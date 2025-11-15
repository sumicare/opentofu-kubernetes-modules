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

// tektonTriggerRepo is the TektonTrigger repository URL.
const tektonTriggerRepo = "https://github.com/tektoncd/triggers.git"

// GetTektonTriggerVersion fetches the latest TektonTrigger versions from GitHub releases.
// Versions are filtered to exclude pre-releases and sorted in descending order.
//
// Parameters:
//   - limit: number of versions to fetch (default: 5)
//
// Returns list of version strings without 'v' prefix, or error.
func GetTektonTriggerVersion(limit int) ([]string, error) {
	versions, err := FetchGitHubReleases(tektonTriggerRepo, limit)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch tekton trigger versions: %w", err)
	}

	return versions, nil
}
