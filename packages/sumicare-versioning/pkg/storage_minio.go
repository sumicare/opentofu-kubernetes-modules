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
	"regexp"
	"sort"
	"strings"

	"sumi.care/util/sumicare-versioning/pkg/github"
)

const (
	// minioRepo is the Minio repository URL.
	minioRepo = "https://github.com/minio/minio.git"
	// minioPrefix is the tag prefix used by Minio releases.
	minioPrefix = "RELEASE."
	// minioFetchLimit is how many tags to fetch to account for filtering.
	minioFetchLimit = 200
)

// minioDatePattern matches Minio's date-based version format: YYYY-MM-DDTHH-MM-SSZ.\.
var minioDatePattern = regexp.MustCompile(`^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}Z$`)

// GetMinioVersion fetches the latest Minio versions from GitHub.
// Minio uses "RELEASE." prefix with date-based versioning (YYYY-MM-DDTHH-MM-SSZ).
// Returns versions sorted by date descending (newest first).
//
// Parameters:
//   - limit: number of versions to fetch (default: 5)
//
// Returns list of version strings without prefix, or error.
func GetMinioVersion(limit int) ([]string, error) {
	effectiveLimit := limit
	if effectiveLimit <= 0 {
		effectiveLimit = DefaultVersionLimit
	}

	client := github.NewClient()
	// Fetch many tags since Minio has lots of releases
	fetchLimit := minioFetchLimit

	tags, err := client.GetTags(minioRepo, "", &fetchLimit)
	if err != nil {
		return nil, fmt.Errorf("error fetching Minio tags: %w", err)
	}

	// Filter and parse Minio versions
	var validVersions []string
	for _, tag := range tags {
		// Remove RELEASE. prefix
		versionStr := strings.TrimPrefix(tag, minioPrefix)

		// Check if it matches the date pattern
		if minioDatePattern.MatchString(versionStr) {
			validVersions = append(validVersions, versionStr)
		}
	}

	// Sort in descending order (newest first)
	// Date format YYYY-MM-DDTHH-MM-SSZ sorts lexicographically
	sort.Slice(validVersions, func(i, j int) bool {
		return validVersions[i] > validVersions[j]
	})

	// Apply limit
	if len(validVersions) > effectiveLimit {
		return validVersions[:effectiveLimit], nil
	}

	return validVersions, nil
}
