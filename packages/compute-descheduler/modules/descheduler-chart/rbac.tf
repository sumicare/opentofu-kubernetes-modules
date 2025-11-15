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


resource "kubernetes_cluster_role" "descheduler" {
  metadata {
    name   = local.app_name
    labels = local.labels
  }

  rule {
    verbs      = ["create", "update"]
    api_groups = ["events.k8s.io"]
    resources  = ["events"]
  }

  rule {
    verbs      = ["get", "watch", "list"]
    api_groups = [""]
    resources  = ["nodes"]
  }

  rule {
    verbs      = ["get", "watch", "list"]
    api_groups = [""]
    resources  = ["namespaces"]
  }

  rule {
    verbs      = ["get", "watch", "list", "delete"]
    api_groups = [""]
    resources  = ["pods"]
  }

  rule {
    verbs      = ["create"]
    api_groups = [""]
    resources  = ["pods/eviction"]
  }

  rule {
    verbs      = ["get", "watch", "list"]
    api_groups = ["scheduling.k8s.io"]
    resources  = ["priorityclasses"]
  }

  rule {
    verbs      = ["get", "watch", "list"]
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
  }

  rule {
    verbs      = ["create", "update"]
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
  }

  rule {
    verbs          = ["get", "patch", "delete"]
    api_groups     = ["coordination.k8s.io"]
    resources      = ["leases"]
    resource_names = ["descheduler"]
  }

  rule {
    verbs      = ["get", "list"]
    api_groups = ["metrics.k8s.io"]
    resources  = ["pods", "nodes"]
  }

  depends_on = [
    kubernetes_service_account.descheduler,
    data.kubernetes_namespace.descheduler
  ]
}

resource "kubernetes_cluster_role_binding" "descheduler" {
  metadata {
    name   = local.app_name
    labels = local.labels
  }

  subject {
    kind      = "ServiceAccount"
    name      = local.app_name
    namespace = local.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = local.app_name
  }

  depends_on = [
    kubernetes_cluster_role.descheduler,
    kubernetes_service_account.descheduler,
    data.kubernetes_namespace.descheduler
  ]
}
