/*
   Copyright 2025 Sumicare

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

locals {
  all_manifests = concat([
    merge(kubernetes_deployment.descheduler, { apiVersion = "apps/v1" }),
    merge(kubernetes_config_map.descheduler, { apiVersion = "v1" }),
    merge(kubernetes_service_account.descheduler, { apiVersion = "v1" }),
    merge(kubernetes_cluster_role.descheduler, { apiVersion = "rbac.authorization.k8s.io/v1" }),
    merge(kubernetes_cluster_role_binding.descheduler, { apiVersion = "rbac.authorization.k8s.io/v1" }),
    merge(kubernetes_pod_disruption_budget.descheduler, { apiVersion = "policy/v1" }),
    merge(try(kubernetes_pod_disruption_budget.descheduler["descheduler"], {}), { apiVersion = "policy/v1" }),
  ])
}

output "chart_yaml" {
  description = "Rendered Descheduler Chart"

  value = join("\n---\n", [
    for res in local.all_manifests : yamlencode(res)
  ])

  sensitive = true
}
