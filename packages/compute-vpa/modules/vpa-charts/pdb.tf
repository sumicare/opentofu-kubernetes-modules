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


resource "kubernetes_pod_disruption_budget" "admission_controller" {
  count = contains(["staging", "prod"], var.env) ? 1 : 0

  metadata {
    name      = "${local.app_name}-admission-controller"
    namespace = var.namespace

    labels = local.labels
  }

  spec {
    selector {
      match_labels = local.admission_controller_labels
    }

    max_unavailable = ceil(var.admission_controller_replicas / 2)
  }
}


resource "kubernetes_pod_disruption_budget" "recommender" {
  count = contains(["staging", "prod"], var.env) ? 1 : 0

  metadata {
    name      = "${local.app_name}-recommender"
    namespace = var.namespace

    labels = local.labels
  }

  spec {
    selector {
      match_labels = local.recommender_labels
    }

    max_unavailable = ceil(var.recommender_replicas / 2)
  }
}


resource "kubernetes_pod_disruption_budget" "updater" {
  count = contains(["staging", "prod"], var.env) ? 1 : 0

  metadata {
    name      = "${local.app_name}-updater"
    namespace = var.namespace

    labels = local.labels
  }

  spec {
    selector {
      match_labels = local.updater_labels
    }

    max_unavailable = ceil(var.updater_replicas / 2)
  }
}
