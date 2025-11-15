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


resource "kubernetes_service" "release_name_prometheus_node_exporter" {
  metadata {
    name      = "release-name-prometheus-node-exporter"
    namespace = "node-exporter"

    labels = {
      "app.kubernetes.io/component"  = "metrics"
      "app.kubernetes.io/instance"   = "release-name"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "prometheus-node-exporter"
      "app.kubernetes.io/part-of"    = "prometheus-node-exporter"
      "app.kubernetes.io/version"    = "1.10.2"
      "helm.sh/chart"                = "prometheus-node-exporter-4.49.1"
    }

    annotations = {
      "prometheus.io/scrape" = "true"
    }
  }

  spec {
    port {
      name        = "metrics"
      protocol    = "TCP"
      port        = 9100
      target_port = "9100"
    }

    selector = {
      "app.kubernetes.io/instance" = "release-name"
      "app.kubernetes.io/name"     = "prometheus-node-exporter"
    }

    type = "ClusterIP"
  }
}

