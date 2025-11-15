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
	"regexp"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("GetMinioVersion", func() {
	Context("with valid limit", func() {
		It("should fetch filtered Minio versions", func() {
			if os.Getenv("GITHUB_TOKEN") == "" {
				Skip("Integration test - requires GITHUB_TOKEN environment variable")
			}

			versions, err := GetMinioVersion(3)
			Expect(err).NotTo(HaveOccurred(), "expected no error")
			Expect(versions).NotTo(BeEmpty(), "expected non-empty versions")
			Expect(len(versions)).To(BeNumerically("<=", 3), "expected at most 3 versions")

			// Versions should match Minio's date format: YYYY-MM-DDTHH-MM-SSZ
			datePattern := regexp.MustCompile(`^\d{4}-\d{2}-\d{2}T\d{2}-\d{2}-\d{2}Z$`)

			for _, v := range versions {
				Expect(datePattern.MatchString(v)).To(BeTrue(), "version %s should match date format", v)
			}
		})
	})

	Context("version ordering", func() {
		It("should return versions in descending order", func() {
			if os.Getenv("GITHUB_TOKEN") == "" {
				Skip("Integration test - requires GITHUB_TOKEN environment variable")
			}

			versions, err := GetMinioVersion(5)
			Expect(err).NotTo(HaveOccurred(), "expected no error")

			// Versions should be sorted newest first (lexicographically for date strings)
			for i := range len(versions) - 1 {
				Expect(versions[i] > versions[i+1]).To(BeTrue(), "version %s should be > %s (descending order)", versions[i], versions[i+1])
			}
		})
	})
})
