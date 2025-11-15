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
)

const (
	// vpaRepo is the VPA repository URL.
	vpaRepo = "https://github.com/kubernetes/autoscaler.git"

	// vpaVersionPrefix is the release prefix used by VPA releases.
	vpaVersionPrefix = "vertical-pod-autoscaler-"
)

// GetVpaVersion fetches the latest VPA versions from GitHub Releases.
// VPA uses "vertical-pod-autoscaler-" prefix for release tags.
// Filters out chart versions and pre-releases.
// Versions are sorted in descending order.
//
// Parameters:
//   - limit: number of versions to fetch (default: 5)
//
// Returns list of version strings without prefix, or error.
func GetVpaVersion(limit int) ([]string, error) {
	versions, err := FetchGitHubReleasesWithPrefix(vpaRepo, vpaVersionPrefix, limit)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch VPA versions: %w", err)
	}

	return versions, nil
}
