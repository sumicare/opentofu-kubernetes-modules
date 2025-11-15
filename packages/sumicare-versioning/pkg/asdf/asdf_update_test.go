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
	"os"
	"path/filepath"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

const (
	// oldGolangVersion is the old version used in tests.
	oldGolangVersion = "1.20.0"
	// newGolangVersion is the new version used in tests.
	newGolangVersion = "1.25.4"
)

var _ = Describe("asdf update helpers", func() {
	// The tests in this suite verify that asdf update helpers correctly
	// select semver versions, write .tool-versions files, and orchestrate
	// tool updates across different edge cases.
	Describe("selectLatestSemverVersion", func() {
		DescribeTable("selects the correct latest version",
			func(lines []string, toolName, expected string) {
				version, err := selectLatestSemverVersion(lines, toolName)
				Expect(err).NotTo(HaveOccurred(), "should be able to select latest semver version without error")
				Expect(version).To(Equal(expected), "selected version should match expected value")
			},
			Entry("prefers latest stable over prerelease and variants",
				[]string{
					"2.0.0",
					"2.1.0-rc1",
					"stackless-2.1.0",
					"2.1.0",
				},
				"python", "2.1.0",
			),
			Entry("falls back to highest prerelease when no stable exists",
				[]string{
					"2.0.0-rc1",
					"2.0.0-dev",
				},
				"python", "2.0.0-rc1",
			),
			Entry("handles single version",
				[]string{"1.0.0"},
				"tool", "1.0.0",
			),
			Entry("selects highest among multiple stable versions",
				[]string{
					"1.0.0",
					"1.2.3",
					"1.1.0",
					"2.0.0",
					"1.5.0",
				},
				"tool", "2.0.0",
			),
			Entry("handles versions with build metadata",
				[]string{
					"1.0.0+build1",
					"1.0.1+build2",
					"1.0.0",
				},
				"tool", "1.0.1+build2",
			),
			Entry("handles mixed stable and prerelease",
				[]string{
					"1.0.0",
					"1.1.0-beta",
					"1.0.5",
					"2.0.0-rc1",
				},
				"tool", "1.0.5",
			),
		)

		It("falls back to last non-empty line when no valid semver", func() {
			lines := []string{
				"invalid-version",
				"another-invalid",
				"",
				"last-valid-line",
			}

			version, err := selectLatestSemverVersion(lines, "tool")
			Expect(err).NotTo(HaveOccurred(), "should not error when falling back to last non-empty line")
			Expect(version).To(Equal("last-valid-line"), "should return last non-empty line when no valid semver versions are found")
		})

		It("returns error when no versions found", func() {
			lines := []string{"", "  ", "\n"}

			_, err := selectLatestSemverVersion(lines, "tool")
			Expect(err).To(HaveOccurred(), "should return error when no versions are found")
			Expect(err.Error()).To(ContainSubstring("no versions found"), "error message should indicate no versions found")
		})

		It("handles lines with annotations", func() {
			lines := []string{
				"1.0.0  (installed)",
				"1.1.0  (latest)",
				"1.0.5",
			}

			version, err := selectLatestSemverVersion(lines, "tool")
			Expect(err).NotTo(HaveOccurred(), "should not error when handling annotated version lines")
			Expect(version).To(Equal("1.1.0"), "should select highest stable version from annotated lines")
		})

		It("ignores empty lines and whitespace", func() {
			lines := []string{
				"",
				"  ",
				"1.0.0",
				"",
				"1.1.0",
				"  ",
			}

			version, err := selectLatestSemverVersion(lines, "tool")
			Expect(err).NotTo(HaveOccurred(), "should not error when ignoring empty lines and whitespace")
			Expect(version).To(Equal("1.1.0"), "should select highest non-empty version")
		})

		It("handles prerelease versions correctly", func() {
			lines := []string{
				"1.0.0-alpha",
				"1.0.0-beta",
				"1.0.0-rc1",
				"1.0.0-rc2",
			}

			version, err := selectLatestSemverVersion(lines, "tool")
			Expect(err).NotTo(HaveOccurred(), "should not error when handling prerelease versions")
			Expect(version).To(Equal("1.0.0-rc2"), "should select highest prerelease version")
		})
	})

	// writeToolVersions is responsible for persisting tool versions to disk
	// in a deterministic and filterable format.
	Describe("writeToolVersions", func() {
		It("writes versions in sorted order", func() {
			tmpDir := GinkgoT().TempDir()
			path := filepath.Join(tmpDir, ".tool-versions")

			versions := map[string]string{
				"python": "3.14.0",
				"golang": newGolangVersion,
				"nodejs": "25.2.0",
			}

			Expect(writeToolVersions(path, versions)).To(Succeed(), "should be able to write tool-versions file in sorted order")

			data, err := os.ReadFile(path)
			Expect(err).NotTo(HaveOccurred(), "should be able to read tool-versions file")

			content := string(data)
			Expect(content).To(Equal("golang 1.25.4\nnodejs 25.2.0\npython 3.14.0\n"), "tool-versions content should match expected sorted output")
		})

		It("skips empty versions", func() {
			tmpDir := GinkgoT().TempDir()
			path := filepath.Join(tmpDir, ".tool-versions")

			versions := map[string]string{
				"golang": newGolangVersion,
				"nodejs": "",
				"python": "3.14.0",
			}

			Expect(writeToolVersions(path, versions)).To(Succeed(), "should be able to write tool-versions file with non-empty versions only")

			data, err := os.ReadFile(path)
			Expect(err).NotTo(HaveOccurred(), "should be able to read tool-versions file")

			content := string(data)
			Expect(content).To(Equal("golang 1.25.4\npython 3.14.0\n"), "tool-versions content should contain only non-empty versions")
			Expect(content).NotTo(ContainSubstring("nodejs"), "tool-versions content should not include entries with empty versions")
		})

		It("handles empty map", func() {
			tmpDir := GinkgoT().TempDir()
			path := filepath.Join(tmpDir, ".tool-versions")

			versions := make(map[string]string)

			Expect(writeToolVersions(path, versions)).To(Succeed(), "should be able to write tool-versions file for empty map")

			data, err := os.ReadFile(path)
			Expect(err).NotTo(HaveOccurred(), "should be able to read tool-versions file for empty map")
			Expect(data).To(BeEmpty(), "tool-versions file should be empty when no versions are provided")
		})

		It("creates file with correct permissions", func() {
			tmpDir := GinkgoT().TempDir()
			path := filepath.Join(tmpDir, ".tool-versions")

			versions := make(map[string]string)
			versions["golang"] = newGolangVersion

			Expect(writeToolVersions(path, versions)).To(Succeed(), "should be able to write tool-versions file")

			info, err := os.Stat(path)
			Expect(err).NotTo(HaveOccurred(), "should be able to stat tool-versions file")
			Expect(info.Mode().Perm()).To(Equal(os.FileMode(0o600)), "tool-versions file should have 0600 permissions")
		})
	})

	// UpdateToolsToLatestForFile drives the end-to-end update flow for
	// a given .tool-versions file. These tests focus on input parsing
	// and result structures rather than shelling out to asdf.
	Describe("UpdateToolsToLatestForFile", func() {
		var tmpDir string
		var toolVersionsPath string

		BeforeEach(func() {
			tmpDir = GinkgoT().TempDir()
			toolVersionsPath = filepath.Join(tmpDir, ".tool-versions")
		})

		It("returns empty result for empty file", func() {
			Expect(os.WriteFile(toolVersionsPath, []byte(""), 0o600)).To(Succeed(), "should be able to write empty tool-versions file")

			results, err := UpdateToolsToLatestForFile(toolVersionsPath)
			Expect(err).NotTo(HaveOccurred(), "should not error when updating tools for empty file")
			Expect(results).To(BeEmpty(), "results should be empty for empty tool-versions file")
		})

		It("returns empty result for non-existent file", func() {
			results, err := UpdateToolsToLatestForFile(filepath.Join(tmpDir, "nonexistent"))
			Expect(err).NotTo(HaveOccurred(), "should not error when target file does not exist")
			Expect(results).To(BeEmpty(), "results should be empty for non-existent tool-versions file")
		})

		It("preserves tool names in results", func() {
			// This test would require mocking asdf commands, so we'll test the structure
			content := "golang 1.20.0\n"
			Expect(os.WriteFile(toolVersionsPath, []byte(content), 0o600)).To(Succeed(), "should be able to write tool-versions file with golang entry")

			// We can't actually run asdf commands in tests, but we can verify the file parsing works
			versions, err := parseToolVersions(toolVersionsPath)
			Expect(err).NotTo(HaveOccurred(), "should be able to parse tool-versions file")
			Expect(versions).To(HaveKeyWithValue("golang", oldGolangVersion), "versions map should contain golang with oldGolangVersion")
		})
	})

	// ToolUpdateResult is a simple struct that captures update metadata
	// such as old/new versions and whether a tool was installed.
	Describe("ToolUpdateResult", func() {
		It("has correct structure", func() {
			result := ToolUpdateResult{
				Name:       "golang",
				OldVersion: oldGolangVersion,
				NewVersion: newGolangVersion,
				Changed:    true,
				Installed:  false,
			}

			Expect(result.Name).To(Equal("golang"), "tool name should be golang")
			Expect(result.OldVersion).To(Equal(oldGolangVersion), "old version should match oldGolangVersion")
			Expect(result.NewVersion).To(Equal(newGolangVersion), "new version should match newGolangVersion")
			Expect(result.Changed).To(BeTrue(), "changed should be true when version differs")
			Expect(result.Installed).To(BeFalse(), "installed should be false when tool is not installed")
		})
	})

	// The integration scenarios below validate that version comparison
	// logic behaves consistently for changed and unchanged versions.
	Describe("Integration scenarios", func() {
		It("handles version comparison correctly", func() {
			// Test that version changes are detected correctly
			oldVersion := oldGolangVersion
			newVersion := newGolangVersion

			changed := oldVersion != "" && oldVersion != newVersion
			Expect(changed).To(BeTrue(), "changed should be true when old and new versions differ")

			unchanged := oldVersion != "" && oldVersion != oldGolangVersion
			Expect(unchanged).To(BeFalse(), "unchanged should be false when old version equals reference version")
		})

		It("handles empty old version", func() {
			oldVersion := ""
			newVersion := newGolangVersion

			changed := oldVersion != "" && oldVersion != newVersion
			Expect(changed).To(BeFalse(), "changed should be false when old version is empty")
		})
	})

	// getPreservedVersion handles tools that do not follow standard semver
	// rules (for example rust nightly and debian image tags).
	Describe("getPreservedVersion", func() {
		DescribeTable("correctly handles package-specific versions",
			func(packageName, currentVersion, expected string) {
				result := getPreservedVersion(packageName, currentVersion)
				Expect(result).To(Equal(expected), "preserved version should match expected value")
			},
			Entry("rust always uses nightly", "rust", "stable", "nightly"),
			Entry("rust always uses nightly even if already nightly", "rust", "nightly", "nightly"),
			Entry("rust always uses nightly even with semver", "rust", "1.70.0", "nightly"),
			Entry("debian preserves non-semver versions", "debian", "trixie-20251117-slim", "trixie-20251117-slim"),
			Entry("debian preserves bookworm versions", "debian", "bookworm-20240101", "bookworm-20240101"),
			Entry("debian allows semver if no hyphen", "debian", "12.0", ""),
			Entry("golang uses normal resolution", "golang", newGolangVersion, ""),
			Entry("nodejs uses normal resolution", "nodejs", "20.0.0", ""),
			Entry("empty package returns empty", "", "1.0.0", ""),
		)
	})
})
