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

package pkg

import (
	"fmt"
	"os"
	"sort"
	"strings"

	"github.com/Masterminds/semver/v3"

	"sumi.care/util/sumicare-versioning/pkg/github"
)

const (
	// DefaultVersionLimit is the default number of versions to fetch.
	DefaultVersionLimit = 5
	// FetchMultiplier is the multiplier for fetching extra tags to account for filtering.
	// This is set high to handle repositories with many non-version tags (e.g., helm-chart/*, cmd/ctl/*, edge-*).
	FetchMultiplier = 100
	// FetchLimit is the maximum number of tags/releases to fetch from GitHub.
	// This allows fetching up to 10 pages (100 items per page) to ensure we capture recent versions
	// even in repositories with many non-version tags.
	FetchLimit = 1000
)

// fetchVersionsWith is a shared helper that fetches version-like strings using the provided
// fetch function (e.g., tags or releases), filters to stable semver versions after stripping
// the prefix, sorts them in descending order, and returns the top N.
func fetchVersionsWith(
	repo, prefix string,
	limit int,
	fetch func(client *github.Client, repo, authToken string, limit *int) ([]string, error),
) ([]string, error) {
	effectiveLimit := limit
	if effectiveLimit <= 0 {
		effectiveLimit = DefaultVersionLimit
	}

	client := github.NewClient()
	fetchLimit := min(effectiveLimit*FetchMultiplier, FetchLimit)

	authToken := os.Getenv("GITHUB_TOKEN")

	items, err := fetch(client, repo, authToken, &fetchLimit)
	if err != nil {
		return nil, fmt.Errorf("error fetching GitHub items: %w", err)
	}

	var validVersions []*semver.Version
	for _, raw := range items {
		versionStr := strings.TrimPrefix(raw, prefix)

		parsedVersion, err := semver.NewVersion(versionStr)
		if err != nil {
			continue
		}

		if parsedVersion.Prerelease() == "" {
			validVersions = append(validVersions, parsedVersion)
		}
	}

	sort.Slice(validVersions, func(i, j int) bool {
		return validVersions[i].GreaterThan(validVersions[j])
	})

	result := make([]string, 0, effectiveLimit)
	for i := 0; i < len(validVersions) && i < effectiveLimit; i++ {
		result = append(result, validVersions[i].String())
	}

	return result, nil
}

// FetchGitHubVersions fetches and filters versions from a GitHub repository.
// This matches the behavior of the Kotlin VersionsFetcher.githubVersions function.
//
// Parameters:
//   - repo: GitHub repository URL
//   - limit: number of versions to return (default: 5)
//
// Returns filtered, sorted versions without 'v' prefix, or error.
func FetchGitHubVersions(repo string, limit int) ([]string, error) {
	versions, err := FetchGitHubVersionsWithPrefix(repo, "v", limit)
	if err != nil {
		return nil, fmt.Errorf("error fetching GitHub versions: %w", err)
	}

	return versions, nil
}

// FetchGitHubVersionsWithPrefix fetches and filters versions from a GitHub repository with a custom prefix.
// This matches the behavior of the Kotlin VersionsFetcher.githubVersions function.
//
// Parameters:
//   - repo: GitHub repository URL
//   - prefix: prefix to remove from tags (e.g., "v", "vertical-pod-autoscaler-")
//   - limit: number of versions to return (default: 5)
//
// Returns filtered, sorted versions without prefix, or error.
func FetchGitHubVersionsWithPrefix(repo, prefix string, limit int) ([]string, error) {
	versions, err := fetchVersionsWith(repo, prefix, limit, (*github.Client).GetTags)
	if err != nil {
		return nil, fmt.Errorf("fetch versions with prefix: %w", err)
	}

	return versions, nil
}

// FetchGitHubReleasesWithPrefix fetches and filters versions from GitHub releases with a custom prefix.
// Similar to FetchGitHubVersionsWithPrefix but uses releases instead of tags.
//
// Parameters:
//   - repo: GitHub repository URL
//   - prefix: prefix to remove from release tags (e.g., "v")
//   - limit: number of versions to return (default: 5)
//
// Returns filtered, sorted versions without prefix, or error.
func FetchGitHubReleasesWithPrefix(repo, prefix string, limit int) ([]string, error) {
	versions, err := fetchVersionsWith(repo, prefix, limit, (*github.Client).GetReleases)
	if err != nil {
		return nil, fmt.Errorf("fetch releases with prefix: %w", err)
	}

	return versions, nil
}

// FetchGitHubReleases fetches and filters versions from GitHub releases.
//
// Parameters:
//   - repo: GitHub repository URL
//   - limit: number of versions to return (default: 5)
//
// Returns filtered, sorted versions without 'v' prefix, or error.
func FetchGitHubReleases(repo string, limit int) ([]string, error) {
	releases, err := FetchGitHubReleasesWithPrefix(repo, "v", limit)
	if err != nil {
		return nil, fmt.Errorf("error fetching GitHub releases: %w", err)
	}

	return releases, nil
}
