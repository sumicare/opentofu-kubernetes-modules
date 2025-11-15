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


resource "kubernetes_service" "descheduler" {

  metadata {
    name      = local.app_name
    namespace = local.namespace
    labels    = local.labels
  }

  spec {
    port {
      name        = "http-metrics"
      protocol    = "TCP"
      port        = var.http_metrics_port
      target_port = tostring(var.http_metrics_port)
    }

    selector   = local.selector_labels
    cluster_ip = "None"
    type       = "ClusterIP"
  }

  depends_on = [
    kubernetes_deployment.descheduler,
    data.kubernetes_namespace.descheduler
  ]
}
