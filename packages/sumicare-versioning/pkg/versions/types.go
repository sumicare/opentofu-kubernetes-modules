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

package versions

// Type definitions for version operations.
type (
	// VersionsFile maps project names to their version strings.
	VersionsFile map[string]string

	// PackageJSON represents the structure of a package.json file.
	PackageJSON struct {
		Name    string `json:"name"`
		Version string `json:"version"`
	}

	// VersionFetcher is a function that fetches versions for a project.
	VersionFetcher func(limit int) ([]string, error)

	// VersionChange represents a version change for a package.
	VersionChange struct {
		// OldVersion is the previous version of the package.
		OldVersion string

		// NewVersion is the new version of the package.
		NewVersion string

		// Changed indicates whether the version was changed.
		Changed bool
	}
)
