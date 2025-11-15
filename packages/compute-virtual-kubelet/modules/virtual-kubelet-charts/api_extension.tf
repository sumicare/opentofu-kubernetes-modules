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


resource "kubernetes_manifest" "apiservice_v1beta1_external_metrics_k8s_io" {
  manifest = {
    apiVersion = "apiregistration.k8s.io/v1"
    kind       = "APIService"
    metadata = {
      annotations = {
        "cert-manager.io/inject-ca-from" = "${var.namespace}/${local.app_name}-tls-certificates"
      }
      labels = local.labels
      name   = "v1beta1.external.metrics.k8s.io"
    }
    spec = {
      group                = "external.metrics.k8s.io"
      groupPriorityMinimum = 100
      service = {
        name      = "${local.app_name}-metrics"
        namespace = var.namespace
        port      = 443
      }
      version         = "v1beta1"
      versionPriority = 100
    }
  }
}
