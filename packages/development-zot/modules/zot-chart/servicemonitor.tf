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


resource "kubernetes_manifest" "servicemonitor_zot" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind"       = "ServiceMonitor"
    "metadata" = {
      "name"      = local.app_name
      "namespace" = var.namespace
      "labels" = merge(local.labels, {
        "app.kubernetes.io/component" = "metrics"
      })
    }
    "spec" = {
      "endpoints" = [
        {
          "basicAuth" = {
            "password" = {
              "key"  = "password"
              "name" = "basic-auth"
            }
            "username" = {
              "key"  = "username"
              "name" = "basic-auth"
            }
          }
          "interval" = "30s"
          "path"     = "/metrics"
          "port"     = "http"
        },
      ]
      "namespaceSelector" = {
        "matchNames" = [
          var.namespace,
        ]
      }
      "selector" = {
        "matchLabels" = local.selector_labels
      }
    }
  }
}
