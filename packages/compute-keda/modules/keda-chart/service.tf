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


resource "kubernetes_service" "keda_operator" {
  metadata {
    name      = "${local.app_name}-operator"
    namespace = var.namespace
    labels    = local.labels
  }

  spec {
    port {
      name        = "metricsservice"
      port        = 9666
      target_port = "9666"
    }

    selector = local.operator_labels
  }
}

resource "kubernetes_service" "keda_metrics_apiserver" {
  metadata {
    name      = "${local.app_name}-metrics"
    namespace = var.namespace
    labels    = local.operator_labels
  }

  spec {
    port {
      name         = "https"
      protocol     = "TCP"
      app_protocol = "https"
      port         = 443
      target_port  = "6443"
    }

    port {
      name        = "metrics"
      protocol    = "TCP"
      port        = 8080
      target_port = "8080"
    }

    selector = local.metrics_server_labels
    type     = "ClusterIP"
  }
}

resource "kubernetes_service" "keda_admission_webhooks" {
  metadata {
    name      = "${local.app_name}-admission-webhooks"
    namespace = var.namespace
    labels    = local.operator_labels
  }

  spec {
    port {
      name         = "https"
      protocol     = "TCP"
      app_protocol = "https"
      port         = 443
      target_port  = "9443"
    }

    selector = local.webhook_labels
  }
}
