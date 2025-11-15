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


resource "kubernetes_cluster_role" "controller" {
  metadata {
    name   = "${local.app_name}-controller"
    labels = local.controller_labels
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["apps"]
    resources  = ["*"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["batch"]
    resources  = ["cronjobs", "jobs"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["namespaces", "pods"]
  }

  rule {
    verbs      = ["get", "list", "create", "delete", "update"]
    api_groups = ["autoscaling.k8s.io"]
    resources  = ["verticalpodautoscalers"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["argoproj.io"]
    resources  = ["rollouts"]
  }
}

resource "kubernetes_cluster_role" "dashboard" {
  metadata {
    name   = "${local.app_name}-dashboard"
    labels = local.dashboard_labels
  }

  rule {
    verbs      = ["get", "list"]
    api_groups = ["autoscaling.k8s.io"]
    resources  = ["verticalpodautoscalers"]
  }

  rule {
    verbs      = ["get", "list"]
    api_groups = ["apps"]
    resources  = ["*"]
  }

  rule {
    verbs      = ["get", "list"]
    api_groups = [""]
    resources  = ["namespaces", "pods"]
  }

  rule {
    verbs      = ["get", "list"]
    api_groups = ["argoproj.io"]
    resources  = ["rollouts"]
  }
}

resource "kubernetes_cluster_role_binding" "controller" {
  metadata {
    name   = "${local.app_name}-controller"
    labels = local.controller_labels
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${local.app_name}-controller"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${local.app_name}-controller"
  }
}

resource "kubernetes_cluster_role_binding" "dashboard" {
  metadata {
    name   = "${local.app_name}-dashboard"
    labels = local.dashboard_labels
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${local.app_name}-dashboard"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${local.app_name}-dashboard"
  }
}
