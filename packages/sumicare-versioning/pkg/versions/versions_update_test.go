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

const (
	// testVersion is a sample version string used in tests.
	testVersion = "1.0.0"
)

var _ = Describe("Versions Package", func() {
	// This suite validates the core types and helpers in the versions
	// package, including constants, filesystem navigation, and basic
	// structures used in higher-level update flows.
	Describe("Constants", func() {
		DescribeTable("should have correct constant values",
			func(actual, expected string) {
				Expect(actual).To(Equal(expected), "constant value should match expected")
			},
			Entry("VersionsFileName", versions.VersionsFileName, "versions.json"),
			Entry("ExpectedPackageName", versions.ExpectedPackageName, "@sumicare/terraform-kubernetes-modules"),
			Entry("RootPackageJSONPath", versions.RootPackageJSONPath, "package.json"),
		)
	})

	// VersionsFile Type is a simple map alias that stores per-project
	// version strings. These tests ensure basic map semantics.
	Describe("VersionsFile Type", func() {
		It("should store and retrieve values correctly", func() {
			vf := make(versions.VersionsFile)
			vf["test-project"] = testVersion
			Expect(vf["test-project"]).To(Equal(testVersion), "should store and retrieve version correctly")
		})
	})

	// PackageJSON Type represents the minimal fields we care about from
	// package.json and is used when verifying repository layout.
	Describe("PackageJSON Type", func() {
		It("should store name and version correctly", func() {
			pkg := versions.PackageJSON{
				Name:    "test-package",
				Version: "1.2.3",
			}
			Expect(pkg.Name).To(Equal("test-package"), "package name should be stored correctly")
			Expect(pkg.Version).To(Equal("1.2.3"), "package version should be stored correctly")
		})
	})

	// EnsureCorrectDirectory walks up the filesystem tree until it finds
	// the repository root, identified by the expected package.json name.
	Describe("EnsureCorrectDirectory", func() {
		It("should navigate from subdirectory to root", func() {
			tmpDir := GinkgoT().TempDir()
			rootDir := filepath.Join(tmpDir, "repo")
			Expect(os.MkdirAll(rootDir, 0o755)).To(Succeed(), "should be able to create root directory")

			rootPkg := versions.PackageJSON{
				Name:    versions.ExpectedPackageName,
				Version: testVersion,
			}
			data, err := json.MarshalIndent(rootPkg, "", "  ")
			Expect(err).NotTo(HaveOccurred(), "should be able to marshal root package")
			Expect(os.WriteFile(filepath.Join(rootDir, "package.json"), data, 0o600)).To(Succeed(), "should be able to write root package.json")

			subDir := filepath.Join(rootDir, "packages", "test-package")
			Expect(os.MkdirAll(subDir, 0o755)).To(Succeed(), "should be able to create subdirectory")

			subPkg := versions.PackageJSON{
				Name:    "test-package",
				Version: testVersion,
			}
			data, err = json.MarshalIndent(subPkg, "", "  ")
			Expect(err).NotTo(HaveOccurred(), "should be able to marshal sub package")
			Expect(os.WriteFile(filepath.Join(subDir, "package.json"), data, 0o600)).To(Succeed(), "should be able to write sub package.json")

			originalDir, err := os.Getwd()
			Expect(err).NotTo(HaveOccurred(), "should be able to get current working directory")
			defer func() {
				Expect(os.Chdir(originalDir)).To(Succeed(), "should be able to change back to original directory")
			}()

			Expect(os.Chdir(subDir)).To(Succeed(), "should be able to change to subdirectory")
			Expect(versions.EnsureCorrectDirectory()).To(Succeed(), "should ensure correct directory navigation")

			currentDir, err := os.Getwd()
			Expect(err).NotTo(HaveOccurred(), "should be able to get current working directory")
			Expect(currentDir).To(Equal(rootDir), "should be in root directory after navigation")
		})

		It("should stay in root directory when already there", func() {
			tmpDir := GinkgoT().TempDir()
			rootDir := filepath.Join(tmpDir, "repo")
			Expect(os.MkdirAll(rootDir, 0o755)).To(Succeed(), "should be able to create root directory")

			rootPkg := versions.PackageJSON{
				Name:    versions.ExpectedPackageName,
				Version: testVersion,
			}
			data, err := json.MarshalIndent(rootPkg, "", "  ")
			Expect(err).NotTo(HaveOccurred(), "should be able to marshal root package")
			Expect(os.WriteFile(filepath.Join(rootDir, "package.json"), data, 0o600)).To(Succeed(), "should be able to write root package.json")

			originalDir, err := os.Getwd()
			Expect(err).NotTo(HaveOccurred(), "should be able to get current working directory")
			defer func() {
				Expect(os.Chdir(originalDir)).To(Succeed(), "should be able to change back to original directory")
			}()

			Expect(os.Chdir(rootDir)).To(Succeed(), "should be able to change to root directory")
			Expect(versions.EnsureCorrectDirectory()).To(Succeed(), "should ensure correct directory navigation")

			currentDir, err := os.Getwd()
			Expect(err).NotTo(HaveOccurred(), "should be able to get current working directory")
			Expect(currentDir).To(Equal(rootDir), "should remain in root directory")
		})

		It("should fail when repository is not found", func() {
			tmpDir := GinkgoT().TempDir()
			originalDir, err := os.Getwd()
			Expect(err).NotTo(HaveOccurred(), "should be able to get current working directory")
			defer func() {
				Expect(os.Chdir(originalDir)).To(Succeed(), "should be able to change back to original directory")
			}()

			Expect(os.Chdir(tmpDir)).To(Succeed(), "should be able to change to temp directory")
			err = versions.EnsureCorrectDirectory()
			Expect(err).To(HaveOccurred(), "should return error when repository not found")
		})
	})
})

var _ = Describe("Versions Update", func() {
	// Versions Update focuses on discovering which projects exist and how
	// their versions should be fetched and updated.
	Describe("GetProjectFetchers", func() {
		var fetchers map[string]versions.VersionFetcher

		BeforeEach(func() {
			fetchers = versions.GetProjectFetchers()
		})

		It("should return non-empty map", func() {
			Expect(fetchers).NotTo(BeEmpty(), "fetchers should not be empty")
		})

		DescribeTable("should contain known projects",
			func(project string) {
				Expect(fetchers).To(HaveKey(project), "fetchers should contain key for "+project)
			},
			Entry("compute-keda", "compute-keda"),
			Entry("compute-descheduler", "compute-descheduler"),
			Entry("observability-grafana", "observability-grafana"),
			Entry("security-cert-manager", "security-cert-manager"),
			Entry("debian", "debian"),
			Entry("storage-minio", "storage-minio"),
			Entry("networking-calico", "networking-calico"),
			Entry("gitops-argo-cd", "gitops-argo-cd"),
		)

		It("should have function values for all projects", func() {
			for projectName, fetcher := range fetchers {
				Expect(fetcher).NotTo(BeNil(), "fetcher for %s should not be nil", projectName)
			}
		})

		It("should have consistent count", func() {
			// Verify the count is stable
			count1 := len(versions.GetProjectFetchers())
			count2 := len(versions.GetProjectFetchers())
			Expect(count1).To(Equal(count2), "GetProjectFetchers should return consistent count")
		})
	})

	// FindMissingProjects reports which projects do not yet have entries
	// in the versions file so callers can fetch and persist them.
	Describe("FindMissingProjects", func() {
		type testCase struct {
			versions versions.VersionsFile
			wantLen  int
		}

		DescribeTable("should find missing projects correctly",
			func(tc testCase) {
				missing := versions.FindMissingProjects(tc.versions)
				Expect(missing).To(HaveLen(tc.wantLen), "should find correct number of missing projects")
			},
			Entry("empty versions",
				testCase{
					versions: make(versions.VersionsFile),
					wantLen:  len(versions.GetProjectFetchers()),
				},
			),
			Entry("some versions present",
				testCase{
					versions: versions.VersionsFile{
						"compute-keda": testVersion,
					},
					wantLen: len(versions.GetProjectFetchers()) - 1,
				},
			),
			Entry("all versions present",
				testCase{
					versions: func() versions.VersionsFile {
						vf := make(versions.VersionsFile)
						for project := range versions.GetProjectFetchers() {
							vf[project] = testVersion
						}

						return vf
					}(),
					wantLen: 0,
				},
			),
			Entry("multiple versions present",
				testCase{
					versions: versions.VersionsFile{
						"compute-keda":  testVersion,
						"debian":        "12.0.0",
						"storage-minio": "2024.1.1",
					},
					wantLen: len(versions.GetProjectFetchers()) - 3,
				},
			),
		)

		It("should return empty slice when all projects have versions", func() {
			vf := make(versions.VersionsFile)
			for project := range versions.GetProjectFetchers() {
				vf[project] = testVersion
			}

			missing := versions.FindMissingProjects(vf)
			Expect(missing).To(BeEmpty(), "should have no missing projects when all present")
		})

		It("should not modify input versions map", func() {
			original := versions.VersionsFile{
				"compute-keda": testVersion,
			}

			_ = versions.FindMissingProjects(original)

			Expect(original).To(HaveLen(1), "input versions map should not be modified")
			Expect(original["compute-keda"]).To(Equal(testVersion), "original version should be preserved")
		})
	})

	// FetchMissingVersions fills in missing entries in a VersionsFile by
	// calling the appropriate project-specific fetchers.
	Describe("FetchMissingVersions", func() {
		It("should not modify existing versions when all present", func() {
			vf := make(versions.VersionsFile)
			for project := range versions.GetProjectFetchers() {
				vf[project] = testVersion
			}

			originalLen := len(vf)
			missing := versions.FetchMissingVersions(vf)

			Expect(missing).To(BeEmpty(), "should have no missing versions when all present")
			Expect(vf).To(HaveLen(originalLen), "versions file should not change size")
		})
	})

	// UpdateVersionsJSON persists a VersionsFile to disk, merging with any
	// existing data and ensuring stable JSON structure and permissions.
	Describe("UpdateVersionsJSON", func() {
		It("should create versions.json with new versions", func() {
			tmpDir := GinkgoT().TempDir()
			originalDir, err := os.Getwd()
			Expect(err).NotTo(HaveOccurred(), "should be able to get current working directory")
			defer func() {
				Expect(os.Chdir(originalDir)).To(Succeed(), "should be able to change back to original directory")
			}()

			Expect(os.Chdir(tmpDir)).To(Succeed(), "should be able to change to temp directory")

			vf := versions.VersionsFile{
				"project-a": testVersion,
				"project-b": "2.0.0",
			}

			Expect(versions.UpdateVersionsJSON(vf)).To(Succeed(), "should be able to update versions JSON")

			data, err := os.ReadFile(versions.VersionsFileName)
			Expect(err).NotTo(HaveOccurred(), "should be able to read versions file")

			var result versions.VersionsFile
			Expect(json.Unmarshal(data, &result)).To(Succeed(), "should be able to unmarshal versions file")
			Expect(result["project-a"]).To(Equal(testVersion), "project-a version should be correct")
			Expect(result["project-b"]).To(Equal("2.0.0"), "project-b version should be correct")
		})

		It("should merge with existing versions", func() {
			tmpDir := GinkgoT().TempDir()
			originalDir, err := os.Getwd()
			Expect(err).NotTo(HaveOccurred(), "should be able to get current working directory")
			defer func() {
				Expect(os.Chdir(originalDir)).To(Succeed(), "should be able to change back to original directory")
			}()

			Expect(os.Chdir(tmpDir)).To(Succeed(), "should be able to change to temp directory")

			// Create initial versions
			vf := versions.VersionsFile{
				"project-a": testVersion,
				"project-b": "2.0.0",
			}
			Expect(versions.UpdateVersionsJSON(vf)).To(Succeed(), "should be able to update initial versions")

			// Merge new versions
			vf2 := versions.VersionsFile{
				"project-c": "3.0.0",
			}
			Expect(versions.UpdateVersionsJSON(vf2)).To(Succeed(), "should be able to merge new versions")

			// Verify all versions are present
			data, err := os.ReadFile(versions.VersionsFileName)
			Expect(err).NotTo(HaveOccurred(), "should be able to read versions file")

			var result versions.VersionsFile
			Expect(json.Unmarshal(data, &result)).To(Succeed(), "should be able to unmarshal versions file")
			Expect(result).To(HaveLen(3), "should have 3 projects")
			Expect(result["project-a"]).To(Equal(testVersion), "project-a version should be preserved")
			Expect(result["project-b"]).To(Equal("2.0.0"), "project-b version should be preserved")
			Expect(result["project-c"]).To(Equal("3.0.0"), "project-c version should be added")
		})

		It("should overwrite existing versions with new values", func() {
			tmpDir := GinkgoT().TempDir()
			originalDir, err := os.Getwd()
			Expect(err).NotTo(HaveOccurred(), "should be able to get current working directory")
			defer func() {
				Expect(os.Chdir(originalDir)).To(Succeed(), "should be able to change back to original directory")
			}()

			Expect(os.Chdir(tmpDir)).To(Succeed(), "should be able to change to temp directory")

			// Create initial versions
			vf := versions.VersionsFile{
				"project-a": testVersion,
			}
			Expect(versions.UpdateVersionsJSON(vf)).To(Succeed(), "should be able to update initial versions")

			// Update with new version
			vf2 := versions.VersionsFile{
				"project-a": "2.0.0",
			}
			Expect(versions.UpdateVersionsJSON(vf2)).To(Succeed(), "should be able to update with new version")

			// Verify version was updated
			data, err := os.ReadFile(versions.VersionsFileName)
			Expect(err).NotTo(HaveOccurred(), "should be able to read versions file")

			var result versions.VersionsFile
			Expect(json.Unmarshal(data, &result)).To(Succeed(), "should be able to unmarshal versions file")
			Expect(result["project-a"]).To(Equal("2.0.0"), "project-a version should be updated")
		})

		It("should create file with correct permissions", func() {
			tmpDir := GinkgoT().TempDir()
			originalDir, err := os.Getwd()
			Expect(err).NotTo(HaveOccurred(), "should be able to get current working directory")
			defer func() {
				Expect(os.Chdir(originalDir)).To(Succeed(), "should be able to change back to original directory")
			}()

			Expect(os.Chdir(tmpDir)).To(Succeed(), "should be able to change to temp directory")

			vf := versions.VersionsFile{
				"project-a": testVersion,
			}
			Expect(versions.UpdateVersionsJSON(vf)).To(Succeed(), "should be able to update versions JSON")

			info, err := os.Stat(versions.VersionsFileName)
			Expect(err).NotTo(HaveOccurred(), "should be able to stat versions file")
			Expect(info.Mode().Perm()).To(Equal(os.FileMode(versions.FilePermissions)), "file should have correct permissions")
		})

		It("should handle empty versions map", func() {
			tmpDir := GinkgoT().TempDir()
			originalDir, err := os.Getwd()
			Expect(err).NotTo(HaveOccurred(), "should be able to get current working directory")
			defer func() {
				Expect(os.Chdir(originalDir)).To(Succeed(), "should be able to change back to original directory")
			}()

			Expect(os.Chdir(tmpDir)).To(Succeed(), "should be able to change to temp directory")

			vf := versions.VersionsFile{}
			Expect(versions.UpdateVersionsJSON(vf)).To(Succeed(), "should be able to update versions JSON")

			data, err := os.ReadFile(versions.VersionsFileName)
			Expect(err).NotTo(HaveOccurred(), "should be able to read versions file")

			var result versions.VersionsFile
			Expect(json.Unmarshal(data, &result)).To(Succeed(), "should be able to unmarshal versions file")
			Expect(result).To(BeEmpty(), "versions file should be empty when no versions are provided")
		})
	})
})
