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

import (
	"bytes"
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
)

// ReadVersionsFile reads and parses the versions.json file.
func ReadVersionsFile() (VersionsFile, error) {
	versions := make(VersionsFile)

	data, err := os.ReadFile(VersionsFileName)
	if err == nil {
		err = json.Unmarshal(data, &versions)
		if err != nil {
			return nil, fmt.Errorf("failed to parse versions.json: %w", err)
		}
	} else if !os.IsNotExist(err) {
		return nil, fmt.Errorf("failed to read versions.json: %w", err)
	}

	return versions, nil
}

// UpdatePackageJSONFiles updates the package.json files with the given versions.
// Returns maps of updated, unchanged, and skipped packages.
func UpdatePackageJSONFiles(versions VersionsFile, packagesDir string) (map[string]VersionChange, error) {
	entries, err := os.ReadDir(packagesDir)
	if err != nil {
		return nil, fmt.Errorf("failed to read packages directory: %w", err)
	}

	updated := make(map[string]VersionChange)

	for _, entry := range entries {
		if !entry.IsDir() {
			continue
		}

		projectName := entry.Name()

		newVersion, ok := versions[projectName]
		if !ok {
			continue
		}

		packageJSONPath := filepath.Join(packagesDir, projectName, "package.json")

		oldVersion, changed, err := UpdatePackageJSON(packageJSONPath, newVersion)
		if err != nil {
			continue
		}

		updated[projectName] = VersionChange{
			OldVersion: oldVersion,
			NewVersion: newVersion,
			Changed:    changed,
		}
	}

	return updated, nil
}

// UpdatePackageJSON updates a single package.json file with the given version.
// Returns the old version, whether it changed, and any error.
func UpdatePackageJSON(path, version string) (string, bool, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return "", false, fmt.Errorf("failed to read file: %w", err)
	}

	// Parse as generic map to preserve all fields and formatting
	var packageData map[string]any

	err = json.Unmarshal(data, &packageData)
	if err != nil {
		return "", false, fmt.Errorf("failed to parse JSON: %w", err)
	}

	versionKey := "version"
	pkgDir := filepath.Base(filepath.Dir(path))

	// handle non-semver versions with custom keys
	switch pkgDir {
	case "debian":
		versionKey = "debianVersion"
	case "storage-minio":
		versionKey = "minioVersion"
	}

	// Determine the previous version value. Missing version is allowed and
	// treated as an empty old version; non-string values are considered an
	// error to avoid corrupting unexpected structures.
	var oldVersion string
	if rawVersion, exists := packageData[versionKey]; exists {
		storedVersion, ok := rawVersion.(string)
		if !ok {
			return "", false, ErrVersionFieldNotString
		}

		oldVersion = storedVersion
	}

	if oldVersion == version {
		return oldVersion, false, nil
	}

	packageData[versionKey] = version

	buf := &bytes.Buffer{}
	enc := json.NewEncoder(buf)
	enc.SetEscapeHTML(false)
	enc.SetIndent("", "  ")

	err = enc.Encode(packageData)
	if err != nil {
		return oldVersion, false, fmt.Errorf("failed to marshal JSON: %w", err)
	}

	err = os.WriteFile(path, buf.Bytes(), FilePermissions)
	if err != nil {
		return oldVersion, false, fmt.Errorf("failed to write file: %w", err)
	}

	return oldVersion, true, nil
}
