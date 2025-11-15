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

package mock

import (
	"io"
	"net/http"
	"strings"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
)

// The following Describe blocks exercise each mock server end-to-end to ensure
// they behave like their upstream counterparts (GitHub, Helm, and generic
// HTTP). Keeping these integration-style tests heavily commented makes it
// easier to reason about the mocked behavior when updating fixtures.
// Tests for GitHubMockServer, HelmMockServer, and URLMockServer.
var _ = Describe("Mock Servers", func() {
	Describe("GitHubMockServer", func() {
		var server *GitHubMockServer

		BeforeEach(func() {
			server = NewGitHubMockServer()
			server.AddCRDFile("crds", "test-crd.yaml", "tests.example.com")
		})

		AfterEach(func() { server.Close() })

		// DescribeTable is used here to cover success/404 behaviors while sharing
		// the same setup logic. Adding comments keeps the intent clear to future
		// contributors reading the table entries.
		DescribeTable("file downloads",
			func(path string, expectedStatus int, shouldContainCRD bool) {
				resp, err := http.Get(server.URL() + path)
				Expect(err).NotTo(HaveOccurred(), "HTTP request should succeed")
				defer resp.Body.Close()

				Expect(resp.StatusCode).To(Equal(expectedStatus), "status code should match")

				//nolint:revive // it's fine for testing to return late
				if shouldContainCRD {
					body, readErr := io.ReadAll(resp.Body)
					Expect(readErr).NotTo(HaveOccurred(), "should read body")
					Expect(string(body)).To(ContainSubstring("CustomResourceDefinition"), "should contain CRD")
				}
			},
			Entry("downloads CRD file", "/raw/owner/repo/main/crds/test-crd.yaml", http.StatusOK, true),
			Entry("returns 404 for missing file", "/raw/owner/repo/main/missing.yaml", http.StatusNotFound, false),
		)

		It("requires authentication when token is set", func() {
			server.SetAuthToken("valid-token")

			// Without token - should fail
			resp, err := http.Get(server.URL() + "/raw/o/r/m/crds/test-crd.yaml")
			Expect(err).NotTo(HaveOccurred(), "HTTP request should succeed")
			resp.Body.Close()
			Expect(resp.StatusCode).To(Equal(http.StatusUnauthorized), "should be unauthorized")

			// With token - should succeed
			req, reqErr := http.NewRequest(http.MethodGet, server.URL()+"/raw/o/r/m/crds/test-crd.yaml", http.NoBody)
			Expect(reqErr).NotTo(HaveOccurred(), "should create request")
			req.Header.Set("Authorization", "token valid-token")
			resp, err = http.DefaultClient.Do(req)
			Expect(err).NotTo(HaveOccurred(), "HTTP request should succeed")
			defer resp.Body.Close()
			Expect(resp.StatusCode).To(Equal(http.StatusOK), "should be OK with token")
		})
	})

	Describe("HelmMockServer", func() {
		var server *HelmMockServer

		BeforeEach(func() {
			server = NewHelmMockServer()
			server.AddChart("test-chart", "1.0.0")
			server.AddCRDToChart("test-chart", "test-crd.yaml", "tests.example.com")
		})

		AfterEach(func() { server.Close() })

		// Each table entry focuses on a single Helm endpoint to validate content
		// types and HTTP status codes without duplicating boilerplate request
		// logic.
		DescribeTable("endpoints",
			func(path string, expectedStatus int, contentType string) {
				resp, err := http.Get(server.URL() + path)
				Expect(err).NotTo(HaveOccurred(), "HTTP request should succeed")
				defer resp.Body.Close()

				Expect(resp.StatusCode).To(Equal(expectedStatus), "status code should match")
				if contentType != "" {
					Expect(resp.Header.Get("Content-Type")).To(ContainSubstring(contentType), "content type should match")
				}
			},
			Entry("serves index.yaml", "/index.yaml", http.StatusOK, "yaml"),
			Entry("serves chart archive", "/test-chart-1.0.0.tgz", http.StatusOK, "gzip"),
			Entry("returns 404 for missing chart", "/missing-1.0.0.tgz", http.StatusNotFound, ""),
		)
	})

	Describe("URLMockServer", func() {
		var server *URLMockServer

		BeforeEach(func() { server = NewURLMockServer() })
		AfterEach(func() { server.Close() })

		// Table-driven approach lets us reuse the server while asserting against
		// various CRD payload shapes (single doc, multi doc, mixed content).
		DescribeTable("CRD downloads",
			func(setup func(), path string, expectedCRDs []string) {
				setup()

				resp, err := http.Get(server.GetURL(path))
				Expect(err).NotTo(HaveOccurred(), "HTTP request should succeed")
				defer resp.Body.Close()

				Expect(resp.StatusCode).To(Equal(http.StatusOK), "status should be OK")

				body, readErr := io.ReadAll(resp.Body)
				Expect(readErr).NotTo(HaveOccurred(), "should read body")
				content := string(body)

				for _, crd := range expectedCRDs {
					Expect(content).To(ContainSubstring(crd), "should contain CRD: "+crd)
				}
			},
			Entry("single CRD",
				func() { server.AddCRD("/crd.yaml", "tests.example.com") },
				"/crd.yaml", []string{"tests.example.com"},
			),
			Entry("multi-document CRD",
				func() { server.AddMultiDocCRD("/multi.yaml", "test1.example.com", "test2.example.com") },
				"/multi.yaml", []string{"test1.example.com", "test2.example.com"},
			),
			Entry("mixed content",
				func() { server.AddMixedContent("/mixed.yaml", []string{"crd.example.com"}, []string{"configmap"}) },
				"/mixed.yaml", []string{"crd.example.com", "configmap"},
			),
		)

		It("returns 404 for missing path", func() {
			resp, err := http.Get(server.GetURL("/missing.yaml"))
			Expect(err).NotTo(HaveOccurred(), "HTTP request should succeed")
			defer resp.Body.Close()
			Expect(resp.StatusCode).To(Equal(http.StatusNotFound), "should return 404")
		})
	})
})

// Tests for CRD content generation across all server types.
var _ = Describe("CRD Content Generation", func() {
	DescribeTable("generates valid CRD YAML",
		func(serverType, crdName string) {
			var content string

			switch serverType {
			case "github":
				s := NewGitHubMockServer()
				defer s.Close()
				s.AddCRDFile("crds", "test.yaml", crdName)
				content = s.FileContent["crds/test.yaml"]
			case "helm":
				s := NewHelmMockServer()
				defer s.Close()
				s.AddChart("test", "1.0.0")
				s.AddCRDToChart("test", "test.yaml", crdName)
				content = s.Charts["test"].CRDs["test.yaml"]
			case "url":
				s := NewURLMockServer()
				defer s.Close()
				s.AddCRD("/test.yaml", crdName)
				content = s.Content["/test.yaml"]
			}

			Expect(content).To(ContainSubstring("apiVersion: apiextensions.k8s.io/v1"), "should have apiVersion")
			Expect(content).To(ContainSubstring("kind: CustomResourceDefinition"), "should have kind")
			Expect(content).To(ContainSubstring("name: "+crdName), "should have name")
		},
		Entry("GitHub server", "github", "tests.example.com"),
		Entry("Helm server", "helm", "foos.example.com"),
		Entry("URL server", "url", "bars.example.com"),
	)
})

// Tests for server URL methods.
var _ = Describe("Server URL Methods", func() {
	It("returns valid URLs", func() {
		github := NewGitHubMockServer()
		defer github.Close()
		Expect(github.URL()).To(HavePrefix("http://"), "GitHub URL should be HTTP")

		helm := NewHelmMockServer()
		defer helm.Close()
		Expect(helm.URL()).To(HavePrefix("http://"), "Helm URL should be HTTP")

		urlServer := NewURLMockServer()
		defer urlServer.Close()
		Expect(urlServer.URL()).To(HavePrefix("http://"), "URL server should be HTTP")
		Expect(urlServer.GetURL("/path")).To(HaveSuffix("/path"), "GetURL should append path")
		Expect(strings.HasSuffix(urlServer.GetURL("/path"), "/path")).To(BeTrue(), "path should be appended")
	})
})
