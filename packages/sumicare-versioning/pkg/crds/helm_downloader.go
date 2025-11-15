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
	"archive/tar"
	"compress/gzip"
	"context"
	"fmt"
	"io"
	"maps"
	"net/http"
	"os"
	"path/filepath"
	"strings"

	"go.yaml.in/yaml/v3"
)

// helmDownloader handles downloading and extracting CRDs from Helm chart repositories.
// It implements security measures against:
// - Decompression bombs (via size limits)
// - Path traversal attacks (via path cleaning)
// - Invalid file sizes (via copy validation).
type helmDownloader struct {
	client *http.Client // Configured HTTP client with timeout
}

// newHelmDownloader creates a new Helm chart downloader instance.
// Initializes with default timeout settings from constants.go.
func newHelmDownloader() *helmDownloader {
	return &helmDownloader{
		client: &http.Client{Timeout: defaultDownloaderTimeout},
	}
}

// download retrieves and extracts CRDs from a Helm chart.
// Performs the following steps:
// 1. Fetches chart index to locate the chart URL
// 2. Downloads the chart archive
// 3. Extracts CRDs from the archive
// 4. Returns a map of CRD names to their YAML content.
func (downloader *helmDownloader) download(ctx context.Context, repo *HelmRepo, chartName, chartVersion string) (map[string]string, error) {
	if repo.IsOCI {
		return nil, ErrOCIUnsupported
	}

	// Fetch repo index
	indexURL := strings.TrimSuffix(repo.URL, "/") + "/index.yaml"

	chartURL, err := downloader.getChartURL(ctx, indexURL, chartName, chartVersion)
	if err != nil {
		return nil, fmt.Errorf("failed to get chart URL: %w", err)
	}

	// Download and extract
	archivePath, err := downloader.downloadArchive(ctx, chartURL)
	if err != nil {
		return nil, fmt.Errorf("failed to download archive: %w", err)
	}
	defer os.Remove(archivePath)

	extractDir, err := downloader.extractArchive(archivePath)
	if err != nil {
		return nil, fmt.Errorf("failed to extract archive: %w", err)
	}
	defer os.RemoveAll(extractDir)

	//nolint:wrapcheck // we're fine
	return downloader.extractCRDs(extractDir)
}

// getChartURL fetches the URL of a chart from the index.
func (downloader *helmDownloader) getChartURL(ctx context.Context, indexURL, chartName, version string) (string, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, indexURL, http.NoBody)
	if err != nil {
		return "", fmt.Errorf("failed to create request: %w", err)
	}

	resp, err := downloader.client.Do(req)
	if err != nil {
		return "", fmt.Errorf("failed to fetch index: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("%w %d", ErrHTTPResponse, resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("failed to read response body: %w", err)
	}

	var index struct {
		Entries map[string][]struct {
			Version string   `yaml:"version"`
			URLs    []string `yaml:"urls"`
		} `yaml:"entries"`
	}

	err = yaml.Unmarshal(body, &index)
	if err != nil {
		return "", fmt.Errorf("failed to unmarshal index: %w", err)
	}

	entries, ok := index.Entries[chartName]
	if !ok || len(entries) == 0 {
		return "", fmt.Errorf("%w: %q", ErrChartNotFound, chartName)
	}

	var chart *struct {
		Version string   `yaml:"version"`
		URLs    []string `yaml:"urls"`
	}

	if version == "" {
		chart = &entries[0]
	} else {
		for i := range entries {
			if entries[i].Version == version {
				chart = &entries[i]
				break
			}
		}
	}

	if chart == nil || len(chart.URLs) == 0 {
		return "", fmt.Errorf("%w: %q", ErrNoChartURL, chartName)
	}

	chartURL := chart.URLs[0]
	if !strings.HasPrefix(chartURL, "http") {
		baseURL := strings.TrimSuffix(indexURL, "/index.yaml")

		chartURL = baseURL + "/" + chartURL
	}

	return chartURL, nil
}

// downloadArchive downloads a chart archive.
func (downloader *helmDownloader) downloadArchive(ctx context.Context, url string) (string, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, http.NoBody)
	if err != nil {
		return "", fmt.Errorf("failed to create request: %w", err)
	}

	resp, err := downloader.client.Do(req)
	if err != nil {
		return "", fmt.Errorf("failed to download archive: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("%w %d", ErrHTTPResponse, resp.StatusCode)
	}

	tmpFile, err := os.CreateTemp("", "helm-chart-*.tgz")
	if err != nil {
		return "", fmt.Errorf("failed to create temp file: %w", err)
	}
	defer tmpFile.Close()

	_, err = io.Copy(tmpFile, resp.Body)
	if err != nil {
		os.Remove(tmpFile.Name())
		return "", fmt.Errorf("failed to copy archive: %w", err)
	}

	return tmpFile.Name(), nil
}

// maxTotalSize defines the maximum allowed total size for extracted archive contents.
// This is 10x the default buffer size to allow for reasonable chart sizes while
// still protecting against decompression bomb attacks.
const maxTotalSize = defaultBufferSize * 10

// extractArchive safely extracts a Helm chart archive (tar.gz).
// Implements security measures including:
// - Path traversal checks
// - File size validation
// - Archive size limits
// Returns the path to the extracted directory or an error if validation fails.
func (*helmDownloader) extractArchive(archivePath string) (string, error) {
	file, err := os.Open(archivePath)
	if err != nil {
		return "", fmt.Errorf("failed to open archive: %w", err)
	}
	defer file.Close()

	gzr, err := gzip.NewReader(file)
	if err != nil {
		return "", fmt.Errorf("failed to create gzip reader: %w", err)
	}
	defer gzr.Close()

	tmpDir, err := os.MkdirTemp("", "helm-chart-*")
	if err != nil {
		return "", fmt.Errorf("failed to create temp dir: %w", err)
	}

	tr := tar.NewReader(io.LimitReader(gzr, maxTotalSize))

	var totalExtracted int64

	for {
		header, err := tr.Next()
		if err == io.EOF {
			break
		}

		if err != nil {
			os.RemoveAll(tmpDir)
			return "", fmt.Errorf("failed to read archive: %w", err)
		}

		// Clean the path first and check for traversal attempts
		cleanedPath := filepath.Clean(header.Name)
		if strings.HasPrefix(cleanedPath, "..") || strings.HasPrefix(cleanedPath, "/") || strings.Contains(cleanedPath, "../") {
			os.RemoveAll(tmpDir)
			return "", fmt.Errorf("%w: %s", ErrInvalidPath, header.Name)
		}

		target := filepath.Join(tmpDir, cleanedPath)
		if !strings.HasPrefix(filepath.Clean(target), filepath.Clean(tmpDir)+string(os.PathSeparator)) {
			os.RemoveAll(tmpDir)
			return "", fmt.Errorf("%w: %s", ErrInvalidPath, header.Name)
		}

		switch header.Typeflag {
		case tar.TypeDir:
			err := os.MkdirAll(target, defaultDirectoryPermission755)
			if err != nil {
				os.RemoveAll(tmpDir)
				return "", fmt.Errorf("failed to create directory: %w", err)
			}

		case tar.TypeReg:
			if header.Size > defaultBufferSize {
				os.RemoveAll(tmpDir)
				return "", fmt.Errorf("%w: %s", ErrFileTooLarge, header.Name)
			}

			totalExtracted += header.Size
			if totalExtracted > maxTotalSize {
				os.RemoveAll(tmpDir)
				return "", ErrArchiveTooLarge
			}

			err := os.MkdirAll(filepath.Dir(target), defaultDirectoryPermission755)
			if err != nil {
				os.RemoveAll(tmpDir)
				return "", fmt.Errorf("failed to create directory: %w", err)
			}

			outFile, err := os.Create(target)
			if err != nil {
				os.RemoveAll(tmpDir)
				return "", fmt.Errorf("failed to create file: %w", err)
			}

			// Secure copy with size validation
			limitedReader := io.LimitReader(tr, header.Size)

			written, err := io.Copy(outFile, limitedReader)
			if err != nil {
				outFile.Close()
				os.RemoveAll(tmpDir)

				return "", fmt.Errorf("failed to copy file: %w", err)
			}

			if written != header.Size {
				outFile.Close()
				os.RemoveAll(tmpDir)

				return "", fmt.Errorf("%w: expected %d bytes, got %d", ErrFileSizeMismatch, header.Size, written)
			}

			outFile.Close()
		}
	}

	return tmpDir, nil
}

// extractCRDs searches for CRDs in a Helm chart directory structure.
// Looks in both the standard 'crds/' directory and the 'templates/' directory.
// Returns a map of CRD names to their YAML content.
func (downloader *helmDownloader) extractCRDs(chartDir string) (map[string]string, error) {
	// Find chart root
	entries, err := os.ReadDir(chartDir)
	if err != nil {
		return nil, fmt.Errorf("failed to read chart directory: %w", err)
	}

	var chartRoot string
	for _, entry := range entries {
		if entry.IsDir() {
			chartRoot = filepath.Join(chartDir, entry.Name())
			break
		}
	}

	if chartRoot == "" {
		chartRoot = chartDir
	}

	crds := make(map[string]string)

	// Check crds/ directory
	crdsDir := filepath.Join(chartRoot, "crds")

	info, err := os.Stat(crdsDir)
	if err == nil && info.IsDir() {
		err := downloader.readCRDsFromDir(crdsDir, crds)
		if err != nil {
			return nil, fmt.Errorf("failed to read existing chart crds directory: %w", err)
		}
	}

	// Check templates/ directory
	templatesDir := filepath.Join(chartRoot, "templates")

	info, err = os.Stat(templatesDir)
	if err == nil && info.IsDir() {
		err := downloader.readCRDsFromDir(templatesDir, crds)
		if err != nil {
			return nil, fmt.Errorf("failed to read existing chart templates directory: %w", err)
		}
	}

	if len(crds) == 0 {
		return nil, ErrNoCRDsFound
	}

	return crds, nil
}

// readCRDsFromDir reads CRDs from a directory.
func (*helmDownloader) readCRDsFromDir(dir string, crds map[string]string) error {
	//nolint:wrapcheck // we're fine
	return filepath.Walk(dir, func(path string, info os.FileInfo, err error) error {
		if err != nil || info.IsDir() {
			return err
		}

		if !strings.HasSuffix(info.Name(), ".yaml") && !strings.HasSuffix(info.Name(), ".yml") {
			return nil
		}

		content, err := os.ReadFile(path)
		if err != nil {
			return fmt.Errorf("failed to read file: %w", err)
		}

		if !strings.Contains(string(content), "kind: CustomResourceDefinition") {
			return nil
		}

		extracted, err := splitMultiDocYAML(string(content))
		if err != nil {
			return fmt.Errorf("failed to split YAML: %w", err)
		}

		maps.Copy(crds, extracted)

		return nil
	})
}
