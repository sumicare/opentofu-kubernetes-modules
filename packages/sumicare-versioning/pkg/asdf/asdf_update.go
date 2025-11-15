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

import (
	"bytes"
	"context"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"sort"
	"strings"
	"sync"

	semver "github.com/Masterminds/semver/v3"

	"sumi.care/util/sumicare-versioning/pkg/versions"
)

// UpdateToolsToLatest ensures all tools in the root .tool-versions are updated to their latest versions.
func UpdateToolsToLatest() ([]ToolUpdateResult, error) {
	results, err := UpdateToolsToLatestForFile(toolVersionsFile)
	if err != nil {
		return nil, fmt.Errorf("failed to update tools to latest from %s: %w", toolVersionsFile, err)
	}

	return results, nil
}

// runInParallel executes the provided function for each item in items using
// a separate goroutine per item and waits for all goroutines to complete.
func runInParallel[T any](items []T, fn func(T)) {
	var wg sync.WaitGroup

	for _, item := range items {
		wg.Go(func() {
			fn(item)
		})
	}

	wg.Wait()
}

// UpdateToolsToLatestForFile ensures that all tools listed in the given
// .tool-versions-style file are updated to their latest available versions
// according to `asdf list all`.
//
// Behavior is identical to UpdateToolsToLatest, but scoped to the provided
// file path.
func UpdateToolsToLatestForFile(path string) ([]ToolUpdateResult, error) {
	existingVersions, err := parseToolVersions(path)
	if err != nil {
		return nil, fmt.Errorf("failed to parse tool-versions file %s: %w", path, err)
	}

	if len(existingVersions) == 0 {
		return make([]ToolUpdateResult, 0), nil
	}

	results := make([]ToolUpdateResult, 0, len(existingVersions))
	updatedVersions := make(map[string]string, len(existingVersions))

	// First pass: determine the latest versions for each tool and update the
	// in-memory map that will be written to .tool-versions. No installations are
	// performed in this pass. Use goroutines for parallel fetching.
	var (
		failedLatest []string
		mu           sync.Mutex
	)

	type toolVersionJob struct {
		name       string
		oldVersion string
	}

	jobs := make([]toolVersionJob, 0, len(existingVersions))
	for name, oldVersion := range existingVersions {
		jobs = append(jobs, toolVersionJob{name: name, oldVersion: oldVersion})
	}

	runInParallel(jobs, func(job toolVersionJob) {
		// Special handling for packages with non-semver versions
		if preservedVersion := getPreservedVersion(job.name, job.oldVersion); preservedVersion != "" {
			mu.Lock()

			results = append(results, ToolUpdateResult{
				Name:       job.name,
				OldVersion: job.oldVersion,
				NewVersion: preservedVersion,
				Changed:    job.oldVersion != preservedVersion,
			})
			updatedVersions[job.name] = preservedVersion

			mu.Unlock()

			return
		}

		latestVersion, latestErr := getLatestAsdfVersion(job.name)

		mu.Lock()
		defer mu.Unlock()

		if latestErr != nil {
			// Skip updating this tool to a new version, but record the failure
			// and keep the existing version pinned.
			failedLatest = append(failedLatest, job.name)

			results = append(results, ToolUpdateResult{
				Name:       job.name,
				OldVersion: job.oldVersion,
				NewVersion: job.oldVersion,
				Changed:    false,
			})

			updatedVersions[job.name] = job.oldVersion

			return
		}

		results = append(results, ToolUpdateResult{
			Name:       job.name,
			OldVersion: job.oldVersion,
			NewVersion: latestVersion,
			Changed:    job.oldVersion != "" && job.oldVersion != latestVersion,
		})

		updatedVersions[job.name] = latestVersion
	})

	// Update the .tool-versions file to reflect the latest versions before
	// performing any installations.
	err = writeToolVersions(path, updatedVersions)
	if err != nil {
		return nil, fmt.Errorf("failed to update %s: %w", path, err)
	}

	// Second pass: ensure the corresponding versions are installed in parallel.
	dataDir, err := getAsdfDataDir()
	if err != nil {
		return nil, fmt.Errorf("failed to determine asdf data directory: %w", err)
	}

	var (
		installMu     sync.Mutex
		installErrors []error
	)

	installJobs := make([]*ToolUpdateResult, 0, len(results))
	for i := range results {
		installJobs = append(installJobs, &results[i])
	}

	runInParallel(installJobs, func(res *ToolUpdateResult) {
		installDir := filepath.Join(dataDir, "installs", res.Name, res.NewVersion)
		_, statErr := os.Stat(installDir)
		installed := statErr == nil

		if !installed {
			ctx := context.Background()
			cmd := exec.CommandContext(ctx, "asdf", "install", res.Name, res.NewVersion) //nolint:gosec // G204 -- tool name and version originate from local configuration

			// Ensure GitHub token is available for asdf plugins that fetch from GitHub.
			cmd.Env = os.Environ()

			if token := os.Getenv("GITHUB_TOKEN"); token != "" {
				cmd.Env = append(cmd.Env, "GITHUB_API_TOKEN="+token)
			}

			cmd.Stdout = os.Stdout
			cmd.Stderr = os.Stderr

			installErr := cmd.Run()
			if installErr != nil {
				installMu.Lock()

				installErrors = append(installErrors, fmt.Errorf("failed to install %s %s: %w", res.Name, res.NewVersion, installErr))

				installMu.Unlock()

				return
			}
		}

		installMu.Lock()

		res.Installed = !installed

		installMu.Unlock()
	})

	if len(installErrors) > 0 {
		return nil, installErrors[0]
	}

	if len(failedLatest) > 0 {
		return results, fmt.Errorf("%w: %s", ErrFailedToDetermineLatestVersions, strings.Join(failedLatest, ", "))
	}

	return results, nil
}

// getLatestAsdfVersion returns the latest available version for the given tool
// name using `asdf list all <tool>`.
func getLatestAsdfVersion(name string) (string, error) {
	ctx := context.Background()
	cmd := exec.CommandContext(ctx, "asdf", "list", "all", name) // #nosec G204 -- tool name originates from local configuration

	// Ensure GitHub token is available for asdf plugins that fetch from GitHub.
	// Some plugins use GITHUB_API_TOKEN, others use GITHUB_TOKEN.
	cmd.Env = os.Environ()

	if token := os.Getenv("GITHUB_TOKEN"); token != "" {
		cmd.Env = append(cmd.Env, "GITHUB_API_TOKEN="+token)
	}

	output, err := cmd.Output()
	if err != nil {
		return "", fmt.Errorf("failed to list versions for %s: %w", name, err)
	}

	// Convert output bytes to lines of text for easier testing and processing.
	lines := bytes.Split(output, []byte("\n"))

	stringLines := make([]string, 0, len(lines))
	for _, raw := range lines {
		stringLines = append(stringLines, strings.TrimSpace(string(raw)))
	}

	version, err := selectLatestSemverVersion(stringLines, name)
	if err != nil {
		return "", fmt.Errorf("failed to select latest semver version for %s: %w", name, err)
	}

	return version, nil
}

// selectLatestSemverVersion selects the highest semantic version from the
// provided lines. Each line may contain additional annotations; the first
// whitespace-separated token is treated as the candidate version string.
//
// The selection rules are:
//   - Prefer stable versions (no prerelease segment, e.g., 3.14.0).
//   - If no stable versions exist, fall back to all valid semver versions,
//     including prereleases like rc/dev.
//   - If no valid semver versions are found at all, fall back to the last
//     non-empty line as-is.
func selectLatestSemverVersion(lines []string, toolName string) (string, error) {
	allVersions := make([]*semver.Version, 0, len(lines))
	stableVersions := make([]*semver.Version, 0, len(lines))

	for _, line := range lines {
		line = strings.TrimSpace(line)
		if line == "" {
			continue
		}

		fields := strings.Fields(line)
		if len(fields) == 0 {
			continue
		}

		version, err := semver.NewVersion(fields[0])
		if err != nil {
			continue
		}

		allVersions = append(allVersions, version)
		if version.Prerelease() == "" {
			stableVersions = append(stableVersions, version)
		}
	}

	if len(allVersions) == 0 {
		// If no valid semver versions are found, fall back to the last non-empty line.
		for i := len(lines) - 1; i >= 0; i-- {
			line := strings.TrimSpace(lines[i])
			if line == "" {
				continue
			}

			return line, nil
		}

		return "", fmt.Errorf("%w: %s", ErrNoVersionsFound, toolName)
	}

	// Prefer stable versions (no prerelease). If none exist, fall back to all
	// versions (including prereleases like rc/dev).
	candidates := stableVersions
	if len(candidates) == 0 {
		candidates = allVersions
	}

	// Select the highest semver version among candidates.
	latest := candidates[0]
	for _, v := range candidates[1:] {
		if v.GreaterThan(latest) {
			latest = v
		}
	}

	return latest.Original(), nil
}

// writeToolVersions writes the given versions map to the .tool-versions file
// in a deterministic, sorted order.
func writeToolVersions(path string, toolVersions map[string]string) error {
	keys := make([]string, 0, len(toolVersions))
	for name := range toolVersions {
		keys = append(keys, name)
	}

	sort.Strings(keys)

	buf := &bytes.Buffer{}
	for _, name := range keys {
		version := toolVersions[name]
		if version == "" {
			continue
		}

		_, err := fmt.Fprintf(buf, "%s %s\n", name, version)
		if err != nil {
			return fmt.Errorf("failed to format tool version line: %w", err)
		}
	}

	err := os.WriteFile(path, buf.Bytes(), defaultFilePermission600)
	if err != nil {
		return fmt.Errorf("failed to write %s: %w", path, err)
	}

	return nil
}

// getPreservedVersion returns the preserved version for the given package name and current version.
func getPreservedVersion(packageName, currentVersion string) string {
	return versions.GetPreservedVersion(packageName, currentVersion)
}
