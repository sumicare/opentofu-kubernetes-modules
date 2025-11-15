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


resource "kubernetes_pod_disruption_budget" "keda_operator" {
  count = contains(["staging", "prod"], var.env) ? 1 : 0

  metadata {
    name      = "${local.app_name}-operator"
    namespace = var.namespace

    labels = local.labels
  }

  spec {
    selector {
      match_labels = local.operator_labels
    }

    max_unavailable = ceil(var.operator_replicas / 2)
  }
}


resource "kubernetes_pod_disruption_budget" "keda_metrics_server" {
  count = contains(["staging", "prod"], var.env) ? 1 : 0

  metadata {
    name      = "${local.app_name}-metrics-server"
    namespace = var.namespace

    labels = local.labels
  }

  spec {
    selector {
      match_labels = local.metrics_server_labels
    }

    max_unavailable = ceil(var.metrics_server_replicas / 2)
  }
}


resource "kubernetes_pod_disruption_budget" "keda_webhook" {
  count = contains(["staging", "prod"], var.env) ? 1 : 0

  metadata {
    name      = "${local.app_name}-webhook"
    namespace = var.namespace

    labels = local.labels
  }

  spec {
    selector {
      match_labels = local.webhook_labels
    }

    max_unavailable = ceil(var.webhook_replicas / 2)
  }
}
