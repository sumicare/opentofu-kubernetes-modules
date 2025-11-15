//
// Copyright (c) 2025 Sumicare
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//   http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// Package github provides a client for interacting with the GitHub API.
package github

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"regexp"
	"strings"
	"time"
)

const (
	// APIVersion is the GitHub API version used for requests.
	APIVersion = "2022-11-28"

	// maxRetries is the maximum number of retries for failed requests.
	maxRetries = 3

	// initialBackoff is the initial backoff duration for retries.
	initialBackoff = 100 * time.Millisecond

	// maxBackoff is the maximum backoff duration for retries.
	maxBackoff = 2 * time.Second

	// httpTimeout is the timeout for HTTP requests.
	httpTimeout = 30 * time.Second
)

var (
	// ErrInvalidURL is returned when the provided URL cannot be parsed.
	ErrInvalidURL = errors.New("invalid GitHub repository URL")
	// ErrHTTPRequest is returned when an HTTP request fails.
	ErrHTTPRequest = errors.New("HTTP request failed")
)

// Client provides methods to interact with GitHub API.
type Client struct {
	httpClient *http.Client
}

// NewClient creates a new GitHub client.
func NewClient() *Client {
	return &Client{
		httpClient: &http.Client{
			Timeout: httpTimeout,
		},
	}
}

// GetOwnerRepoFrom extracts owner and repository name from a given URL.
//
// Accepts URLs in the following formats:
// - `git@github.com:owner/repo.git`
// - `https://github.com/owner/repo.git`
// - `https://github.com/owner/repo`
//
// Returns owner and repository names. If the URL is invalid, returns empty strings.
func GetOwnerRepoFrom(url string) (string, string) {
	const expectedParts = 2

	cleaned := strings.Replace(url, "git@github.com:", "", 1)

	cleaned = strings.Replace(cleaned, "https://github.com/", "", 1)

	parts := strings.Split(cleaned, "/")
	if len(parts) != expectedParts {
		return "", ""
	}

	owner := parts[0]
	repo := strings.TrimSuffix(parts[1], ".git")

	return owner, repo
}

// parseNextLink extracts the next page URL from the Link header.
func parseNextLink(linkHeader string) string {
	if linkHeader == "" {
		return ""
	}

	re := regexp.MustCompile(`<([^>]+)>;\s*rel="next"`)

	matches := re.FindStringSubmatch(linkHeader)
	if len(matches) > 1 {
		return matches[1]
	}

	return ""
}

// isRetryableError checks if an error is transient and should be retried.
func isRetryableError(err error) bool {
	if err == nil {
		return false
	}

	errStr := err.Error()
	// Retry on stream errors, timeouts, and connection resets
	return strings.Contains(errStr, "stream error") ||
		strings.Contains(errStr, "timeout") ||
		strings.Contains(errStr, "connection reset") ||
		strings.Contains(errStr, "connection refused") ||
		strings.Contains(errStr, "temporary failure")
}

// fetchPageByURL fetches a single page from the GitHub API with retry logic.
func (client *Client) fetchPageByURL(url, authToken string, result any) (string, error) {
	var lastErr error

	backoff := initialBackoff

	for attempt := 0; attempt <= maxRetries; attempt++ {
		req, err := http.NewRequestWithContext(context.Background(), http.MethodGet, url, http.NoBody)
		if err != nil {
			return "", fmt.Errorf("failed to create request: %w", err)
		}

		req.Header.Set("X-Github-Api-Version", APIVersion)
		req.Header.Set("Accept", "application/vnd.github.v3+json")

		if authToken != "" {
			req.Header.Set("Authorization", "Bearer "+authToken)
		}

		resp, err := client.httpClient.Do(req)
		if err != nil {
			lastErr = err
			if attempt < maxRetries && isRetryableError(err) {
				time.Sleep(backoff)

				backoff *= 2
				if backoff > maxBackoff {
					backoff = maxBackoff
				}

				continue
			}

			return "", fmt.Errorf("network request failed: %w", err)
		}

		//nolint:revive, gocritic // we're fine with defer here
		defer resp.Body.Close()

		if resp.StatusCode != http.StatusOK {
			body, readErr := io.ReadAll(resp.Body)
			if readErr != nil {
				return "", fmt.Errorf("%w: status %d %s", ErrHTTPRequest, resp.StatusCode, resp.Status)
			}

			return "", fmt.Errorf("%w: status %d %s - %s", ErrHTTPRequest, resp.StatusCode, resp.Status, string(body))
		}

		body, err := io.ReadAll(resp.Body)
		if err != nil {
			lastErr = err
			if attempt < maxRetries && isRetryableError(err) {
				time.Sleep(backoff)

				backoff *= 2
				if backoff > maxBackoff {
					backoff = maxBackoff
				}

				continue
			}

			return "", fmt.Errorf("failed to read response body: %w", err)
		}

		err = json.Unmarshal(body, result)
		if err != nil {
			return "", fmt.Errorf("failed to parse GitHub API response: %w", err)
		}

		nextURL := parseNextLink(resp.Header.Get("Link"))

		return nextURL, nil
	}

	return "", fmt.Errorf("network request failed after %d retries: %w", maxRetries, lastErr)
}

// fetchAll fetches all items from a paginated GitHub API endpoint.
func (client *Client) fetchAll(owner, repo, endpoint, authToken string, limit *int) ([]json.RawMessage, error) {
	if limit != nil && *limit <= 0 {
		return make([]json.RawMessage, 0), nil
	}

	url := fmt.Sprintf("https://api.github.com/repos/%s/%s/%s?per_page=100&sort=created&direction=desc", owner, repo, endpoint)

	var acc []json.RawMessage

	for {
		remaining := -1
		if limit != nil {
			remaining = *limit - len(acc)
			if remaining <= 0 {
				break
			}
		}

		var items []json.RawMessage

		nextURL, err := client.fetchPageByURL(url, authToken, &items)
		if err != nil {
			return nil, fmt.Errorf("failed to fetch GitHub page: %w", err)
		}

		if len(items) == 0 {
			break
		}

		toAdd := items
		if remaining >= 0 && remaining < len(items) {
			toAdd = items[:remaining]
		}

		acc = append(acc, toAdd...)

		if nextURL == "" {
			break
		}

		url = nextURL
	}

	return acc, nil
}

// getGithubToken retrieves the GitHub token from environment variable.
func getGithubToken() string {
	return os.Getenv("GITHUB_TOKEN")
}
