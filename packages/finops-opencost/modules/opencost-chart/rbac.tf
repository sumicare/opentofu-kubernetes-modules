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


resource "kubernetes_cluster_role" "opencost" {
  metadata {
    name   = local.app_name
    labels = local.labels
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["configmaps", "deployments", "nodes", "nodes/proxy", "pods", "services", "resourcequotas", "replicationcontrollers", "limitranges", "persistentvolumeclaims", "persistentvolumes", "namespaces", "endpoints"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["extensions"]
    resources  = ["daemonsets", "deployments", "replicasets"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["apps"]
    resources  = ["statefulsets", "deployments", "daemonsets", "replicasets"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["batch"]
    resources  = ["cronjobs", "jobs"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
  }
}

resource "kubernetes_cluster_role_binding" "opencost" {
  metadata {
    name   = local.app_name
    labels = local.labels
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.app_name
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = local.app_name
  }
}
