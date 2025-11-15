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

package versions

import "errors"

// Error definitions for version operations.
var (
	// ErrVersionFieldNotString is returned when the version field in package.json is not a string.
	ErrVersionFieldNotString = errors.New("version field is not a string")

	// ErrRepositoryRootNotFound is returned when the repository root directory cannot be found.
	ErrRepositoryRootNotFound = errors.New("repository root not found")
)
