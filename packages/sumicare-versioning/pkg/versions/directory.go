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

//

// Package versions provides utilities for managing package versions in a monorepo.
// It includes functionality for reading, writing, and synchronizing version information
// across multiple package.json files and a central versions.json file.
package versions

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
)

// EnsureCorrectDirectory searches for the repository root directory by walking up
// the directory tree until it finds a package.json with the expected package name.
// Changes the working directory to the repository root if found.
// Returns an error if the root directory is reached without finding the correct package.json.
func EnsureCorrectDirectory() error {
	startDir, err := os.Getwd()
	if err != nil {
		return fmt.Errorf("failed to get current directory: %w", err)
	}

	currentDir := startDir
	previousDir := ""

	for {
		// Check if we've reached the root directory
		if currentDir == "/" || currentDir == previousDir {
			return fmt.Errorf("%w: searched from %q to root", ErrRepositoryRootNotFound, startDir)
		}

		// Try to read package.json in current directory
		packagePath := filepath.Join(currentDir, RootPackageJSONPath)

		data, err := os.ReadFile(packagePath)
		if err == nil {
			// Parse package.json
			var pkg PackageJSON

			err := json.Unmarshal(data, &pkg)
			if err != nil {
				// Invalid package.json, continue searching
				previousDir = currentDir
				currentDir = filepath.Dir(currentDir)

				continue
			}

			// Check if this is the correct package
			if pkg.Name == ExpectedPackageName {
				// Found the correct directory, change to it
				if currentDir != startDir {
					err := os.Chdir(currentDir)
					if err != nil {
						return fmt.Errorf("failed to change directory to %q: %w", currentDir, err)
					}
				}

				return nil
			}
		}

		// Move up one directory
		previousDir = currentDir
		currentDir = filepath.Dir(currentDir)
	}
}
