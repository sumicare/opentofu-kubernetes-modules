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

package versions_test

import (
	"encoding/json"
	"os"
	"path/filepath"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	"sumi.care/util/sumicare-versioning/pkg/versions"
)

var _ = Describe("Versions Sync", func() {
	// The Versions Sync suite focuses on reading versions.json and
	// keeping package.json files in sync with the desired versions.
	Describe("ReadVersionsFile", func() {
		type testCase struct {
			fileData       versions.VersionsFile
			expectedValues map[string]string
			setupFile      bool
			expectedEmpty  bool
		}

		DescribeTable("should read versions file correctly",
			func(tc testCase) {
				tmpDir := GinkgoT().TempDir()
				originalDir, err := os.Getwd()
				Expect(err).NotTo(HaveOccurred(), "should be able to get current working directory")
				defer func() {
					Expect(os.Chdir(originalDir)).To(Succeed(), "should be able to change back to original directory")
				}()

				Expect(os.Chdir(tmpDir)).To(Succeed(), "should be able to change to temp directory")

				if tc.setupFile {
					data, err := json.MarshalIndent(tc.fileData, "", "  ")
					Expect(err).NotTo(HaveOccurred(), "should be able to marshal test data")
					Expect(os.WriteFile(versions.VersionsFileName, data, 0o600)).To(Succeed(), "should be able to write versions file")
				}

				vf, err := versions.ReadVersionsFile()
				Expect(err).NotTo(HaveOccurred(), "should be able to read versions file")

				if tc.expectedEmpty {
					Expect(vf).To(BeEmpty(), "versions file should be empty when expected")
				}

				for key, expectedValue := range tc.expectedValues {
					Expect(vf[key]).To(Equal(expectedValue), "version for %s should match expected value", key)
				}
			},
			Entry("file does not exist",
				testCase{
					setupFile:     false,
					expectedEmpty: true,
				},
			),
			Entry("existing versions.json file",
				testCase{
					setupFile: true,
					fileData: versions.VersionsFile{
						"test-project": "1.2.3",
					},
					expectedValues: map[string]string{
						"test-project": "1.2.3",
					},
				},
			),
			Entry("multiple projects",
				testCase{
					setupFile: true,
					fileData: versions.VersionsFile{
						"project-a": "1.0.0",
						"project-b": "2.0.0",
						"project-c": "3.0.0",
					},
					expectedValues: map[string]string{
						"project-a": "1.0.0",
						"project-b": "2.0.0",
						"project-c": "3.0.0",
					},
				},
			),
		)

		It("should handle malformed JSON", func() {
			tmpDir := GinkgoT().TempDir()
			originalDir, err := os.Getwd()
			Expect(err).NotTo(HaveOccurred(), "should be able to get current working directory")
			defer func() {
				Expect(os.Chdir(originalDir)).To(Succeed(), "should be able to change back to original directory")
			}()

			Expect(os.Chdir(tmpDir)).To(Succeed(), "should be able to change to temp directory")
			Expect(os.WriteFile(versions.VersionsFileName, []byte("invalid json"), 0o600)).To(Succeed(), "should be able to write invalid JSON file")

			_, err = versions.ReadVersionsFile()
			Expect(err).To(HaveOccurred(), "should return error for malformed JSON")
		})
	})

	// UpdatePackageJSON updates a single package.json file and returns
	// information about the previous version and whether a change occurred.
	Describe("UpdatePackageJSON", func() {
		type testCase struct {
			initialData    map[string]any
			verifyFields   map[string]any
			newVersion     string
			expectedOld    string
			expectedChange bool
		}

		DescribeTable("should handle version updates correctly",
			func(tc testCase) {
				tmpDir := GinkgoT().TempDir()
				packagePath := filepath.Join(tmpDir, "package.json")

				data, err := json.MarshalIndent(tc.initialData, "", "  ")
				Expect(err).NotTo(HaveOccurred(), "should be able to marshal initial package data")
				Expect(os.WriteFile(packagePath, append(data, '\n'), 0o600)).To(Succeed(), "should be able to write package.json file")

				oldVersion, changed, err := versions.UpdatePackageJSON(packagePath, tc.newVersion)
				Expect(err).NotTo(HaveOccurred(), "should be able to update package version")
				Expect(oldVersion).To(Equal(tc.expectedOld), "old version should match expected value")
				Expect(changed).To(Equal(tc.expectedChange), "change status should match expected value")

				if tc.verifyFields == nil {
					return
				}

				updatedData, err := os.ReadFile(packagePath)
				Expect(err).NotTo(HaveOccurred(), "should be able to read updated package file")

				var pkg map[string]any
				Expect(json.Unmarshal(updatedData, &pkg)).To(Succeed(), "should be able to unmarshal updated package data")

				for key, expectedValue := range tc.verifyFields {
					Expect(pkg[key]).To(Equal(expectedValue), "field %s should match expected value", key)
				}
			},
			Entry("update version and preserve fields",
				testCase{
					initialData: map[string]any{
						"name":        "test-package",
						"version":     "1.0.0",
						"description": "Test package",
					},
					newVersion:     "2.0.0",
					expectedOld:    "1.0.0",
					expectedChange: true,
					verifyFields: map[string]any{
						"version":     "2.0.0",
						"name":        "test-package",
						"description": "Test package",
					},
				},
			),
			Entry("no change when version is the same",
				testCase{
					initialData: map[string]any{
						"name":    "test-package",
						"version": "1.0.0",
					},
					newVersion:     "1.0.0",
					expectedOld:    "1.0.0",
					expectedChange: false,
				},
			),
			Entry("handle missing version field",
				testCase{
					initialData: map[string]any{
						"name": "test-package",
					},
					newVersion:     "1.0.0",
					expectedOld:    "",
					expectedChange: true,
					verifyFields: map[string]any{
						"version": "1.0.0",
						"name":    "test-package",
					},
				},
			),
		)

		testPackageVersionUpdate := func(pkgType, versionField, oldVersion, newVersion string) {
			tmpDir := GinkgoT().TempDir()
			pkgDir := filepath.Join(tmpDir, pkgType)
			Expect(os.MkdirAll(pkgDir, 0o755)).To(Succeed(), "should be able to create package directory")

			packagePath := filepath.Join(pkgDir, "package.json")
			initialData := map[string]any{
				"name":       pkgType + "-package",
				"version":    "1.0.0",
				versionField: oldVersion,
			}

			data, err := json.MarshalIndent(initialData, "", "  ")
			Expect(err).NotTo(HaveOccurred(), "should be able to marshal initial package data")
			Expect(os.WriteFile(packagePath, append(data, '\n'), 0o600)).To(Succeed(), "should be able to write package.json file")

			oldVersion, changed, err := versions.UpdatePackageJSON(packagePath, newVersion)
			Expect(err).NotTo(HaveOccurred(), "should be able to update package version")
			Expect(oldVersion).To(Equal(oldVersion), "old version should match expected value")
			Expect(changed).To(BeTrue(), "change status should match expected value")

			updatedData, err := os.ReadFile(packagePath)
			Expect(err).NotTo(HaveOccurred(), "should be able to read updated package file")

			var pkg map[string]any
			Expect(json.Unmarshal(updatedData, &pkg)).To(Succeed(), "should be able to unmarshal updated package data")

			Expect(pkg["version"]).To(Equal("1.0.0"), "version should match expected value")
			Expect(pkg[versionField]).To(Equal(newVersion), "version field should match expected value")
		}

		It("should update debianVersion for debian package without changing version", func() {
			testPackageVersionUpdate("debian", "debianVersion", "old-debian", "new-debian")
		})

		It("should update minioVersion for storage-minio package without changing version", func() {
			testPackageVersionUpdate("storage-minio", "minioVersion", "old-minio", "new-minio")
		})

		It("should return error for non-existent file", func() {
			_, _, err := versions.UpdatePackageJSON("/nonexistent/package.json", "1.0.0")
			Expect(err).To(HaveOccurred(), "should return error for non-existent file")
		})

		It("should return error for malformed JSON", func() {
			tmpDir := GinkgoT().TempDir()
			packagePath := filepath.Join(tmpDir, "package.json")
			Expect(os.WriteFile(packagePath, []byte("invalid json"), 0o600)).To(Succeed(), "should be able to write invalid JSON file")

			_, _, err := versions.UpdatePackageJSON(packagePath, "1.0.0")
			Expect(err).To(HaveOccurred(), "should return error for malformed JSON")
		})
	})

	// UpdatePackageJSONFiles walks a packages/ tree and applies version
	// changes to all package.json files present for known packages.
	Describe("UpdatePackageJSONFiles", func() {
		It("should update multiple package.json files", func() {
			tmpDir := GinkgoT().TempDir()
			packagesDir := filepath.Join(tmpDir, "packages")

			// Create package directories
			pkg1Dir := filepath.Join(packagesDir, "package-1")
			pkg2Dir := filepath.Join(packagesDir, "package-2")
			Expect(os.MkdirAll(pkg1Dir, 0o755)).To(Succeed(), "should be able to create package-1 directory")
			Expect(os.MkdirAll(pkg2Dir, 0o755)).To(Succeed(), "should be able to create package-2 directory")

			// Create package.json files
			pkg1Data := map[string]any{"name": "package-1", "version": "1.0.0"}
			pkg2Data := map[string]any{"name": "package-2", "version": "2.0.0"}

			data1, err := json.MarshalIndent(pkg1Data, "", "  ")
			Expect(err).NotTo(HaveOccurred(), "should be able to marshal package-1 data")
			data2, err := json.MarshalIndent(pkg2Data, "", "  ")
			Expect(err).NotTo(HaveOccurred(), "should be able to marshal package-2 data")

			Expect(os.WriteFile(filepath.Join(pkg1Dir, "package.json"), append(data1, '\n'), 0o600)).To(Succeed(), "should be able to write package-1.json file")
			Expect(os.WriteFile(filepath.Join(pkg2Dir, "package.json"), append(data2, '\n'), 0o600)).To(Succeed(), "should be able to write package-2.json file")

			// Update versions
			vf := versions.VersionsFile{
				"package-1": "1.5.0",
				"package-2": "2.5.0",
			}

			updated, err := versions.UpdatePackageJSONFiles(vf, packagesDir)
			Expect(err).NotTo(HaveOccurred(), "should be able to update package files")
			Expect(updated).To(HaveLen(2), "should have updated 2 packages")

			Expect(updated["package-1"].Changed).To(BeTrue(), "package-1 should be marked as changed")
			Expect(updated["package-1"].OldVersion).To(Equal("1.0.0"), "package-1 old version should be 1.0.0")
			Expect(updated["package-1"].NewVersion).To(Equal("1.5.0"), "package-1 new version should be 1.5.0")
		})

		It("should skip packages not in versions map", func() {
			tmpDir := GinkgoT().TempDir()
			packagesDir := filepath.Join(tmpDir, "packages")

			pkg1Dir := filepath.Join(packagesDir, "package-1")
			Expect(os.MkdirAll(pkg1Dir, 0o755)).To(Succeed(), "should be able to create package-1 directory")

			pkg1Data := map[string]any{"name": "package-1", "version": "1.0.0"}
			data1, err := json.MarshalIndent(pkg1Data, "", "  ")
			Expect(err).NotTo(HaveOccurred(), "should be able to marshal package-1 data")
			Expect(os.WriteFile(filepath.Join(pkg1Dir, "package.json"), append(data1, '\n'), 0o600)).To(Succeed(), "should be able to write package-1.json file")

			vf := versions.VersionsFile{
				"package-2": "2.0.0",
			}

			updated, err := versions.UpdatePackageJSONFiles(vf, packagesDir)
			Expect(err).NotTo(HaveOccurred(), "should be able to update package files")
			Expect(updated).To(BeEmpty(), "should have no updated packages when package not in versions")
		})

		It("should skip non-directory entries", func() {
			tmpDir := GinkgoT().TempDir()
			packagesDir := filepath.Join(tmpDir, "packages")
			Expect(os.MkdirAll(packagesDir, 0o755)).To(Succeed(), "should be able to create packages directory")

			// Create a file instead of directory
			Expect(os.WriteFile(filepath.Join(packagesDir, "file.txt"), []byte("test"), 0o600)).To(Succeed(), "should be able to create test file")

			vf := versions.VersionsFile{}
			updated, err := versions.UpdatePackageJSONFiles(vf, packagesDir)
			Expect(err).NotTo(HaveOccurred(), "should be able to update package files")
			Expect(updated).To(BeEmpty(), "should have no updated packages when only files exist")
		})

		It("should handle missing package.json gracefully", func() {
			tmpDir := GinkgoT().TempDir()
			packagesDir := filepath.Join(tmpDir, "packages")

			pkg1Dir := filepath.Join(packagesDir, "package-1")
			Expect(os.MkdirAll(pkg1Dir, 0o755)).To(Succeed(), "should be able to create package-1 directory")
			// Don't create package.json

			vf := versions.VersionsFile{
				"package-1": "1.0.0",
			}

			updated, err := versions.UpdatePackageJSONFiles(vf, packagesDir)
			Expect(err).NotTo(HaveOccurred(), "should be able to update package files")
			Expect(updated).To(BeEmpty(), "should have no updated packages when package.json missing")
		})
	})

	// VersionChange is a lightweight struct summarizing how a single
	// package.json entry changed between old and new versions.
	Describe("VersionChange", func() {
		It("should have correct structure", func() {
			change := versions.VersionChange{
				OldVersion: "1.0.0",
				NewVersion: "2.0.0",
				Changed:    true,
			}

			Expect(change.OldVersion).To(Equal("1.0.0"), "old version should be 1.0.0")
			Expect(change.NewVersion).To(Equal("2.0.0"), "new version should be 2.0.0")
			Expect(change.Changed).To(BeTrue(), "changed should be true")
		})
	})
})
