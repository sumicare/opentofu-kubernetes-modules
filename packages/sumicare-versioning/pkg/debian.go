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
	"errors"
	"fmt"
	"sort"
	"strconv"
	"strings"
	"time"

	"sumi.care/util/sumicare-versioning/pkg/dockerhub"
)

const (
	// fetchMultiplier is the multiplier for fetching extra tags to ensure enough results after filtering.
	fetchMultiplier = 10
	// currentDebianRelease is the current stable Debian release name.
	currentDebianRelease = "trixie"
)

// ErrNoDebianTagsFound is returned when no matching Debian tags are found.
var ErrNoDebianTagsFound = errors.New("no matching debian tags found")

// GetDebianVersion fetches the latest Debian slim image tags from Docker Hub.
// Filters for tags matching the pattern: {releasename}-{currentyear}****-slim
// Versions are sorted in descending order.
//
// Parameters:
//   - limit: number of versions to fetch (default: 5)
//
// Returns list of Debian slim tag names (e.g., "trixie-20251117-slim"), or error.
func GetDebianVersion(limit int) ([]string, error) {
	currentYear := time.Now().Year()
	yearPrefix := strconv.Itoa(currentYear)

	// Filter for tags matching {releasename}-{currentyear}****-slim pattern
	releaseFilter := func(tag string) bool {
		pattern := fmt.Sprintf("%s-%s", currentDebianRelease, yearPrefix)
		return strings.HasPrefix(tag, pattern) && strings.HasSuffix(tag, "-slim")
	}

	// Fetch many more tags to ensure we have enough after filtering

	//nolint:mnd // it's okay
	tags, err := dockerhub.FetchImageTags("debian", releaseFilter, limit*fetchMultiplier*5)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch debian tags: %w", err)
	}

	if len(tags) == 0 {
		return nil, fmt.Errorf("%w: %s-%s*-slim", ErrNoDebianTagsFound, currentDebianRelease, yearPrefix)
	}

	// Sort tags in descending order (most recent first)
	// Tags are in format: trixie-20251117-slim, trixie-20251116-slim, etc.
	sort.Slice(tags, func(i, j int) bool {
		return tags[i] > tags[j]
	})

	// Return up to limit tags
	if len(tags) > limit {
		tags = tags[:limit]
	}

	return tags, nil
}
