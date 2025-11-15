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

package crds

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"maps"
	"net/http"
	"os"
	"path"
	"strings"
)

// githubDownloader downloads CRDs from GitHub.
type githubDownloader struct {
	client     *http.Client
	token      string
	apiBaseURL string // Base URL for GitHub API (for testing)
	rawBaseURL string // Base URL for raw content (for testing)
}

// newGitHubDownloader creates a new GitHub downloader.
// It reads the GitHub token from the GITHUB_TOKEN environment variable.
func newGitHubDownloader() *githubDownloader {
	// Get token from environment variable
	token := os.Getenv(githubTokenEnvVar)

	return &githubDownloader{
		client:     &http.Client{Timeout: defaultDownloaderTimeout},
		token:      token,
		apiBaseURL: githubAPIBase,
		rawBaseURL: githubRawBase,
	}
}

// download downloads CRDs from a GitHub directory.
func (downloader *githubDownloader) download(ctx context.Context, dir *GitHubCRDDir) (map[string]string, error) {
	if dir == nil {
		return nil, ErrGitHubDirNil
	}

	ref := dir.Ref
	if ref == "" {
		ref = "main"
	}

	pattern := dir.FilePattern
	if pattern == "" {
		pattern = "*.yaml"
	}

	files, err := downloader.listDirectory(ctx, dir.Owner, dir.Repo, dir.Path, ref)
	if err != nil {
		return nil, fmt.Errorf("%w: %w", ErrFailedToListDir, err)
	}

	var matchedFiles []string
	for _, filePath := range files {
		matched, err := path.Match(pattern, path.Base(filePath))
		if err != nil {
			return nil, fmt.Errorf("%w %q: %w", ErrInvalidPattern, pattern, err)
		}

		if matched {
			matchedFiles = append(matchedFiles, filePath)
		}
	}

	if len(matchedFiles) == 0 {
		return nil, fmt.Errorf("%w: %q in %s/%s/%s", ErrNoFilesMatch, pattern, dir.Owner, dir.Repo, dir.Path)
	}

	crds := make(map[string]string)
	for _, filePath := range matchedFiles {
		content, err := downloader.downloadFile(ctx, dir.Owner, dir.Repo, ref, filePath)
		if err != nil {
			return nil, fmt.Errorf("download %s: %w", filePath, err)
		}

		// If FilterCRDsOnly is enabled, only include files that contain CRDs
		if dir.FilterCRDsOnly {
			if !strings.Contains(content, "kind: CustomResourceDefinition") {
				continue
			}
		}

		extracted, err := splitMultiDocYAML(content)
		if err != nil || len(extracted) == 0 {
			if strings.Contains(content, "kind: CustomResourceDefinition") {
				name := extractCRDName(content)

				crds[name+".yaml"] = content
			}

			continue
		}

		maps.Copy(crds, extracted)
	}

	return crds, nil
}

// listDirectory lists files in a directory.
func (downloader *githubDownloader) listDirectory(ctx context.Context, owner, repo, dirPath, ref string) ([]string, error) {
	url := fmt.Sprintf("%s/repos/%s/%s/contents/%s?ref=%s", downloader.apiBaseURL, owner, repo, dirPath, ref)

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, http.NoBody)
	if err != nil {
		return nil, fmt.Errorf("%w: %w", ErrFailedToCreateReq, err)
	}

	req.Header.Set("Accept", "application/vnd.github.v3+json")

	// Add authentication token if available
	if downloader.token != "" {
		req.Header.Set("Authorization", "token "+downloader.token)
	}

	resp, err := downloader.client.Do(req)
	if err != nil {
		return nil, fmt.Errorf("%w: %w", ErrFailedToListDir, err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		body, err := io.ReadAll(resp.Body)
		if err != nil {
			return nil, fmt.Errorf("%w %d: %w", ErrHTTPResponse, resp.StatusCode, err)
		}

		if body != nil {
			return nil, fmt.Errorf("%w %d: %s", ErrHTTPResponse, resp.StatusCode, string(body))
		}

		return nil, fmt.Errorf("%w %d", ErrHTTPResponse, resp.StatusCode)
	}

	var contents []struct {
		Name string `json:"name"`
		Path string `json:"path"`
		Type string `json:"type"`
	}

	err = json.NewDecoder(resp.Body).Decode(&contents)
	if err != nil {
		return nil, fmt.Errorf("%w: %w", ErrFailedToDecodeResp, err)
	}

	var files []string
	for i := range contents {
		if contents[i].Type == "file" {
			files = append(files, contents[i].Path)
		}
	}

	return files, nil
}

// downloadFile downloads a file from GitHub.
func (downloader *githubDownloader) downloadFile(ctx context.Context, owner, repo, ref, filePath string) (string, error) {
	url := fmt.Sprintf("%s/%s/%s/%s/%s", downloader.rawBaseURL, owner, repo, ref, filePath)

	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, http.NoBody)
	if err != nil {
		return "", fmt.Errorf("%w: %w", ErrFailedToCreateReq, err)
	}

	// Add authentication token if available
	if downloader.token != "" {
		req.Header.Set("Authorization", "token "+downloader.token)
	}

	resp, err := downloader.client.Do(req)
	if err != nil {
		return "", fmt.Errorf("%w: %w", ErrFailedToListDir, err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("%w %d", ErrHTTPResponse, resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("%w: %w", ErrFailedToReadResp, err)
	}

	return string(body), nil
}

// matchPattern matches a pattern against a name.
