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

// Package asdf provides helpers for managing asdf plugins and tool versions
// using the .tool-versions file.
package asdf

import (
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"
)

// InstallPlugins ensures all plugins in the root .tool-versions file are installed.
func InstallPlugins() error {
	err := InstallPluginsForFile(toolVersionsFile)
	if err != nil {
		return fmt.Errorf("failed to install plugins from %s: %w", toolVersionsFile, err)
	}

	return nil
}

// InstallPluginsForFile ensures all plugins listed in the given .tool-versions
// file are installed.
func InstallPluginsForFile(path string) error {
	versions, err := parseToolVersions(path)
	if err != nil {
		return fmt.Errorf("failed to parse tool-versions file %s: %w", path, err)
	}

	if len(versions) == 0 {
		return nil
	}

	pluginsDir, err := getAsdfPluginsDir()
	if err != nil {
		return fmt.Errorf("failed to get asdf plugins directory: %w", err)
	}

	missingPlugins := make([]string, 0)

	for plugin := range versions {
		pluginDir := filepath.Join(pluginsDir, plugin)

		_, statErr := os.Stat(pluginDir)
		if errors.Is(statErr, os.ErrNotExist) {
			missingPlugins = append(missingPlugins, plugin)
			continue
		}

		if statErr != nil {
			return fmt.Errorf("failed to check plugin %q in %q: %w", plugin, pluginsDir, statErr)
		}
	}

	if len(missingPlugins) > 0 {
		return fmt.Errorf("%w: %s", ErrPluginNotFound, strings.Join(missingPlugins, ", "))
	}

	return nil
}

// GetAsdfVersions parses the root .tool-versions file and returns a map of plugin name to version.
func GetAsdfVersions() map[string]string { return GetAsdfVersionsForFile(toolVersionsFile) }

// GetAsdfVersionsForFile parses the specified .tool-versions-style file and
// returns a map of plugin name to version.
func GetAsdfVersionsForFile(path string) map[string]string {
	versions, err := parseToolVersions(path)
	if err != nil {
		return make(map[string]string)
	}

	return versions
}

// GetVersions implements the versions.VersionFetcher signature for asdf-managed tools.
func GetVersions(name string) ([]string, error) {
	version, ok := GetAsdfVersions()[name]
	if !ok {
		return nil, fmt.Errorf("%w: plugin %q not found in %s", ErrPluginNotFound, name, toolVersionsFile)
	}

	return []string{version}, nil
}

// SyncToolVersionsFiles updates additional .tool-versions-style files so that
// the versions of any tools they reference match the root .tool-versions file.
//
// Comments, blank lines, and tools not present in the root .tool-versions file
// are preserved as-is. Only lines with a tool name that also exists in the
// root file have their version updated.
func SyncToolVersionsFiles(paths ...string) error {
	if len(paths) == 0 {
		return nil
	}

	rootVersions, err := parseToolVersions(toolVersionsFile)
	if err != nil {
		return fmt.Errorf("failed to parse root tool-versions file %s: %w", toolVersionsFile, err)
	}

	if len(rootVersions) == 0 {
		return nil
	}

	for _, path := range paths {
		err := syncSingleToolVersionsFile(path, rootVersions)
		if err != nil {
			return fmt.Errorf("failed to sync tool-versions file %s: %w", path, err)
		}
	}

	return nil
}

// syncSingleToolVersionsFile applies the versions from rootVersions to a
// single .tool-versions-style file while preserving comments and formatting
// where possible.
func syncSingleToolVersionsFile(path string, rootVersions map[string]string) error {
	data, err := os.ReadFile(path)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			// Nothing to sync if the file doesn't exist.
			return nil
		}

		return fmt.Errorf("failed to read %s: %w", path, err)
	}

	lines := strings.Split(string(data), "\n")

	for i, line := range lines {
		trimmed := strings.TrimSpace(line)
		if trimmed == "" || strings.HasPrefix(trimmed, "#") {
			continue
		}

		fields := strings.Fields(trimmed)
		if len(fields) < 2 { //nolint:mnd // .tool-versions lines have at least two fields: name and version
			continue
		}

		name := fields[0]

		version, ok := rootVersions[name]
		if !ok || version == "" {
			continue
		}

		lines[i] = fmt.Sprintf("%s %s", name, version)
	}

	output := strings.Join(lines, "\n")

	err = os.WriteFile(path, []byte(output), defaultFilePermission600)
	if err != nil {
		return fmt.Errorf("failed to write %s: %w", path, err)
	}

	return nil
}

// parseToolVersions reads a .tool-versions style file and returns a map of
// plugin name to version.
func parseToolVersions(path string) (map[string]string, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		if errors.Is(err, os.ErrNotExist) {
			return make(map[string]string), nil
		}

		return nil, fmt.Errorf("failed to read %s: %w", path, err)
	}

	lines := strings.Split(string(data), "\n")
	versions := make(map[string]string)

	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" || strings.HasPrefix(line, "#") {
			continue
		}

		fields := strings.Fields(line)
		if len(fields) < 2 { //nolint:mnd // .tool-versions lines have at least two fields: name and version
			continue
		}

		name := fields[0]
		version := fields[1]

		versions[name] = version
	}

	return versions, nil
}

// getAsdfPluginsDir returns the path to the asdf plugins directory, taking into
// account the ASDF_DATA_DIR environment variable.
func getAsdfPluginsDir() (string, error) {
	dataDir, err := getAsdfDataDir()
	if err != nil {
		return "", fmt.Errorf("failed to determine asdf data directory: %w", err)
	}

	pluginsDir := filepath.Join(dataDir, "plugins")

	err = os.MkdirAll(pluginsDir, defaultDirectoryPermission755)
	if err != nil {
		return "", fmt.Errorf("failed to create asdf plugins directory %q: %w", pluginsDir, err)
	}

	return pluginsDir, nil
}

// getAsdfDataDir returns the asdf data directory, respecting ASDF_DATA_DIR and
// defaulting to ~/.asdf when not set.
func getAsdfDataDir() (string, error) {
	dataDir := os.Getenv("ASDF_DATA_DIR")
	if dataDir != "" {
		return dataDir, nil
	}

	homeDir, err := os.UserHomeDir()
	if err != nil {
		return "", fmt.Errorf("failed to determine user home directory: %w", err)
	}

	return filepath.Join(homeDir, ".asdf"), nil
}

// copyDir recursively copies a directory tree from src to dst.
func copyDir(src, dst string) error {
	info, err := os.Stat(src)
	if err != nil {
		return fmt.Errorf("failed to stat src %q: %w", src, err)
	}

	if !info.IsDir() {
		return fmt.Errorf("%w: source %q", ErrSourceNotDirectory, src)
	}

	err = os.MkdirAll(dst, info.Mode())
	if err != nil {
		return fmt.Errorf("failed to create dst %q: %w", dst, err)
	}

	entries, err := os.ReadDir(src)
	if err != nil {
		return fmt.Errorf("failed to read dir %q: %w", src, err)
	}

	for _, entry := range entries {
		srcPath := filepath.Join(src, entry.Name())
		dstPath := filepath.Join(dst, entry.Name())

		entryInfo, err := entry.Info()
		if err != nil {
			return fmt.Errorf("failed to stat entry %q: %w", srcPath, err)
		}

		if entryInfo.IsDir() {
			err := copyDir(srcPath, dstPath)
			if err != nil {
				return fmt.Errorf("failed to copy directory %q to %q: %w", srcPath, dstPath, err)
			}

			continue
		}

		err = copyFile(srcPath, dstPath, entryInfo.Mode())
		if err != nil {
			return fmt.Errorf("failed to copy file %q to %q: %w", srcPath, dstPath, err)
		}
	}

	return nil
}

// copyFile copies a single file from src to dst with the given file mode.
func copyFile(src, dst string, mode os.FileMode) error {
	srcFile, err := os.Open(src)
	if err != nil {
		return fmt.Errorf("failed to open src file %q: %w", src, err)
	}
	defer srcFile.Close()

	dstFile, err := os.OpenFile(dst, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, mode)
	if err != nil {
		return fmt.Errorf("failed to create dst file %q: %w", dst, err)
	}
	defer dstFile.Close()

	_, err = io.Copy(dstFile, srcFile)
	if err != nil {
		return fmt.Errorf("failed to copy %q to %q: %w", src, dst, err)
	}

	return nil
}
