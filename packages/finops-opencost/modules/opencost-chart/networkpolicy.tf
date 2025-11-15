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


resource "kubernetes_network_policy" "opencost" {
  metadata {
    name      = local.app_name
    namespace = var.namespace
    labels    = local.labels
  }

  spec {
    pod_selector {
      match_labels = {
        "app.kubernetes.io/name" = local.app_name
      }
    }

    ingress {
      ports {
        port = tostring(var.api_port)
      }

      from {
        pod_selector {
          match_labels = {
            "app.kubernetes.io/name" = "prometheus"
          }
        }

        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = var.prometheus_namespace
          }
        }
      }
    }

    egress {
      ports {
        port = "9090"
      }

      to {
        pod_selector {
          match_labels = {
            "app.kubernetes.io/name" = "prometheus"
          }
        }

        namespace_selector {
          match_labels = {
            "kubernetes.io/metadata.name" = var.prometheus_namespace
          }
        }
      }
    }

    policy_types = ["Ingress", "Egress"]
  }
}
