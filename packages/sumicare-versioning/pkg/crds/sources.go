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
	"path/filepath"
	"strings"
)

const (
	// mainRef is the default branch name for GitHub repositories.
	mainRef = "main"
)

// SourceConfig defines the CRD source configuration.
// Package naming follows the convention: <group>-<name> (e.g., "compute-keda", "security-cert-manager").
type SourceConfig struct {
	HelmRepo       *HelmRepo
	GitHubDir      *GitHubCRDDir
	CRDURLs        map[string]string
	Package        string
	ChartName      string
	SkipDownload   bool
	AllowEmptyCRDs bool
}

// GetAllSources returns all CRD sources with their target directories.
// Target directories are derived from the package structure: packages/<package>/modules/<name>-crds/.
func GetAllSources(packagesRoot string) []Source {
	configs := getAllSourceConfigs()
	sources := make([]Source, 0, len(configs))

	for i := range configs {
		sources = append(sources, configs[i].toSource(packagesRoot))
	}

	return sources
}

// toSource converts a SourceConfig to a Source with computed target directory.
func (config *SourceConfig) toSource(packagesRoot string) Source {
	// Extract name from package: "compute-keda" -> "keda"
	name := config.Package
	if idx := strings.Index(config.Package, "-"); idx != -1 {
		name = config.Package[idx+1:]
	}

	return Source{
		Name:           name,
		TargetDir:      filepath.Join(packagesRoot, config.Package, "modules", name+"-crds"),
		HelmRepo:       config.HelmRepo,
		ChartName:      config.ChartName,
		GitHubDir:      config.GitHubDir,
		CRDURLs:        config.CRDURLs,
		SkipDownload:   config.SkipDownload,
		AllowEmptyCRDs: config.AllowEmptyCRDs,
	}
}

// getAllSourceConfigs returns all CRD source configurations.
func getAllSourceConfigs() []SourceConfig {
	return []SourceConfig{
		// Compute
		{
			Package:   "compute-keda",
			HelmRepo:  &HelmRepo{Name: "kedacore", URL: "https://kedacore.github.io/charts"},
			ChartName: "keda",
		},
		{
			Package: "compute-vpa",
			CRDURLs: map[string]string{
				"vpa-v1-crd.yaml": "https://raw.githubusercontent.com/kubernetes/autoscaler/refs/heads/master/vertical-pod-autoscaler/deploy/vpa-v1-crd-gen.yaml",
			},
		},

		// Development
		{
			Package: "development-atlas-operator",
			// Use GitHub URL instead of OCI registry
			GitHubDir: &GitHubCRDDir{Owner: "ariga", Repo: "atlas-operator", Path: "charts/atlas-operator/templates/crds", Ref: "master", FilePattern: "*.yaml"},
		},
		{
			Package: "development-tekton-dashboard",
			// Dashboard CRDs are in config/ directory, filter for CRDs only
			GitHubDir: &GitHubCRDDir{Owner: "tektoncd", Repo: "dashboard", Path: "config", Ref: mainRef, FilePattern: "*.yaml", FilterCRDsOnly: true},
		},
		{
			Package: "development-tekton-pipeline",
			// Pipeline CRDs are in config/300-crds/
			GitHubDir: &GitHubCRDDir{Owner: "tektoncd", Repo: "pipeline", Path: "config/300-crds", Ref: mainRef, FilePattern: "*.yaml"},
		},
		{
			Package: "development-tekton-triggers",
			// Triggers CRDs are in config/ directory, filter for CRDs only
			GitHubDir: &GitHubCRDDir{Owner: "tektoncd", Repo: "triggers", Path: "config", Ref: mainRef, FilePattern: "*.yaml", FilterCRDsOnly: true},
		},
		{
			Package:   "development-theia",
			HelmRepo:  &HelmRepo{Name: "theia-cloud", URL: "https://eclipse-theia.github.io/theia-cloud-helm"},
			ChartName: "theia-cloud-crds",
		},

		// GitOps
		{
			Package:   "gitops-argo-cd",
			HelmRepo:  &HelmRepo{Name: "argo", URL: "https://argoproj.github.io/argo-helm"},
			ChartName: "argo-cd",
		},
		{
			Package:   "gitops-argo-events",
			HelmRepo:  &HelmRepo{Name: "argo", URL: "https://argoproj.github.io/argo-helm"},
			ChartName: "argo-events",
		},
		{
			Package:   "gitops-argo-rollouts",
			HelmRepo:  &HelmRepo{Name: "argo", URL: "https://argoproj.github.io/argo-helm"},
			ChartName: "argo-rollouts",
		},
		{
			Package:   "gitops-argo-workflows",
			HelmRepo:  &HelmRepo{Name: "argo", URL: "https://argoproj.github.io/argo-helm"},
			ChartName: "argo-workflows",
		},

		// MLOps
		{
			Package: "mlops-volcano",
			CRDURLs: map[string]string{
				"volcano-crds.yaml": "https://raw.githubusercontent.com/volcano-sh/volcano/master/installer/volcano-development.yaml",
			},
		},

		// Networking
		{
			Package:   "networking-external-dns",
			HelmRepo:  &HelmRepo{Name: "external-dns", URL: "https://kubernetes-sigs.github.io/external-dns/"},
			ChartName: "external-dns",
		},
		{
			Package:   "networking-gateway-api",
			GitHubDir: &GitHubCRDDir{Owner: "kubernetes-sigs", Repo: "gateway-api", Path: "config/crd/experimental", Ref: mainRef, FilePattern: "*.yaml"},
		},

		// Observability
		{
			Package: "observability-prometheus",
			// Use GitHub URL for Prometheus CRDs
			GitHubDir: &GitHubCRDDir{
				Owner:       "prometheus-community",
				Repo:        "helm-charts",
				Path:        "charts/kube-prometheus-stack/charts/crds/crds",
				Ref:         mainRef,
				FilePattern: "*.yaml",
			},
		},

		// Security
		{
			Package:   "security-cert-manager",
			HelmRepo:  &HelmRepo{Name: "cert-manager", URL: "https://charts.jetstack.io"},
			ChartName: "cert-manager",
		},
		{
			Package:   "security-falco",
			GitHubDir: &GitHubCRDDir{Owner: "falcosecurity", Repo: "falco-operator", Path: "config/crd/bases", Ref: mainRef, FilePattern: "*.yaml"},
		},
		{
			Package: "security-kyverno",
			// Use GitHub URL for Kyverno CRDs
			GitHubDir: &GitHubCRDDir{Owner: "kyverno", Repo: "kyverno", Path: "charts/kyverno/charts/crds", Ref: mainRef, FilePattern: "*.yaml"},
		},

		// Storage
		{
			Package:   "storage-cnpg",
			HelmRepo:  &HelmRepo{Name: "cnpg", URL: "https://cloudnative-pg.github.io/charts"},
			ChartName: "cloudnative-pg",
		},
		{
			Package:   "storage-k8ssandra",
			GitHubDir: &GitHubCRDDir{Owner: "k8ssandra", Repo: "k8ssandra", Path: "charts/cass-operator/crds", Ref: mainRef, FilePattern: "*.yaml"},
		},
		{
			Package:   "storage-minio",
			HelmRepo:  &HelmRepo{Name: "minio", URL: "https://operator.min.io/"},
			ChartName: "minio-operator",
		},
		{
			Package:   "storage-strimzi",
			HelmRepo:  &HelmRepo{Name: "strimzi", URL: "https://strimzi.io/charts/"},
			ChartName: "strimzi-kafka-operator",
		},
		{
			Package:   "storage-velero",
			HelmRepo:  &HelmRepo{Name: "vmware-tanzu", URL: "https://vmware-tanzu.github.io/helm-charts"},
			ChartName: "velero",
		},
	}
}

// GetSourceByName returns a specific source by name or package.
func GetSourceByName(packagesRoot, name string) *Source {
	nameLower := strings.ToLower(name)

	sources := GetAllSources(packagesRoot)
	for i := range sources {
		if strings.EqualFold(sources[i].Name, nameLower) {
			return &sources[i]
		}
	}

	return nil
}

// GetSourceByPackage returns a specific source by package name.
func GetSourceByPackage(packagesRoot, pkg string) *Source {
	pkgName := strings.ToLower(pkg)

	sourceConfigs := getAllSourceConfigs()
	for i := range sourceConfigs {
		if strings.EqualFold(sourceConfigs[i].Package, pkgName) {
			src := sourceConfigs[i].toSource(packagesRoot)

			return &src
		}
	}

	return nil
}
