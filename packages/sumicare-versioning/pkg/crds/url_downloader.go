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
	"fmt"
	"io"
	"maps"
	"net/http"
	"sync"

	"golang.org/x/sync/errgroup"
)

// urlDownloader downloads CRDs from URLs.
type urlDownloader struct {
	client *http.Client
}

// newURLDownloader creates a new URL downloader.
func newURLDownloader() *urlDownloader {
	return &urlDownloader{
		client: &http.Client{Timeout: defaultDownloaderTimeout},
	}
}

// download downloads CRDs from URLs.
func (downloader *urlDownloader) download(ctx context.Context, urls map[string]string) (map[string]string, error) {
	crds := make(map[string]string)

	errGroup, useErrCtx := errgroup.WithContext(ctx)
	errGroup.SetLimit(maxConcurrentDownloads) // Limit concurrent downloads

	mu := &sync.Mutex{}

	for name, url := range urls {
		// capture loop variables
		errGroup.Go(func() error {
			content, err := downloader.fetchURL(useErrCtx, url)
			if err != nil {
				return fmt.Errorf("fetch %s: %w", name, err)
			}

			extracted, err := splitMultiDocYAML(content)
			if err != nil || len(extracted) == 0 {
				mu.Lock()

				crds[name] = content

				mu.Unlock()

				//nolint:nilerr // we're marking empty content
				return nil
			}

			mu.Lock()
			maps.Copy(crds, extracted)
			mu.Unlock()

			return nil
		})
	}

	err := errGroup.Wait()
	if err != nil {
		return nil, fmt.Errorf("failed to download CRDs: %w", err)
	}

	return crds, nil
}

// fetchURL fetches a URL and returns its content.
func (downloader *urlDownloader) fetchURL(ctx context.Context, url string) (string, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, http.NoBody)
	if err != nil {
		return "", fmt.Errorf("failed to create request: %w", err)
	}

	resp, err := downloader.client.Do(req)
	if err != nil {
		return "", fmt.Errorf("failed to fetch URL: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return "", fmt.Errorf("%w %d", ErrHTTPResponse, resp.StatusCode)
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", fmt.Errorf("failed to read response body: %w", err)
	}

	return string(body), nil
}
