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

resource "kubernetes_manifest" "servicemonitor" {
  for_each = var.deploy_custom_resources ? toset(["descheduler"]) : toset([])

  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind"       = "ServiceMonitor"
    "metadata" = {
      "labels" = merge(local.labels, {
        "monitoring" = "descheduler"
      })
      "name"      = local.app_name
      "namespace" = var.monitoring_namespace
    }
    "spec" = {
      "endpoints" = [
        {
          "honorLabels" = true
          "metricRelabelings" = [
            {
              "action" = "keep"
              "regex"  = "descheduler_(build_info|pods_evicted)"
              "sourceLabels" = [
                "__name__",
              ]
            },
          ]
          "port" = "http-metrics"
          "relabelings" = [
            {
              "action"      = "replace"
              "regex"       = "^(.*)$"
              "replacement" = "$1"
              "separator"   = ";"
              "sourceLabels" = [
                "__meta_kubernetes_pod_node_name",
              ]
              "targetLabel" = "nodename"
            },
          ]
          "scheme" = "https"
          "tlsConfig" = {
            "insecureSkipVerify" = true
          }
        },
      ]
      "jobLabel" = "jobLabel"
      "namespaceSelector" = {
        "matchNames" = [
          local.namespace,
        ]
      }
      "selector" = {
        "matchLabels" = local.selector_labels
      }
    }
  }

  depends_on = [
    kubernetes_service.descheduler,
    data.kubernetes_namespace.monitoring
  ]
}
