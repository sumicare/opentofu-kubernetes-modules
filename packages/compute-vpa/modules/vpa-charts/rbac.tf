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


resource "kubernetes_cluster_role" "vpa_admission_controller" {
  metadata {
    name = "vpa-admission-controller"
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["pods", "configmaps", "nodes", "limitranges"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list"]
    api_groups = ["admissionregistration.k8s.io"]
    resources  = ["mutatingwebhookconfigurations"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["poc.autoscaling.k8s.io"]
    resources  = ["verticalpodautoscalers"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["autoscaling.k8s.io"]
    resources  = ["verticalpodautoscalers"]
  }

  rule {
    verbs      = ["create", "update", "get", "list", "watch"]
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
  }
}

resource "kubernetes_cluster_role" "vpa_metrics_reader" {
  metadata {
    name = "vpa-metrics-reader"
  }

  rule {
    verbs      = ["get", "list"]
    api_groups = ["metrics.k8s.io"]
    resources  = ["pods"]
  }
}

resource "kubernetes_cluster_role" "vpa_actor" {
  metadata {
    name = "vpa-actor"
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["pods", "nodes", "limitranges"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create"]
    api_groups = [""]
    resources  = ["events"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["poc.autoscaling.k8s.io"]
    resources  = ["verticalpodautoscalers"]
  }

  rule {
    verbs      = ["get", "list", "watch", "patch"]
    api_groups = ["autoscaling.k8s.io"]
    resources  = ["verticalpodautoscalers"]
  }
}

resource "kubernetes_cluster_role" "vpa_status_actor" {
  metadata {
    name = "vpa-status-actor"
  }

  rule {
    verbs      = ["get", "patch"]
    api_groups = ["autoscaling.k8s.io"]
    resources  = ["verticalpodautoscalers/status"]
  }
}

resource "kubernetes_cluster_role" "vpa_checkpoint_actor" {
  metadata {
    name = "vpa-checkpoint-actor"
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "patch", "delete"]
    api_groups = ["poc.autoscaling.k8s.io"]
    resources  = ["verticalpodautoscalercheckpoints"]
  }

  rule {
    verbs      = ["get", "list", "watch", "create", "patch", "delete"]
    api_groups = ["autoscaling.k8s.io"]
    resources  = ["verticalpodautoscalercheckpoints"]
  }

  rule {
    verbs      = ["get", "list"]
    api_groups = [""]
    resources  = ["namespaces"]
  }
}

resource "kubernetes_cluster_role" "vpa_evictioner" {
  metadata {
    name = "vpa-evictioner"
  }

  rule {
    verbs      = ["get"]
    api_groups = ["apps", "extensions"]
    resources  = ["replicasets"]
  }

  rule {
    verbs      = ["create"]
    api_groups = [""]
    resources  = ["pods/eviction"]
  }
}

resource "kubernetes_cluster_role" "vpa_target_reader" {
  metadata {
    name = "vpa-target-reader"
  }

  rule {
    verbs      = ["get", "watch"]
    api_groups = ["*"]
    resources  = ["*/scale"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["replicationcontrollers"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["apps"]
    resources  = ["daemonsets", "deployments", "replicasets", "statefulsets"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["batch"]
    resources  = ["jobs", "cronjobs"]
  }
}

resource "kubernetes_cluster_role" "vpa_status_reader" {
  metadata {
    name = "vpa-status-reader"
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
  }
}

resource "kubernetes_cluster_role" "vpa_updater_in_place" {
  metadata {
    name = "vpa-updater-in-place"
  }

  rule {
    verbs      = ["patch"]
    api_groups = [""]
    resources  = ["pods/resize", "pods"]
  }
}

resource "kubernetes_cluster_role_binding" "vpa_admission_controller" {
  metadata {
    name = "vpa-admission-controller"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${local.app_name}-admission-controller"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "vpa-admission-controller"
  }
}

resource "kubernetes_cluster_role_binding" "vpa_metrics_reader" {
  metadata {
    name = "vpa-metrics-reader"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${local.app_name}-recommender"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "vpa-metrics-reader"
  }
}

resource "kubernetes_cluster_role_binding" "vpa_checkpoint_actor" {
  metadata {
    name = "vpa-checkpoint-actor"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${local.app_name}-recommender"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "vpa-checkpoint-actor"
  }
}

resource "kubernetes_cluster_role_binding" "vpa_status_actor" {
  metadata {
    name = "vpa-status-actor"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${local.app_name}-recommender"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "vpa-status-actor"
  }
}

resource "kubernetes_cluster_role_binding" "vpa_evictionter_binding" {
  metadata {
    name = "vpa-evictionter-binding"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${local.app_name}-updater"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "vpa-evictioner"
  }
}

resource "kubernetes_cluster_role_binding" "vpa_status_reader_binding" {
  metadata {
    name = "vpa-status-reader-binding"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${local.app_name}-updater"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "vpa-status-reader"
  }
}

resource "kubernetes_cluster_role_binding" "vpa_updater_in_place_binding" {
  metadata {
    name = "vpa-updater-in-place-binding"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${local.app_name}-updater"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "vpa-updater-in-place"
  }
}

resource "kubernetes_cluster_role_binding" "vpa_actor" {
  metadata {
    name = "vpa-actor"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${local.app_name}-recommender"
    namespace = var.namespace
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${local.app_name}-updater"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "vpa-actor"
  }
}

resource "kubernetes_cluster_role_binding" "vpa_target_reader_binding" {
  metadata {
    name = "vpa-target-reader-binding"
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${local.app_name}-recommender"
    namespace = var.namespace
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${local.app_name}-admission-controller"
    namespace = var.namespace
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${local.app_name}-updater"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "vpa-target-reader"
  }
}
