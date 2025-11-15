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

import "errors"

// Common error definitions.
var (
	// ErrNoSourceConfigured is returned when no CRD source is configured.
	ErrNoSourceConfigured = errors.New("no CRD source configured")
	// ErrDownloadFailed is returned when CRD download fails.
	ErrDownloadFailed = errors.New("errors downloading CRDs")
	// ErrHTTPResponse is returned when an HTTP request fails.
	ErrHTTPResponse = errors.New("HTTP error response")

	// ErrGitHubDirNil is returned when GitHubCRDDir is nil.
	ErrGitHubDirNil = errors.New("GitHubCRDDir is nil")
	// ErrNoFilesMatch is returned when no files match the pattern.
	ErrNoFilesMatch = errors.New("no files matching pattern in repository")
	// ErrFailedToListDir is returned when listing a directory fails.
	ErrFailedToListDir = errors.New("failed to list directory")
	// ErrFailedToCreateReq is returned when creating a request fails.
	ErrFailedToCreateReq = errors.New("failed to create request")
	// ErrFailedToDecodeResp is returned when decoding a response fails.
	ErrFailedToDecodeResp = errors.New("failed to decode response body")
	// ErrFailedToReadResp is returned when reading a response fails.
	ErrFailedToReadResp = errors.New("failed to read response body")
	// ErrInvalidPattern is returned when a pattern is invalid.
	ErrInvalidPattern = errors.New("invalid pattern")

	// ErrOCIUnsupported is returned when OCI registries are not supported.
	ErrOCIUnsupported = errors.New("OCI registries not supported")
	// ErrChartNotFound is returned when a chart is not found.
	ErrChartNotFound = errors.New("chart not found")
	// ErrNoChartURL is returned when a chart URL is not found.
	ErrNoChartURL = errors.New("no URL found for chart")
	// ErrInvalidPath is returned when a path is invalid.
	ErrInvalidPath = errors.New("invalid path")
	// ErrNoCRDsFound is returned when no CRDs are found in a chart.
	ErrNoCRDsFound = errors.New("no CRDs found in chart")

	// ErrFileTooLarge is returned when a file exceeds the maximum size limit.
	ErrFileTooLarge = errors.New("file exceeds maximum size limit")
	// ErrArchiveTooLarge is returned when an archive exceeds the maximum size limit.
	ErrArchiveTooLarge = errors.New("archive exceeds maximum size limit")
	// ErrFileSizeMismatch is returned when a file size does not match the expected size.
	ErrFileSizeMismatch = errors.New("file size mismatch")
)
