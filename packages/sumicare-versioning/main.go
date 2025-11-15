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

// Package main provides a CLI tool for managing version information across packages.
package main

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"strings"
	"sync"

	"sumi.care/util/sumicare-versioning/pkg/asdf"
	"sumi.care/util/sumicare-versioning/pkg/crds"
	"sumi.care/util/sumicare-versioning/pkg/templating"
	"sumi.care/util/sumicare-versioning/pkg/versions"
)

const (
	// minArgsCount is the minimum number of command line arguments required.
	minArgsCount = 2
	// packagesDir is the directory containing package subdirectories.
	packagesDir = "packages"
	// debianToolVersionsPath is the .tool-versions file used for Debian images.
	debianToolVersionsPath = "packages/debian/modules/debian-images/.tool-versions"

	// defaultPreAllocCap pre-allocated slices initial capacity.
	defaultPreAllocCap = 5
)

// main is the entry point of the program.
func main() {
	// Ensure we're in the correct directory
	err := versions.EnsureCorrectDirectory()
	if err != nil {
		fmt.Fprint(os.Stderr, "Error: ")
		fmt.Fprintln(os.Stderr, err)
		fmt.Fprintln(os.Stderr, "Please run this command from the repository root directory.")
		os.Exit(1)
	}

	if len(os.Args) < minArgsCount {
		fmt.Println("Usage: sumicare-versioning <command>")
		fmt.Println("Commands:")
		fmt.Println("  update    - Fetch latest versions and update versions.json and package.json files")
		fmt.Println("  sync      - Sync package.json files from existing versions.json")
		fmt.Println("  crds      - Download CRDs for all packages")
		os.Exit(1)
	}

	command := os.Args[1]

	switch command {
	case "update":
		err := updateVersions()
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}

	case "sync":
		err := syncVersions()
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}

	case "crds":
		err := downloadCRDs()
		if err != nil {
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}

	default:
		fmt.Fprintf(os.Stderr, "Unknown command: %s\n", command)
		os.Exit(1)
	}
}

// printVersionsJSONSummary prints a summary of versions.json and package.json updates.
func printVersionsJSONSummary(updated map[string]versions.VersionChange) {
	actuallyUpdated := 0

	for i := range updated {
		if updated[i].Changed {
			actuallyUpdated++
		}
	}

	fmt.Println("\nsynchronized package.json versions")

	if actuallyUpdated > 0 {
		fmt.Printf("  ✓ %d packages updated\n", actuallyUpdated)
	}
}

// updateVersions fetches the latest versions and updates the versions.json and package.json files.
func updateVersions() error {
	var (
		err                 error
		toolVersionsUpdates = make([]string, 0, defaultPreAllocCap)
		toolVersionsErrors  = make([]string, 0, defaultPreAllocCap)
	)

	//nolint:gocritic // it's fine to iterate over the map
	for _, cfg := range []struct{ Path, Label string }{
		{".tool-versions", ""},
		{debianToolVersionsPath, "debian-images"},
	} {
		err := asdf.InstallPluginsForFile(cfg.Path)
		if err != nil {
			toolVersionsErrors = append(toolVersionsErrors, fmt.Sprintf("%s: %v", cfg.Path, err))
		}

		toolUpdates, err := asdf.UpdateToolsToLatestForFile(cfg.Path)
		if err != nil {
			toolVersionsErrors = append(toolVersionsErrors, fmt.Sprintf("%s: %v", cfg.Path, err))
			continue
		}

		// Count actual changes
		changed := 0

		installed := 0

		for i := range toolUpdates {
			if toolUpdates[i].Changed {
				changed++
			}

			if toolUpdates[i].Installed {
				installed++
			}
		}

		fileLabel := cfg.Path
		if cfg.Label != "" {
			fileLabel = cfg.Label
		}

		if changed == 0 && installed == 0 {
			continue
		}

		var parts []string
		if changed > 0 {
			parts = append(parts, fmt.Sprintf("%d updated", changed))
		}

		if installed > 0 {
			parts = append(parts, fmt.Sprintf("%d installed", installed))
		}

		toolVersionsUpdates = append(toolVersionsUpdates, fmt.Sprintf("%s: %s", fileLabel, strings.Join(parts, ", ")))
	}

	// Fetch all versions in parallel
	syncVersions := make(versions.VersionsFile)

	var (
		versionErrors []string
		mu            sync.Mutex
		wg            sync.WaitGroup
	)

	for projectName, fetchFunc := range versions.GetProjectFetchers() {
		wg.Go(func() {
			latestVersions, err := fetchFunc(1)

			mu.Lock()
			defer mu.Unlock()

			if err != nil {
				versionErrors = append(versionErrors, fmt.Sprintf("%s: %v", projectName, err))
				return
			}

			if len(latestVersions) == 0 {
				versionErrors = append(versionErrors, projectName+": no versions found")
				return
			}

			syncVersions[projectName] = latestVersions[0]
		})
	}

	wg.Wait()

	err = versions.UpdateVersionsJSON(syncVersions)
	if err != nil {
		return fmt.Errorf("failed to update versions.json: %w", err)
	}

	updated, err := versions.UpdatePackageJSONFiles(syncVersions, packagesDir)
	if err != nil {
		return fmt.Errorf("failed to update package.json files: %w", err)
	}

	if len(toolVersionsErrors) > 0 {
		fmt.Println("\n.tool-versions errors:")

		for _, errMsg := range toolVersionsErrors {
			fmt.Printf("  ⚠ %s\n", errMsg)
		}
	}

	if len(toolVersionsUpdates) > 0 {
		fmt.Println("\n.tool-versions updates:")

		for _, update := range toolVersionsUpdates {
			fmt.Printf("  ✓ %s\n", update)
		}
	} else if len(toolVersionsErrors) == 0 {
		fmt.Println("\n.tool-versions: No changes (all tools up to date)")
	}

	if len(versionErrors) > 0 {
		fmt.Println("\nversions.json errors:")

		for _, errMsg := range versionErrors {
			fmt.Printf("  ⚠ %s\n", errMsg)
		}
	}

	printVersionsJSONSummary(updated)

	return nil
}

// downloadCRDs downloads CRDs for all packages using the crds package.
func downloadCRDs() error {
	// Create a downloader instance
	downloader := crds.NewDownloader()

	// Create context with timeout
	ctx := context.Background()

	err := downloader.DownloadAll(ctx, packagesDir)
	if err != nil {
		return fmt.Errorf("failed to download CRDs: %w", err)
	}

	fmt.Println("✓ CRDs downloaded successfully")

	return nil
}

// getEnv retrieves an environment variable or returns a default value.
func getEnv(key, fallback string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}

	return fallback
}

// renderTemplates finds and renders all .tpl files in the packages directory.
func renderTemplates(syncVersions versions.VersionsFile) error {
	walkErr := filepath.Walk(packagesDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if info.IsDir() {
			// Skip node_modules
			if info.Name() == "node_modules" {
				return filepath.SkipDir
			}

			return nil
		}

		if !strings.HasSuffix(path, ".tpl") {
			return nil
		}

		// Determine output path
		var outputPath string
		if before, ok := strings.CutSuffix(path, ".tf.tpl"); ok {
			outputPath = before + ".gen.tf"
		} else {
			outputPath = strings.TrimSuffix(path, ".tpl")
		}

		// Prepare template data
		data := templating.TemplateData{
			Org:        getEnv("ORG", "sumicare"),
			Repository: getEnv("REPO", "docker.io/"),
			Versions:   syncVersions,
		}

		// Render template
		err = templating.RenderTemplateToFile(path, outputPath, data)
		if err != nil {
			return fmt.Errorf("failed to render template %s: %w", path, err)
		}

		return nil
	})
	if walkErr != nil {
		return fmt.Errorf("failed to walk packages directory %q: %w", packagesDir, walkErr)
	}

	return nil
}

// syncVersions syncs the package.json files from the existing versions.json.
func syncVersions() error {
	syncVersions, err := versions.ReadVersionsFile()
	if err != nil {
		return fmt.Errorf("failed to read versions file: %w", err)
	}

	missingProjects := versions.FetchMissingVersions(syncVersions)
	if len(missingProjects) > 0 {
		err := versions.UpdateVersionsJSON(syncVersions)
		if err != nil {
			return fmt.Errorf("failed to update versions.json: %w", err)
		}
	}

	updated, err := versions.UpdatePackageJSONFiles(syncVersions, packagesDir)
	if err != nil {
		return fmt.Errorf("failed to update package.json files: %w", err)
	}

	// Render templates
	err = renderTemplates(syncVersions)
	if err != nil {
		return fmt.Errorf("failed to render templates: %w", err)
	}

	if len(missingProjects) > 0 {
		fmt.Printf("\nversions.json: Added %d missing projects\n", len(missingProjects))
	}

	printVersionsJSONSummary(updated)

	return nil
}
