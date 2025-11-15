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

import "time"

// Common constants for CRD operations.
const (
	// defaultDirectoryPermission755 is the default permission for directories.
	defaultDirectoryPermission755 = 0o755
	// defaultFilePermission600 is the default permission for files.
	defaultFilePermission600 = 0o600

	// defaultDownloaderTimeout is the default timeout for downloader.
	defaultDownloaderTimeout = 30 * time.Second
	// maxConcurrentDownloads is the maximum number of concurrent downloads.
	maxConcurrentDownloads = 10

	// defaultBufferSize is the default buffer size for scanner.
	defaultBufferSize = 10 * 1024 * 1024 // 10MB

	// githubAPIBase is the base URL for GitHub API.
	githubAPIBase = "https://api.github.com"
	// githubRawBase is the base URL for GitHub raw content.
	githubRawBase = "https://raw.githubusercontent.com"

	// githubTokenEnvVar is the environment variable name for GitHub token.
	//
	//nolint:gosec // we're fine it's var name
	githubTokenEnvVar = "GITHUB_TOKEN"

	// autoGenLicenseHeader is the license header for auto-generated files.
	autoGenLicenseHeader = `#
# Copyright 2025 Sumicare
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

###           DO NOT EDIT            ###
# This file is automagically generated #

`
)
