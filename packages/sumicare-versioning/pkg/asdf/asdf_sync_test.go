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
	"errors"
	"os"
	"path/filepath"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

// These tests exercise the public asdf sync helpers end-to-end.
// Each scenario uses isolated temporary directories and environment
// overrides so that behavior does not depend on the caller's machine.
// The goal is to keep regressions visible when changing filesystem
// helpers or .tool-versions parsing logic.
//
// When adding new helpers in this package, prefer extending this test
// suite so behavior is covered before and after refactors.
// This extra context also documents how the sumicare-versioning CLI depends
// on these helpers for correct interaction with the local filesystem.
const (
	// golangTool is the name of the golang tool in asdf.
	golangTool = "golang"
)

var _ = Describe("asdf sync helpers", func() {
	// The tests in this suite validate the behavior of the asdf sync helpers.
	// Each Describe block focuses on a single responsibility to keep failures easy to interpret.
	Describe("parseToolVersions", func() {
		It("parses .tool-versions content and ignores comments", func() {
			tmpDir := GinkgoT().TempDir()
			toolVersionsPath := filepath.Join(tmpDir, ".tool-versions")

			content := `# Comment line
golang 1.25.4
nodejs 25.2.0

# Another comment
python 3.14.0`

			Expect(os.WriteFile(toolVersionsPath, []byte(content), 0o600)).To(Succeed(), "should be able to write tool-versions file")

			versions, err := parseToolVersions(toolVersionsPath)
			Expect(err).NotTo(HaveOccurred(), "should be able to parse tool-versions file")
			Expect(versions).To(HaveKeyWithValue(golangTool, "1.25.4"), "should have golang version 1.25.4")
			Expect(versions).To(HaveKeyWithValue("nodejs", "25.2.0"), "should have nodejs version 25.2.0")
			Expect(versions).To(HaveKeyWithValue("python", "3.14.0"), "should have python version 3.14.0")
		})

		It("returns empty map for non-existent file", func() {
			versions, err := parseToolVersions("/nonexistent/path/.tool-versions")
			Expect(err).NotTo(HaveOccurred(), "should not error for non-existent file")
			Expect(versions).To(BeEmpty(), "should return empty map for non-existent file")
		})

		It("handles empty file", func() {
			tmpDir := GinkgoT().TempDir()
			toolVersionsPath := filepath.Join(tmpDir, ".tool-versions")
			Expect(os.WriteFile(toolVersionsPath, []byte(""), 0o600)).To(Succeed(), "should be able to write empty file")

			versions, err := parseToolVersions(toolVersionsPath)
			Expect(err).NotTo(HaveOccurred(), "should not error for empty file")
			Expect(versions).To(BeEmpty(), "should return empty map for empty file")
		})

		It("ignores malformed lines", func() {
			tmpDir := GinkgoT().TempDir()
			toolVersionsPath := filepath.Join(tmpDir, ".tool-versions")

			content := `golang 1.25.4
malformed-line
nodejs 25.2.0
single-field`

			Expect(os.WriteFile(toolVersionsPath, []byte(content), 0o600)).To(Succeed(), "should be able to write malformed content file")

			versions, err := parseToolVersions(toolVersionsPath)
			Expect(err).NotTo(HaveOccurred(), "should not error for malformed content")
			Expect(versions).To(HaveLen(2), "should parse 2 valid versions from malformed content")
			Expect(versions).To(HaveKeyWithValue(golangTool, "1.25.4"), "should have golang version 1.25.4")
			Expect(versions).To(HaveKeyWithValue("nodejs", "25.2.0"), "should have nodejs version 25.2.0")
		})
	})

	// GetAsdfVersions reads versions from the root .tool-versions file.
	// These tests ensure both existing and non-existent file scenarios are handled correctly.
	Describe("GetAsdfVersions", func() {
		It("uses the current directory .tool-versions file", func() {
			originalDir, err := os.Getwd()
			Expect(err).NotTo(HaveOccurred(), "should be able to get current working directory")

			tmpDir := GinkgoT().TempDir()
			DeferCleanup(func() {
				Expect(os.Chdir(originalDir)).To(Succeed(), "should be able to change back to original directory")
			})

			Expect(os.Chdir(tmpDir)).To(Succeed(), "should be able to change to temp directory")

			content := "golang 1.25.4\nnodejs 25.2.0\n"
			Expect(os.WriteFile(toolVersionsFile, []byte(content), 0o600)).To(Succeed(), "should be able to write tool-versions file")

			versions := GetAsdfVersions()
			Expect(versions).To(HaveLen(2), "should have 2 versions")
			Expect(versions).To(HaveKeyWithValue(golangTool, "1.25.4"), "should have golang version 1.25.4")
			Expect(versions).To(HaveKeyWithValue("nodejs", "25.2.0"), "should have nodejs version 25.2.0")
		})

		It("returns empty map when file doesn't exist", func() {
			originalDir, err := os.Getwd()
			Expect(err).NotTo(HaveOccurred(), "should be able to get current working directory")

			tmpDir := GinkgoT().TempDir()
			DeferCleanup(func() {
				Expect(os.Chdir(originalDir)).To(Succeed(), "should be able to change back to original directory")
			})

			Expect(os.Chdir(tmpDir)).To(Succeed(), "should be able to change to temp directory")

			versions := GetAsdfVersions()
			Expect(versions).To(BeEmpty(), "should return empty map when file doesn't exist")
		})
	})

	// GetAsdfVersionsForFile allows callers to specify an explicit tool-versions path.
	// The tests below confirm we correctly parse and return values from that file.
	Describe("GetAsdfVersionsForFile", func() {
		It("parses the specified file", func() {
			tmpDir := GinkgoT().TempDir()
			customPath := filepath.Join(tmpDir, "custom.tool-versions")

			content := "golang 1.25.4\npython 3.14.0\n"
			Expect(os.WriteFile(customPath, []byte(content), 0o600)).To(Succeed(), "should be able to write custom tool-versions file")

			versions := GetAsdfVersionsForFile(customPath)
			Expect(versions).To(HaveLen(2), "should have 2 versions")
			Expect(versions).To(HaveKeyWithValue(golangTool, "1.25.4"), "should have golang version 1.25.4")
			Expect(versions).To(HaveKeyWithValue("python", "3.14.0"), "should have python version 3.14.0")
		})
	})

	// GetVersions implements the versions.VersionFetcher contract for asdf-managed tools.
	// These tests assert correct behavior for both existing and missing plugins.
	Describe("GetVersions", func() {
		BeforeEach(func() {
			originalDir, err := os.Getwd()
			Expect(err).NotTo(HaveOccurred(), "should be able to get current working directory")

			tmpDir := GinkgoT().TempDir()
			Expect(os.Chdir(tmpDir)).To(Succeed(), "should be able to change to temp directory")

			DeferCleanup(func() {
				Expect(os.Chdir(originalDir)).To(Succeed(), "should be able to change back to original directory")
			})

			content := "golang 1.25.4\n"
			Expect(os.WriteFile(toolVersionsFile, []byte(content), 0o600)).To(Succeed(), "should be able to write tool-versions file")
		})

		DescribeTable("returns versions from .tool-versions", func(name string, expectError bool, expectedVersion string) {
			versions, err := GetVersions(name)

			if expectError {
				Expect(err).To(HaveOccurred(), "should return error when expected")
				Expect(versions).To(BeNil(), "versions should be nil when error occurs")
			} else {
				Expect(err).NotTo(HaveOccurred(), "should not return error when not expected")
				Expect(versions).To(HaveLen(1), "should have 1 version")
				Expect(versions[0]).To(Equal(expectedVersion), "version should match expected")
			}
		},
			Entry("existing plugin", golangTool, false, "1.25.4"),
			Entry("missing plugin", "python", true, ""),
		)
	})

	// InstallPlugins verifies that required asdf plugins are present before updates run.
	// The tests cover missing plugins, pre-installed plugins, and an empty configuration.
	Describe("InstallPlugins", func() {
		It("returns error listing missing plugins when plugins are not installed", func() {
			originalDir, err := os.Getwd()
			Expect(err).NotTo(HaveOccurred(), "should be able to get current working directory")

			originalAsdfDataDir := os.Getenv("ASDF_DATA_DIR")

			tmpDir := GinkgoT().TempDir()
			DeferCleanup(func() {
				Expect(os.Chdir(originalDir)).To(Succeed(), "should be able to change back to original directory")

				if originalAsdfDataDir == "" {
					Expect(os.Unsetenv("ASDF_DATA_DIR")).To(Succeed(), "should be able to unset ASDF_DATA_DIR")
				} else {
					Expect(os.Setenv("ASDF_DATA_DIR", originalAsdfDataDir)).To(Succeed(), "should be able to restore ASDF_DATA_DIR")
				}
			})

			Expect(os.Chdir(tmpDir)).To(Succeed(), "should be able to change to temp directory")

			asdfDataDir := filepath.Join(tmpDir, "asdf-data")
			Expect(os.Setenv("ASDF_DATA_DIR", asdfDataDir)).To(Succeed(), "should be able to set ASDF_DATA_DIR")

			pluginName := golangTool
			toolVersionsContent := pluginName + " 1.25.4\n"
			Expect(os.WriteFile(toolVersionsFile, []byte(toolVersionsContent), defaultFilePermission600)).To(Succeed(), "should be able to write tool-versions file")

			err = InstallPlugins()
			Expect(err).To(HaveOccurred(), "should return error when plugins are missing")
			Expect(errors.Is(err, ErrPluginNotFound)).To(BeTrue(), "error should wrap ErrPluginNotFound when plugins are missing")
		})

		It("succeeds when plugins already exist in asdf plugins directory", func() {
			originalDir, err := os.Getwd()
			Expect(err).NotTo(HaveOccurred(), "should be able to get current working directory")

			originalAsdfDataDir := os.Getenv("ASDF_DATA_DIR")

			tmpDir := GinkgoT().TempDir()
			DeferCleanup(func() {
				Expect(os.Chdir(originalDir)).To(Succeed(), "should be able to change back to original directory")
				if originalAsdfDataDir == "" {
					Expect(os.Unsetenv("ASDF_DATA_DIR")).To(Succeed(), "should be able to unset ASDF_DATA_DIR")
				} else {
					Expect(os.Setenv("ASDF_DATA_DIR", originalAsdfDataDir)).To(Succeed(), "should be able to restore ASDF_DATA_DIR")
				}
			})

			Expect(os.Chdir(tmpDir)).To(Succeed(), "should be able to change to temp directory")

			asdfDataDir := filepath.Join(tmpDir, "asdf-data")
			Expect(os.Setenv("ASDF_DATA_DIR", asdfDataDir)).To(Succeed(), "should be able to set ASDF_DATA_DIR")

			pluginName := golangTool
			pluginDir := filepath.Join(asdfDataDir, "plugins", pluginName)
			Expect(os.MkdirAll(pluginDir, 0o755)).To(Succeed(), "should be able to create plugin directory")

			toolVersionsContent := pluginName + " 1.25.4\n"
			Expect(os.WriteFile(toolVersionsFile, []byte(toolVersionsContent), 0o600)).To(Succeed(), "should be able to write tool-versions file")

			Expect(InstallPlugins()).To(Succeed(), "should succeed when all plugins already exist")
		})

		It("handles empty .tool-versions file", func() {
			originalDir, err := os.Getwd()
			Expect(err).NotTo(HaveOccurred(), "should be able to get current working directory")

			tmpDir := GinkgoT().TempDir()
			DeferCleanup(func() {
				Expect(os.Chdir(originalDir)).To(Succeed(), "should be able to change back to original directory")
			})

			Expect(os.Chdir(tmpDir)).To(Succeed(), "should be able to change to temp directory")
			Expect(os.WriteFile(toolVersionsFile, []byte(""), 0o600)).To(Succeed(), "should be able to write empty tool-versions file")

			Expect(InstallPlugins()).To(Succeed(), "should be able to install plugins")
		})
	})

	// SyncToolVersionsFiles propagates versions from the root .tool-versions file
	// into additional tool-versions-style files while preserving comments and layout.
	Describe("SyncToolVersionsFiles", func() {
		var tmpDir string
		var rootToolVersions string

		BeforeEach(func() {
			originalDir, err := os.Getwd()
			Expect(err).NotTo(HaveOccurred(), "should be able to get current working directory")

			tmpDir = GinkgoT().TempDir()
			Expect(os.Chdir(tmpDir)).To(Succeed(), "should be able to change to temp directory")

			DeferCleanup(func() {
				Expect(os.Chdir(originalDir)).To(Succeed(), "should be able to change back to original directory")
			})

			rootToolVersions = "golang 1.25.4\nnodejs 25.2.0\npython 3.14.0\n"
			Expect(os.WriteFile(toolVersionsFile, []byte(rootToolVersions), 0o600)).To(Succeed(), "should be able to write root tool-versions file")
		})

		It("syncs versions from root .tool-versions to target file", func() {
			targetPath := filepath.Join(tmpDir, "target.tool-versions")
			targetContent := "golang 1.20.0\npython 3.11.0\n"
			Expect(os.WriteFile(targetPath, []byte(targetContent), 0o600)).To(Succeed(), "should be able to write target tool-versions file")

			Expect(SyncToolVersionsFiles(targetPath)).To(Succeed(), "should be able to sync tool versions files")

			data, err := os.ReadFile(targetPath)
			Expect(err).NotTo(HaveOccurred(), "should be able to read target file")
			content := string(data)

			Expect(content).To(ContainSubstring("golang 1.25.4"), "should contain updated golang version")
			Expect(content).To(ContainSubstring("python 3.14.0"), "should contain updated python version")
			Expect(content).NotTo(ContainSubstring("1.20.0"), "should not contain old golang version")
			Expect(content).NotTo(ContainSubstring("3.11.0"), "should not contain old python version")
		})

		It("ignores tools not in root .tool-versions", func() {
			targetPath := filepath.Join(tmpDir, "target.tool-versions")
			targetContent := "golang 1.20.0\nruby 3.2.0\n"
			Expect(os.WriteFile(targetPath, []byte(targetContent), 0o600)).To(Succeed(), "should be able to write target tool-versions file")

			Expect(SyncToolVersionsFiles(targetPath)).To(Succeed(), "should be able to sync tool versions files")

			data, err := os.ReadFile(targetPath)
			Expect(err).NotTo(HaveOccurred(), "should be able to read target file")
			content := string(data)

			Expect(content).To(ContainSubstring("golang 1.25.4"), "should contain updated golang version")
			Expect(content).To(ContainSubstring("ruby 3.2.0"), "should contain unchanged ruby version")
		})

		It("handles non-existent target file gracefully", func() {
			targetPath := filepath.Join(tmpDir, "nonexistent.tool-versions")
			Expect(SyncToolVersionsFiles(targetPath)).To(Succeed(), "should be able to sync non-existent file gracefully")
		})

		It("handles multiple files", func() {
			target1 := filepath.Join(tmpDir, "target1.tool-versions")
			target2 := filepath.Join(tmpDir, "target2.tool-versions")

			Expect(os.WriteFile(target1, []byte("golang 1.20.0\n"), 0o600)).To(Succeed(), "should be able to write target1 file")
			Expect(os.WriteFile(target2, []byte("python 3.11.0\n"), 0o600)).To(Succeed(), "should be able to write target2 file")

			Expect(SyncToolVersionsFiles(target1, target2)).To(Succeed(), "should be able to sync multiple files")

			data1, err := os.ReadFile(target1)
			Expect(err).NotTo(HaveOccurred(), "should be able to read target1 file")
			Expect(string(data1)).To(ContainSubstring("golang 1.25.4"), "target1 should contain updated golang version")

			data2, err := os.ReadFile(target2)
			Expect(err).NotTo(HaveOccurred(), "should be able to read target2 file")
			Expect(string(data2)).To(ContainSubstring("python 3.14.0"), "target2 should contain updated python version")
		})

		It("handles empty path list", func() {
			Expect(SyncToolVersionsFiles()).To(Succeed(), "should succeed with empty path list")
		})
	})

	// copyDir is a small filesystem helper for recursive directory copies.
	// These tests exercise both the happy path and error conditions.
	Describe("copyDir", func() {
		It("recursively copies directory tree", func() {
			tmpDir := GinkgoT().TempDir()
			srcDir := filepath.Join(tmpDir, "src")
			dstDir := filepath.Join(tmpDir, "dst")

			// Create source structure
			Expect(os.MkdirAll(filepath.Join(srcDir, "subdir"), defaultDirectoryPermission755)).To(Succeed(), "should be able to create source subdirectory")
			Expect(os.WriteFile(filepath.Join(srcDir, "file1.txt"), []byte("content1"), defaultFilePermission600)).To(Succeed(), "should be able to write source file1")
			Expect(os.WriteFile(filepath.Join(srcDir, "subdir", "file2.txt"), []byte("content2"), defaultFilePermission600)).To(Succeed(), "should be able to write source file2")

			Expect(copyDir(srcDir, dstDir)).To(Succeed(), "should be able to copy directory tree")

			Expect(filepath.Join(dstDir, "file1.txt")).To(BeAnExistingFile(), "destination should contain copied file1")
			Expect(filepath.Join(dstDir, "subdir", "file2.txt")).To(BeAnExistingFile(), "destination should contain copied file2")

			data, err := os.ReadFile(filepath.Join(dstDir, "file1.txt"))
			Expect(err).NotTo(HaveOccurred(), "should be able to read copied file1")
			Expect(string(data)).To(Equal("content1"), "copied file1 content should match source")
		})

		It("returns error for non-directory source", func() {
			tmpDir := GinkgoT().TempDir()
			srcFile := filepath.Join(tmpDir, "file.txt")
			dstDir := filepath.Join(tmpDir, "dst")

			Expect(os.WriteFile(srcFile, []byte("content"), defaultFilePermission600)).To(Succeed(), "should be able to write source file")

			err := copyDir(srcFile, dstDir)
			Expect(err).To(HaveOccurred(), "should return error for non-directory source")
			Expect(err.Error()).To(ContainSubstring("not a directory"), "error message should indicate non-directory source")
		})
	})

	// getAsdfDataDir resolves the asdf data directory from environment or defaults.
	// The tests below ensure we respect ASDF_DATA_DIR and fall back to ~/.asdf.
	Describe("getAsdfDataDir", func() {
		It("respects ASDF_DATA_DIR environment variable", func() {
			originalValue := os.Getenv("ASDF_DATA_DIR")
			DeferCleanup(func() {
				if originalValue == "" {
					Expect(os.Unsetenv("ASDF_DATA_DIR")).To(Succeed(), "should be able to unset ASDF_DATA_DIR")
				} else {
					Expect(os.Setenv("ASDF_DATA_DIR", originalValue)).To(Succeed(), "should be able to restore ASDF_DATA_DIR")
				}
			})

			customDir := "/custom/asdf/dir"
			Expect(os.Setenv("ASDF_DATA_DIR", customDir)).To(Succeed(), "should be able to set ASDF_DATA_DIR")

			dataDir, err := getAsdfDataDir()
			Expect(err).NotTo(HaveOccurred(), "should not error when ASDF_DATA_DIR is set")
			Expect(dataDir).To(Equal(customDir), "data directory should match ASDF_DATA_DIR")
		})

		It("defaults to ~/.asdf when ASDF_DATA_DIR is not set", func() {
			originalValue := os.Getenv("ASDF_DATA_DIR")
			DeferCleanup(func() {
				if originalValue == "" {
					Expect(os.Unsetenv("ASDF_DATA_DIR")).To(Succeed(), "should be able to unset ASDF_DATA_DIR")
				} else {
					Expect(os.Setenv("ASDF_DATA_DIR", originalValue)).To(Succeed(), "should be able to restore ASDF_DATA_DIR")
				}
			})

			Expect(os.Unsetenv("ASDF_DATA_DIR")).To(Succeed(), "should be able to unset ASDF_DATA_DIR for test")

			dataDir, err := getAsdfDataDir()
			Expect(err).NotTo(HaveOccurred(), "should not error when ASDF_DATA_DIR is unset")

			homeDir, err := os.UserHomeDir()
			Expect(err).NotTo(HaveOccurred(), "should be able to determine user home directory")
			Expect(dataDir).To(Equal(filepath.Join(homeDir, ".asdf")), "data directory should default to ~/.asdf")
		})
	})
})
