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

package pkg

import (
	"os"
	"strings"

	"github.com/Masterminds/semver/v3"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

// VersionFetchFunc is a function type for version fetchers.
type VersionFetchFunc func(limit int) ([]string, error)

// TestVersionFetcher creates standardized tests for a version fetcher function.
// This reduces code duplication across all version fetcher tests.
//
//nolint:unparam // it's okay to use this helper to init ginkgo tests
func TestVersionFetcher(name string, fetchFunc VersionFetchFunc) bool {
	return Describe(name, func() {
		Context("with valid limit", func() {
			It("should fetch filtered versions", func() {
				if os.Getenv("GITHUB_TOKEN") == "" {
					Skip("Integration test - requires GITHUB_TOKEN environment variable")
				}

				//nolint:mnd // false positive
				versions, err := fetchFunc(3)
				Expect(err).NotTo(HaveOccurred(), "expected no error")
				Expect(versions).NotTo(BeEmpty(), "expected non-empty versions")

				//nolint:mnd // false positive
				Expect(len(versions)).To(BeNumerically("<=", 3), "expected at most 3 versions")

				// Versions should NOT have 'v' prefix
				for _, v := range versions {
					Expect(strings.HasPrefix(v, "v")).To(BeFalse(), "version %s should not have 'v' prefix", v)
				}

				// Versions should be valid semver (including optional build metadata)
				for _, v := range versions {
					_, err := semver.NewVersion(v)
					Expect(err).NotTo(HaveOccurred(), "version %s should be valid semver", v)
				}
			})
		})

		Context("version filtering", func() {
			It("should exclude pre-release versions", func() {
				if os.Getenv("GITHUB_TOKEN") == "" {
					Skip("Integration test - requires GITHUB_TOKEN environment variable")
				}

				//nolint:mnd // false positive
				versions, err := fetchFunc(5)
				Expect(err).NotTo(HaveOccurred(), "expected no error")

				for _, v := range versions {
					parsed, parseErr := semver.NewVersion(v)
					Expect(parseErr).NotTo(HaveOccurred(), "version %s should be valid semver", v)
					Expect(parsed.Prerelease()).To(Equal(""), "version %s should not be a pre-release", v)
				}
			})
		})
	})
}
