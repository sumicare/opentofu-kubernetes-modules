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

// Package dockerhub provides functionality to fetch image tags from Docker Hub.
package dockerhub

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"
)

const (
	// dockerHubAPIURL is the base URL for Docker Hub API v2.
	dockerHubAPIURL = "https://hub.docker.com/v2"
	// defaultPageSize is the default number of results per page.
	defaultPageSize = 100
	// defaultHTTPTimeout is the default timeout for HTTP requests.
	defaultHTTPTimeout = 30 * time.Second
)

// ErrUnexpectedStatusCode is returned when Docker Hub API returns a non-200 status code.
var ErrUnexpectedStatusCode = errors.New("unexpected status code from docker hub API")

type (
	// TagsResponse represents the response from Docker Hub tags API.
	TagsResponse struct {
		Next     string `json:"next"`
		Previous string `json:"previous"`
		Results  []Tag  `json:"results"`
		Count    int    `json:"count"`
	}

	// Tag represents a Docker image tag.
	Tag struct {
		LastUpdated time.Time `json:"last_updated"`
		Name        string    `json:"name"`
		FullSize    int64     `json:"full_size"`
	}
)

// FetchImageTags fetches image tags from Docker Hub for a given repository.
// Parameters:
//   - repository: the Docker Hub repository (e.g., "debian", "library/debian")
//   - filter: optional filter function to select specific tags
//   - limit: maximum number of tags to return
//
// Returns list of tag names or error.
func FetchImageTags(repository string, filter func(string) bool, limit int) ([]string, error) {
	// Normalize repository name (add library/ prefix for official images if not present)
	normalizedRepository := repository
	if !strings.Contains(repository, "/") {
		normalizedRepository = "library/" + repository
	}

	url := fmt.Sprintf("%s/repositories/%s/tags?page_size=%d", dockerHubAPIURL, normalizedRepository, defaultPageSize)

	var allTags []string

	client := &http.Client{
		Timeout: defaultHTTPTimeout,
	}

	for url != "" && len(allTags) < limit {
		req, err := http.NewRequestWithContext(context.Background(), http.MethodGet, url, http.NoBody)
		if err != nil {
			return nil, fmt.Errorf("failed to create request: %w", err)
		}

		resp, err := client.Do(req)
		if err != nil {
			return nil, fmt.Errorf("failed to fetch tags: %w", err)
		}

		if resp.StatusCode != http.StatusOK {
			resp.Body.Close()
			return nil, fmt.Errorf("%w: %d", ErrUnexpectedStatusCode, resp.StatusCode)
		}

		body, err := io.ReadAll(resp.Body)
		resp.Body.Close()

		if err != nil {
			return nil, fmt.Errorf("failed to read response body: %w", err)
		}

		var tagsResp TagsResponse

		err = json.Unmarshal(body, &tagsResp)
		if err != nil {
			return nil, fmt.Errorf("failed to parse response: %w", err)
		}

		for i := range tagsResp.Results {
			if filter != nil && !filter(tagsResp.Results[i].Name) {
				continue
			}

			allTags = append(allTags, tagsResp.Results[i].Name)
			if len(allTags) >= limit {
				break
			}
		}

		url = tagsResp.Next
	}

	return allTags, nil
}
