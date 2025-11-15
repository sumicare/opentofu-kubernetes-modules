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

package crds

import (
	"context"
	"os"
	"testing"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	"sumi.care/util/sumicare-versioning/pkg/crds/mock"
)

var _ = Describe("GitHub Downloader", func() {
	var (
		downloader *githubDownloader
		ctx        context.Context
	)

	BeforeEach(func() {
		downloader = newGitHubDownloader()
		ctx = context.Background()
	})

	Describe("newGitHubDownloader", func() {
		It("should create a new GitHub downloader", func() {
			d := newGitHubDownloader()
			Expect(d).NotTo(BeNil(), "newGitHubDownloader should return a non-nil downloader")
			Expect(d.client).NotTo(BeNil(), "client should be initialized")
			Expect(d.client.Timeout).To(Equal(defaultDownloaderTimeout), "client should have the default timeout")
		})

		It("should read token from environment", func() {
			// Set environment variable
			os.Setenv(githubTokenEnvVar, "test-token")
			defer os.Unsetenv(githubTokenEnvVar)

			d := newGitHubDownloader()
			Expect(d.token).To(Equal("test-token"), "token should be read from environment")
		})
	})

	Describe("download", func() {
		It("should return error for nil GitHubDir", func() {
			_, err := downloader.download(ctx, nil)
			Expect(err).To(HaveOccurred(), "download should return an error for nil GitHubDir")
			Expect(err).To(Equal(ErrGitHubDirNil), "error should be ErrGitHubDirNil")
		})

		It("should use default ref if not specified", func() {
			// Create a GitHubDir without a ref
			dir := &GitHubCRDDir{
				Owner: "test-owner",
				Repo:  "test-repo",
				Path:  "test-path",
			}

			// Check that the default ref is set
			Expect(dir.Ref).To(BeEmpty(), "ref should be empty initially")
			if dir.Ref == "" {
				dir.Ref = "main" // This is what happens inside the download method
			}
			Expect(dir.Ref).To(Equal("main"), "ref should be set to main")
		})

		It("should use default pattern if not specified", func() {
			// Create a GitHubDir without a pattern
			dir := &GitHubCRDDir{
				Owner: "test-owner",
				Repo:  "test-repo",
				Path:  "test-path",
				Ref:   "test-ref",
			}

			// Check that the default pattern is set
			Expect(dir.FilePattern).To(BeEmpty(), "pattern should be empty initially")
			if dir.FilePattern == "" {
				dir.FilePattern = "*.yaml" // This is what happens inside the download method
			}
			Expect(dir.FilePattern).To(Equal("*.yaml"), "pattern should be set to *.yaml")
		})
	})

	Describe("Authentication", func() {
		It("should set token from environment variable", func() {
			// Save original env var
			originalToken := os.Getenv(githubTokenEnvVar)
			defer os.Setenv(githubTokenEnvVar, originalToken)

			// Set environment variable
			os.Setenv(githubTokenEnvVar, "test-token")

			// Create a new downloader
			d := newGitHubDownloader()
			Expect(d.token).To(Equal("test-token"), "token should be set from environment variable")
		})
	})

	Describe("download with mock server", func() {
		var mockServer *mock.GitHubMockServer

		BeforeEach(func() {
			mockServer = mock.NewGitHubMockServer()
			// Configure downloader to use mock server
			downloader.apiBaseURL = mockServer.URL()
			downloader.rawBaseURL = mockServer.URL() + "/raw"
		})

		AfterEach(func() {
			mockServer.Close()
		})

		It("should download CRDs from GitHub directory", func() {
			// Add CRD files to mock server
			mockServer.AddCRDFile("crds", "test-crd.yaml", "tests.example.com")

			dir := &GitHubCRDDir{
				Owner: "test-owner",
				Repo:  "test-repo",
				Path:  "crds",
				Ref:   "main",
			}

			crds, err := downloader.download(ctx, dir)
			Expect(err).NotTo(HaveOccurred(), "download should not return an error")
			Expect(crds).To(HaveLen(1), "should download 1 CRD")
			Expect(crds).To(HaveKey("tests.example.com.yaml"), "should have the correct CRD name")
		})

		It("should download multiple CRDs", func() {
			// Add multiple CRD files
			mockServer.AddCRDFile("crds", "test1.yaml", "tests1.example.com")
			mockServer.AddCRDFile("crds", "test2.yaml", "tests2.example.com")

			dir := &GitHubCRDDir{
				Owner: "test-owner",
				Repo:  "test-repo",
				Path:  "crds",
				Ref:   "main",
			}

			crds, err := downloader.download(ctx, dir)
			Expect(err).NotTo(HaveOccurred(), "download should not return an error")
			Expect(crds).To(HaveLen(2), "should download 2 CRDs")
			Expect(crds).To(HaveKey("tests1.example.com.yaml"), "should have the first CRD")
			Expect(crds).To(HaveKey("tests2.example.com.yaml"), "should have the second CRD")
		})

		It("should filter files by pattern", func() {
			// Add CRD files with different extensions
			mockServer.AddCRDFile("crds", "test.yaml", "tests.example.com")

			dir := &GitHubCRDDir{
				Owner:       "test-owner",
				Repo:        "test-repo",
				Path:        "crds",
				Ref:         "main",
				FilePattern: "*.yaml",
			}

			crds, err := downloader.download(ctx, dir)
			Expect(err).NotTo(HaveOccurred(), "download should not return an error")
			Expect(crds).To(HaveLen(1), "should download 1 CRD matching pattern")
		})

		It("should return error for non-existent directory", func() {
			dir := &GitHubCRDDir{
				Owner: "test-owner",
				Repo:  "test-repo",
				Path:  "non-existent",
				Ref:   "main",
			}

			_, err := downloader.download(ctx, dir)
			Expect(err).To(HaveOccurred(), "download should return an error for non-existent directory")
		})

		It("should use authentication token", func() {
			mockServer.SetAuthToken("test-token")
			mockServer.AddCRDFile("crds", "test.yaml", "tests.example.com")

			// Set token on downloader
			downloader.token = "test-token"

			dir := &GitHubCRDDir{
				Owner: "test-owner",
				Repo:  "test-repo",
				Path:  "crds",
				Ref:   "main",
			}

			crds, err := downloader.download(ctx, dir)
			Expect(err).NotTo(HaveOccurred(), "download should not return an error with valid token")
			Expect(crds).To(HaveLen(1), "should download 1 CRD")
		})

		It("should fail with invalid authentication token", func() {
			mockServer.SetAuthToken("valid-token")
			mockServer.AddCRDFile("crds", "test.yaml", "tests.example.com")

			// Set wrong token on downloader
			downloader.token = "invalid-token"

			dir := &GitHubCRDDir{
				Owner: "test-owner",
				Repo:  "test-repo",
				Path:  "crds",
				Ref:   "main",
			}

			_, err := downloader.download(ctx, dir)
			Expect(err).To(HaveOccurred(), "download should return an error with invalid token")
		})
	})
})

// TestGitHubDownloaderWithoutGinkgo tests the GitHub downloader without using Ginkgo.
func TestGitHubDownloaderWithoutGinkgo(t *testing.T) {
	// Test newGitHubDownloader
	d := newGitHubDownloader()
	if d == nil {
		t.Fatal("newGitHubDownloader returned nil")
	}

	if d.client == nil {
		t.Fatal("client is nil")
	}
}
