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

package asdf

import "errors"

// Error definitions for asdf operations.
var (
	// ErrPluginNotFound is returned when an asdf plugin is not found.
	ErrPluginNotFound = errors.New("plugin not found")

	// ErrSourceNotDirectory is returned when a source path is not a directory.
	ErrSourceNotDirectory = errors.New("source is not a directory")

	// ErrFailedToDetermineLatestVersions is returned when the latest versions cannot be determined.
	ErrFailedToDetermineLatestVersions = errors.New("failed to determine latest versions")

	// ErrNoVersionsFound is returned when no versions are found for a tool.
	ErrNoVersionsFound = errors.New("no versions found")
)
