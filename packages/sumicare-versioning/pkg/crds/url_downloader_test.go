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
	"net/http"
	"net/http/httptest"
	"testing"

	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"

	"sumi.care/util/sumicare-versioning/pkg/crds/mock"
)

var _ = Describe("URL Downloader", func() {
	var (
		downloader *urlDownloader
		ctx        context.Context
	)

	BeforeEach(func() {
		downloader = newURLDownloader()
		ctx = context.Background()
	})

	Describe("newURLDownloader", func() {
		It("should create a new URL downloader", func() {
			d := newURLDownloader()
			Expect(d).NotTo(BeNil(), "newURLDownloader should return a non-nil downloader")
			Expect(d.client).NotTo(BeNil(), "client should be initialized")
			Expect(d.client.Timeout).To(Equal(defaultDownloaderTimeout), "client should have the default timeout")
		})
	})

	Describe("download", func() {
		It("should download from URLs", func() {
			// Create a mock server
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
				// Return a simple CRD
				w.WriteHeader(http.StatusOK)
				//nolint:errcheck // Ignore write errors in tests
				_, _ = w.Write([]byte(`apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: test-crd.example.com`))
			}))
			defer server.Close()

			// Create URLs map
			urls := map[string]string{
				"test-crd.yaml": server.URL + "/test-crd.yaml",
			}

			// Download
			crds, err := downloader.download(ctx, urls)
			Expect(err).NotTo(HaveOccurred(), "download should not return an error")
			Expect(crds).To(HaveLen(1), "download should return 1 CRD")
			Expect(crds).To(HaveKey("test-crd.example.com.yaml"), "download should return the CRD with the correct name")
		})

		It("should handle HTTP errors", func() {
			// Create a mock server
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
				w.WriteHeader(http.StatusNotFound)
			}))
			defer server.Close()

			// Create URLs map
			urls := map[string]string{
				"test-crd.yaml": server.URL + "/test-crd.yaml",
			}

			// Download
			_, err := downloader.download(ctx, urls)
			Expect(err).To(HaveOccurred(), "download should return an error")
		})

		It("should handle empty URLs map", func() {
			// Create empty URLs map
			urls := make(map[string]string)

			// Download
			crds, err := downloader.download(ctx, urls)
			Expect(err).NotTo(HaveOccurred(), "download should not return an error for empty URLs map")
			Expect(crds).To(BeEmpty(), "download should return empty map for empty URLs map")
		})

		It("should handle multi-document YAML", func() {
			// Create a mock server
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
				// Return a multi-document YAML
				w.WriteHeader(http.StatusOK)
				//nolint:errcheck // Ignore write errors in tests
				_, _ = w.Write([]byte(`---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: test-crd1.example.com
---
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: test-crd2.example.com
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: not-a-crd`))
			}))
			defer server.Close()

			// Create URLs map
			urls := map[string]string{
				"test-crds.yaml": server.URL + "/test-crds.yaml",
			}

			// Download
			crds, err := downloader.download(ctx, urls)
			Expect(err).NotTo(HaveOccurred(), "download should not return an error")
			Expect(crds).To(HaveLen(2), "download should return 2 CRDs")
			Expect(crds).To(HaveKey("test-crd1.example.com.yaml"), "download should return the first CRD")
			Expect(crds).To(HaveKey("test-crd2.example.com.yaml"), "download should return the second CRD")
			Expect(crds).NotTo(HaveKey("not-a-crd.yaml"), "download should not return the ConfigMap")
		})
	})

	Describe("fetchURL", func() {
		It("should fetch URL content", func() {
			// Create a mock server
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
				w.WriteHeader(http.StatusOK)
				//nolint:errcheck // Ignore write errors in tests
				_, _ = w.Write([]byte("test content"))
			}))
			defer server.Close()

			// Fetch URL
			content, err := downloader.fetchURL(ctx, server.URL)
			Expect(err).NotTo(HaveOccurred(), "fetchURL should not return an error")
			Expect(content).To(Equal("test content"), "fetchURL should return the correct content")
		})

		It("should handle HTTP errors", func() {
			// Create a mock server
			server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, _ *http.Request) {
				w.WriteHeader(http.StatusNotFound)
			}))
			defer server.Close()

			// Fetch URL
			_, err := downloader.fetchURL(ctx, server.URL)
			Expect(err).To(HaveOccurred(), "fetchURL should return an error")
			Expect(err.Error()).To(ContainSubstring("404"), "error should contain the status code")
		})
	})

	Describe("download with mock server", func() {
		var mockServer *mock.URLMockServer

		BeforeEach(func() {
			mockServer = mock.NewURLMockServer()
		})

		AfterEach(func() {
			mockServer.Close()
		})

		It("should download single CRD", func() {
			mockServer.AddCRD("/crd.yaml", "tests.example.com")

			urls := map[string]string{
				"crd.yaml": mockServer.GetURL("/crd.yaml"),
			}

			crds, err := downloader.download(ctx, urls)
			Expect(err).NotTo(HaveOccurred(), "download should not return an error")
			Expect(crds).To(HaveLen(1), "should download 1 CRD")
			Expect(crds).To(HaveKey("tests.example.com.yaml"), "should have the correct CRD name")
		})

		It("should download multi-document CRD", func() {
			mockServer.AddMultiDocCRD("/crds.yaml", "tests1.example.com", "tests2.example.com")

			urls := map[string]string{
				"crds.yaml": mockServer.GetURL("/crds.yaml"),
			}

			crds, err := downloader.download(ctx, urls)
			Expect(err).NotTo(HaveOccurred(), "download should not return an error")
			Expect(crds).To(HaveLen(2), "should download 2 CRDs")
			Expect(crds).To(HaveKey("tests1.example.com.yaml"), "should have the first CRD")
			Expect(crds).To(HaveKey("tests2.example.com.yaml"), "should have the second CRD")
		})

		It("should filter CRDs from mixed content", func() {
			mockServer.AddMixedContent("/mixed.yaml",
				[]string{"tests.example.com"},
				[]string{"configmap1", "configmap2"},
			)

			urls := map[string]string{
				"mixed.yaml": mockServer.GetURL("/mixed.yaml"),
			}

			crds, err := downloader.download(ctx, urls)
			Expect(err).NotTo(HaveOccurred(), "download should not return an error")
			Expect(crds).To(HaveLen(1), "should download only 1 CRD (not ConfigMaps)")
			Expect(crds).To(HaveKey("tests.example.com.yaml"), "should have the CRD")
		})

		It("should download from multiple URLs", func() {
			mockServer.AddCRD("/crd1.yaml", "tests1.example.com")
			mockServer.AddCRD("/crd2.yaml", "tests2.example.com")

			urls := map[string]string{
				"crd1.yaml": mockServer.GetURL("/crd1.yaml"),
				"crd2.yaml": mockServer.GetURL("/crd2.yaml"),
			}

			crds, err := downloader.download(ctx, urls)
			Expect(err).NotTo(HaveOccurred(), "download should not return an error")
			Expect(crds).To(HaveLen(2), "should download 2 CRDs")
		})
	})
})

// TestURLDownloaderWithoutGinkgo tests the URL downloader without using Ginkgo.
func TestURLDownloaderWithoutGinkgo(t *testing.T) {
	// Test newURLDownloader
	d := newURLDownloader()
	if d == nil {
		t.Fatal("newURLDownloader returned nil")
	}

	if d.client == nil {
		t.Fatal("client is nil")
	}
}
