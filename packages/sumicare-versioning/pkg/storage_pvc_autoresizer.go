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

// pvcAutoresizerRepo is the PvcAutoresizer repository URL.
const pvcAutoresizerRepo = "https://github.com/topolvm/pvc-autoresizer.git"

// GetPvcAutoresizerVersion fetches the latest PvcAutoresizer versions from GitHub.
// Versions are filtered to exclude pre-releases and sorted in descending order.
//
// Parameters:
//   - limit: number of versions to fetch (default: 5)
//
// Returns list of version strings without 'v' prefix, or error.
func GetPvcAutoresizerVersion(limit int) ([]string, error) {
	versions, err := FetchGitHubReleases(pvcAutoresizerRepo, limit)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch PvcAutoresizer versions: %w", err)
	}

	return versions, nil
}
