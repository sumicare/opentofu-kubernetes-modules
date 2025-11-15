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

package asdf

// ToolUpdateResult represents the result of updating a single asdf-managed tool.
type ToolUpdateResult struct {
	// Name is the name of the tool.
	Name string

	// OldVersion is the previous version of the tool.
	OldVersion string

	// NewVersion is the new version of the tool.
	NewVersion string

	// Changed indicates whether the version was changed.
	Changed bool

	// Installed indicates whether the new version was installed.
	Installed bool
}
