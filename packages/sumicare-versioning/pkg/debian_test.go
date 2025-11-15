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

package pkg_test

import (
	"testing"

	"sumi.care/util/sumicare-versioning/pkg"
)

// TestGetDebianVersion tests the GetDebianVersion function.
func TestGetDebianVersion(t *testing.T) {
	//nolint:revive // false positive
	versions, err := pkg.GetDebianVersion(5)
	if err != nil {
		t.Fatalf("GetDebianVersion() error = %v", err)
	}

	if len(versions) == 0 {
		t.Error("GetDebianVersion() returned no versions")
	}

	// Verify all returned tags end with "-slim"
	for _, version := range versions {
		//nolint:revive // we're fine with magic numbers here
		if len(version) < 5 || version[len(version)-5:] != "-slim" {
			t.Errorf("GetDebianVersion() returned non-slim tag: %s", version)
		}
	}

	t.Logf("Found %d Debian slim versions: %v", len(versions), versions)
}
