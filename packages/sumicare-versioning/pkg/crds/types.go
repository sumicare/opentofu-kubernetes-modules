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

// Source defines how to fetch CRDs for a component.
type (
	Source struct {
		HelmRepo     *HelmRepo
		GitHubDir    *GitHubCRDDir
		CRDURLs      map[string]string
		Name         string
		TargetDir    string
		ChartName    string
		ChartVersion string
		// SkipDownload indicates that this source should be skipped entirely
		SkipDownload bool
		// AllowEmptyCRDs indicates that empty CRD sets are acceptable and should not cause errors
		AllowEmptyCRDs bool
	}

	// GitHubCRDDir represents a GitHub directory containing CRD files.
	GitHubCRDDir struct {
		// Owner is the GitHub repository owner.
		Owner string
		// Repo is the GitHub repository name.
		Repo string
		// Path is the directory path within the repository.
		Path string
		// Ref is the branch, tag, or commit (default: "main").
		Ref string
		// FilePattern is an optional glob pattern to filter files (default: "*.yaml").
		FilePattern string
		// FilterCRDsOnly filters downloaded YAML files to only include CustomResourceDefinition resources.
		FilterCRDsOnly bool
	}

	// HelmRepo represents a Helm repository.
	HelmRepo struct {
		// Name is the repository name (used for logging).
		Name string

		// URL is the repository URL (e.g., "https://kedacore.github.io/charts").
		URL string

		// IsOCI indicates if this is an OCI registry.
		IsOCI bool
	}

	// HelmRepoIndex represents the index.yaml structure of a Helm repository.
	HelmRepoIndex struct {
		Entries    map[string][]HelmChartMetadata `yaml:"entries"`
		APIVersion string                         `yaml:"apiVersion"`
	}

	// HelmChartMetadata represents chart metadata in the repository index.
	HelmChartMetadata struct {
		Name        string   `yaml:"name"`
		Version     string   `yaml:"version"`
		AppVersion  string   `yaml:"appVersion"`
		Digest      string   `yaml:"digest"`
		Description string   `yaml:"description"`
		URLs        []string `yaml:"urls"`
	}

	// ChartYAML represents the Chart.yaml file structure.
	ChartYAML struct {
		APIVersion  string `yaml:"apiVersion"`
		Name        string `yaml:"name"`
		Version     string `yaml:"version"`
		AppVersion  string `yaml:"appVersion"`
		Description string `yaml:"description"`
	}
)
