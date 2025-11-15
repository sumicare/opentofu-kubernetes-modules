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

package pkg

// Repos returns a map of repository URLs for different components.
func Repos() map[string]string {
	return map[string]string{
		"compute-descheduler":              deschedulerRepo,
		"compute-goldilocks":               goldilocksRepo,
		"compute-grafana-rollout-operator": grafanaRolloutOperatorRepo,
		"compute-virtual-kubelet":          virtualKubeletRepo,
		"compute-kamaji":                   kamajiRepo,
		"compute-keda":                     kedaRepo,
		"compute-vpa":                      vpaRepo,
		"development-atlas-operator":       atlasOperatorRepo,
		"development-dex":                  dexRepo,
		"development-tekton-chains":        tektonChainsRepo,
		"development-tekton-dashboard":     tektonDashboardRepo,
		"development-tekton-pipeline":      tektonPipelineRepo,
		"development-tekton-results":       tektonResultsRepo,
		"development-tekton-triggers":      tektonTriggerRepo,
		"development-theia":                theiaRepo,
		"development-zot":                  zotRepo,
		"finops-cloud-cost-exporter":       cloudCostExporterRepo,
		"finops-opencost":                  opencostRepo,
		"gitops-argo-cd":                   argoCdRepo,
		"gitops-argo-events":               argoEventsRepo,
		"gitops-argo-rollouts":             argoRolloutsRepo,
		"gitops-argo-workflows":            argoWorkflowsRepo,
		"mlops-data-fusion-ballista":       dataFusionBallistaRepo,
		"mlops-ome":                        omeRepo,
		"mlops-kuberay":                    kubeRayRepo,
		"mlops-volcano":                    volcanoRepo,
		"networking-calico":                calicoRepo,
		"networking-external-dns":          externalDnsRepo,
		"networking-gateway-api":           gatewayApiRepo,
		"networking-linkerd":               linkerdRepo,
		"networking-linkerd-viz":           linkerdVizRepo,
		"observability-alloy":              alloyRepo,
		"observability-grafana":            grafanaRepo,
		"observability-grafana-mcp":        grafanaMcpRepo,
		"observability-kube-state-metrics": kubeStateMetricsRepo,
		"observability-loki":               lokiRepo,
		"observability-metrics-server":     metricsServerRepo,
		"observability-mimir":              mimirRepo,
		"observability-node-exporter":      nodeExporterRepo,
		"observability-prometheus":         prometheusRepo,
		"observability-pyroscope":          pyroscopeRepo,
		"observability-tempo":              tempoRepo,
		"security-cert-manager":            certManagerRepo,
		"security-bank-vaults-operator":    bankVaultsOperatorRepo,
		"security-bank-vaults-webhook":     bankVaultsWebhookRepo,
		"security-falco":                   falcoRepo,
		"security-kyverno":                 kyvernoRepo,
		"security-openbao":                 openbaoRepo,
		"security-openfga":                 openfgaRepo,
		"security-reloader":                reloaderRepo,
		"storage-cnpg":                     cnpgRepo,
		"storage-k8ssandra":                k8ssandraRepo,
		"storage-local-path-provisioner":   localPathProvisionerRepo,
		"storage-minio":                    minioRepo,
		"storage-mongodb":                  mongodbRepo,
		"storage-pvc-autoresizer":          pvcAutoresizerRepo,
		"storage-strimzi":                  strimziRepo,
		"storage-topolvm":                  topoLVMRepo,
		"storage-valkey":                   valkeyRepo,
		"storage-velero":                   veleroRepo,
	}
}
