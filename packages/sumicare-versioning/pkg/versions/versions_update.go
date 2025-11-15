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

import (
	"bytes"
	"encoding/json"
	"fmt"
	"maps"
	"os"
	"strings"
	"sync"

	"sumi.care/util/sumicare-versioning/pkg"
)

// GetPreservedVersion returns a preserved version for packages that don't use
// standard semver resolution. Returns empty string if the package should use
// normal semver-based logic.
//
// Packages with special handling:
//   - rust: always uses "nightly"
//   - debian: preserves existing non-semver versions (e.g., "trixie-20251117-slim")
func GetPreservedVersion(packageName, currentVersion string) string {
	switch packageName {
	case "rust":
		return "nightly"
	case "debian":
		// Preserve debian versions that don't follow semver (contain hyphens with dates/codenames)
		if strings.Contains(currentVersion, "-") {
			return currentVersion
		}
	}

	return ""
}

// GetProjectFetchers returns the mapping of package directory names to their version fetcher functions.
func GetProjectFetchers() map[string]VersionFetcher {
	return map[string]VersionFetcher{
		"compute-descheduler":              pkg.GetDeschedulerVersion,
		"compute-goldilocks":               pkg.GetGoldilocksVersion,
		"compute-grafana-rollout-operator": pkg.GetGrafanaRolloutOperatorVersion,
		"compute-kamaji":                   pkg.GetKamajiVersion,
		"compute-keda":                     pkg.GetKedaVersion,
		"compute-virtual-kubelet":          pkg.GetVirtualKubeletVersion,
		"compute-vpa":                      pkg.GetVpaVersion,
		"debian":                           pkg.GetDebianVersion,
		"development-atlas-operator":       pkg.GetAtlasOperatorVersion,
		"development-dex":                  pkg.GetDexVersion,
		"development-tekton-chains":        pkg.GetTektonChainsVersion,
		"development-tekton-dashboard":     pkg.GetTektonDashboardVersion,
		"development-tekton-pipeline":      pkg.GetTektonPipelineVersion,
		"development-tekton-results":       pkg.GetTektonResultsVersion,
		"development-tekton-triggers":      pkg.GetTektonTriggerVersion,
		"development-theia":                pkg.GetTheiaVersion,
		"development-zot":                  pkg.GetZotVersion,
		"finops-cloud-cost-exporter":       pkg.GetCloudCostExporterVersion,
		"finops-opencost":                  pkg.GetOpencostVersion,
		"gitops-argo-cd":                   pkg.GetArgoCdVersion,
		"gitops-argo-events":               pkg.GetArgoEventsVersion,
		"gitops-argo-rollouts":             pkg.GetArgoRolloutsVersion,
		"gitops-argo-workflows":            pkg.GetArgoWorkflowsVersion,
		"mlops-data-fusion-ballista":       pkg.GetDataFusionBallistaVersion,
		"mlops-kuberay":                    pkg.GetKuberayVersion,
		"mlops-ome":                        pkg.GetOmeVersion,
		"mlops-volcano":                    pkg.GetVolcanoVersion,
		"networking-calico":                pkg.GetCalicoVersion,
		"networking-external-dns":          pkg.GetExternalDnsVersion,
		"networking-gateway-api":           pkg.GetGatewayApiVersion,
		"networking-linkerd":               pkg.GetLinkerdVersion,
		"networking-linkerd-viz":           pkg.GetLinkerdVizVersion,
		"observability-alloy":              pkg.GetAlloyVersion,
		"observability-grafana":            pkg.GetGrafanaVersion,
		"observability-grafana-mcp":        pkg.GetGrafanaMcpVersion,
		"observability-kube-state-metrics": pkg.GetKubeStateMetricsVersion,
		"observability-loki":               pkg.GetLokiVersion,
		"observability-metrics-server":     pkg.GetMetricsServerVersion,
		"observability-mimir":              pkg.GetMimirVersion,
		"observability-node-exporter":      pkg.GetNodeExporterVersion,
		"observability-prometheus":         pkg.GetPrometheusVersion,
		"observability-pyroscope":          pkg.GetPyroscopeVersion,
		"observability-tempo":              pkg.GetTempoVersion,
		"security-cert-manager":            pkg.GetCertManagerVersion,
		"security-bank-vaults-operator":    pkg.GetBankVaultsOperatorVersion,
		"security-bank-vaults-webhook":     pkg.GetBankVaultsWebhookVersion,
		"security-falco":                   pkg.GetFalcoVersion,
		"security-kyverno":                 pkg.GetKyvernoVersion,
		"security-openbao":                 pkg.GetOpenbaoVersion,
		"security-openfga":                 pkg.GetOpenfgaVersion,
		"security-reloader":                pkg.GetReloaderVersion,
		"storage-cnpg":                     pkg.GetCnpgVersion,
		"storage-k8ssandra":                pkg.GetK8ssandraVersion,
		"storage-local-path-provisioner":   pkg.GetLocalPathProvisionerVersion,
		"storage-minio":                    pkg.GetMinioVersion,
		"storage-mongodb":                  pkg.GetMongodbVersion,
		"storage-pvc-autoresizer":          pkg.GetPvcAutoresizerVersion,
		"storage-strimzi":                  pkg.GetStrimziVersion,
		"storage-topolvm":                  pkg.GetTopoLVMVersion,
		"storage-valkey":                   pkg.GetValkeyVersion,
		"storage-velero":                   pkg.GetVeleroVersion,
	}
}

// FindMissingProjects identifies projects that don't have versions yet.
func FindMissingProjects(versions VersionsFile) []string {
	var missing []string
	for projectName := range GetProjectFetchers() {
		if _, ok := versions[projectName]; !ok {
			missing = append(missing, projectName)
		}
	}

	return missing
}

// FetchMissingVersions fetches versions for projects missing from the versions map and returns the list of missing projects.
// Fetches are done in parallel using goroutines for better performance.
func FetchMissingVersions(versions VersionsFile) []string {
	missingProjects := FindMissingProjects(versions)
	if len(missingProjects) == 0 {
		return missingProjects
	}

	var (
		mu sync.Mutex
		wg sync.WaitGroup
	)

	fetchers := GetProjectFetchers()

	type missingJob struct {
		name string
	}

	jobs := make([]missingJob, 0, len(missingProjects))
	for _, projectName := range missingProjects {
		jobs = append(jobs, missingJob{name: projectName})
	}

	for i := range jobs {
		job := jobs[i]

		wg.Go(func() {
			latestVersions, err := fetchers[job.name](1)
			if err != nil || len(latestVersions) == 0 {
				return
			}

			mu.Lock()

			versions[job.name] = latestVersions[0]

			mu.Unlock()
		})
	}

	wg.Wait()

	return missingProjects
}

// UpdateVersionsJSON updates the versions.json file with the given versions.
func UpdateVersionsJSON(versions VersionsFile) error {
	existingData := make(VersionsFile)

	data, err := os.ReadFile(VersionsFileName)
	if err == nil {
		err := json.Unmarshal(data, &existingData)
		if err != nil {
			return fmt.Errorf("failed to parse existing versions.json: %w", err)
		}
	} else if !os.IsNotExist(err) {
		return fmt.Errorf("failed to read versions.json: %w", err)
	}

	maps.Copy(existingData, versions)

	buf := &bytes.Buffer{}
	enc := json.NewEncoder(buf)
	enc.SetEscapeHTML(false)
	enc.SetIndent("", "  ")

	err = enc.Encode(existingData)
	if err != nil {
		return fmt.Errorf("failed to marshal versions: %w", err)
	}

	err = os.WriteFile(VersionsFileName, buf.Bytes(), FilePermissions)
	if err != nil {
		return fmt.Errorf("write %s: %w", VersionsFileName, err)
	}

	return nil
}
