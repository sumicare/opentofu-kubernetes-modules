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

package github

import (
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

var _ = Describe("Client", func() {
	Describe("NewClient", func() {
		It("should create a new client", func() {
			client := NewClient()
			Expect(client).NotTo(BeNil(), "client should not be nil")
			Expect(client.httpClient).NotTo(BeNil(), "httpClient should not be nil")
		})
	})

	Describe("GetOwnerRepoFrom", func() {
		Context("with valid URLs", func() {
			It("should parse HTTPS URL with .git", func() {
				owner, repo := GetOwnerRepoFrom("https://github.com/kubernetes/kubernetes.git")
				Expect(owner).To(Equal("kubernetes"), "owner should be extracted correctly")
				Expect(repo).To(Equal("kubernetes"), "repo should be extracted correctly")
			})

			It("should parse HTTPS URL without .git", func() {
				owner, repo := GetOwnerRepoFrom("https://github.com/kubernetes/kubernetes")
				Expect(owner).To(Equal("kubernetes"), "owner should be extracted correctly")
				Expect(repo).To(Equal("kubernetes"), "repo should be extracted correctly")
			})

			It("should parse SSH URL", func() {
				owner, repo := GetOwnerRepoFrom("git@github.com:kubernetes/kubernetes.git")
				Expect(owner).To(Equal("kubernetes"), "owner should be extracted correctly")
				Expect(repo).To(Equal("kubernetes"), "repo should be extracted correctly")
			})
		})

		Context("with invalid URLs", func() {
			It("should return empty strings for malformed URL", func() {
				owner, repo := GetOwnerRepoFrom("invalid-url")
				Expect(owner).To(Equal(""), "owner should be empty for invalid URL")
				Expect(repo).To(Equal(""), "repo should be empty for invalid URL")
			})

			It("should return empty strings for URL with too many parts", func() {
				owner, repo := GetOwnerRepoFrom("https://github.com/owner/repo/extra")
				Expect(owner).To(Equal(""), "owner should be empty for malformed URL")
				Expect(repo).To(Equal(""), "repo should be empty for malformed URL")
			})
		})
	})

	Describe("parseNextLink", func() {
		It("should parse next link from Link header", func() {
			header := `<https://api.github.com/repos/owner/repo/tags?page=2>; rel="next", <https://api.github.com/repos/owner/repo/tags?page=10>; rel="last"`
			nextURL := parseNextLink(header)
			Expect(nextURL).To(Equal("https://api.github.com/repos/owner/repo/tags?page=2"), "should extract next page URL")
		})

		It("should return empty string when no next link", func() {
			header := `<https://api.github.com/repos/owner/repo/tags?page=10>; rel="last"`
			nextURL := parseNextLink(header)
			Expect(nextURL).To(Equal(""), "should return empty when no next link")
		})

		It("should return empty string for empty header", func() {
			nextURL := parseNextLink("")
			Expect(nextURL).To(Equal(""), "should return empty for empty header")
		})
	})
})
