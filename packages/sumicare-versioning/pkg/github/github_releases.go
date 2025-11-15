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

package github

import (
	"encoding/json"
	"fmt"
	"sort"
)

// GitReleaseResponse represents a GitHub release.
type GitReleaseResponse struct {
	NodeID      string `json:"node_id"`
	TagName     string `json:"tag_name"`
	Name        string `json:"name"`
	Body        string `json:"body"`
	CreatedAt   string `json:"created_at"`
	PublishedAt string `json:"published_at"`
	ID          int64  `json:"id"`
	Draft       bool   `json:"draft"`
	Prerelease  bool   `json:"prerelease"`
}

// GetReleases fetches all releases for a given repository URL.
//
// Parameters:
//   - url: repository URL
//   - authToken: optional GitHub authentication token (uses GITHUB_TOKEN env var if empty)
//   - limit: optional limit on the number of releases to fetch (nil for all)
//
// Returns list of release tag names sorted in descending order, or error.
func (client *Client) GetReleases(url, authToken string, limit *int) ([]string, error) {
	owner, repo := GetOwnerRepoFrom(url)
	if owner == "" || repo == "" {
		return nil, fmt.Errorf("%w: %s", ErrInvalidURL, url)
	}

	token := authToken
	if token == "" {
		token = getGithubToken()
	}

	items, err := client.fetchAll(owner, repo, "releases", token, limit)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch releases: %w", err)
	}

	releases := make([]string, 0, len(items))
	for _, item := range items {
		var release GitReleaseResponse

		err := json.Unmarshal(item, &release)
		if err != nil {
			return nil, fmt.Errorf("failed to parse release: %w", err)
		}

		releases = append(releases, release.TagName)
	}

	// Sort in descending order
	sort.Slice(releases, func(i, j int) bool {
		return releases[i] > releases[j]
	})

	if limit != nil && len(releases) > *limit {
		releases = releases[:*limit]
	}

	return releases, nil
}
