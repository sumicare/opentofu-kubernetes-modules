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


resource "kubernetes_cluster_role" "keda_operator" {
  metadata {
    name   = "${local.app_name}-operator"
    labels = local.labels
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["configmaps", "configmaps/status", "limitranges", "pods", "services", "serviceaccounts"]
  }

  rule {
    verbs      = ["create", "patch"]
    api_groups = [""]
    resources  = ["events"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = [""]
    resources  = ["secrets"]
  }

  rule {
    verbs      = ["get", "list", "patch", "update", "watch"]
    api_groups = ["*"]
    resources  = ["*/scale"]
  }

  rule {
    verbs      = ["get"]
    api_groups = ["*"]
    resources  = ["*"]
  }

  rule {
    verbs      = ["get", "list", "patch", "update", "watch"]
    api_groups = ["apps"]
    resources  = ["deployments/scale", "statefulsets/scale"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["apps"]
    resources  = ["deployments", "statefulsets"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["batch"]
    resources  = ["jobs"]
  }

  rule {
    verbs      = ["get", "list", "patch", "update", "watch"]
    api_groups = ["eventing.keda.sh"]
    resources  = ["cloudeventsources", "cloudeventsources/status", "clustercloudeventsources", "clustercloudeventsources/status"]
  }

  rule {
    verbs      = ["get", "list", "patch", "update", "watch"]
    api_groups = ["keda.sh"]
    resources  = ["scaledjobs", "scaledjobs/finalizers", "scaledjobs/status", "scaledobjects", "scaledobjects/finalizers", "scaledobjects/status", "triggerauthentications", "triggerauthentications/status"]
  }
}

resource "kubernetes_cluster_role" "keda_minimal_cluster_role" {
  metadata {
    name   = "${local.app_name}-operator-minimal-cluster-role"
    labels = local.labels
  }

  rule {
    verbs      = ["get", "list", "patch", "update", "watch"]
    api_groups = ["keda.sh"]
    resources  = ["clustertriggerauthentications", "clustertriggerauthentications/status"]
  }

  rule {
    verbs      = ["get", "list", "patch", "update", "watch"]
    api_groups = ["eventing.keda.sh"]
    resources  = ["cloudeventsources", "cloudeventsources/status", "clustercloudeventsources", "clustercloudeventsources/status"]
  }
}

resource "kubernetes_cluster_role" "keda_external_metrics_reader" {
  metadata {
    name   = "${local.app_name}-metrics-reader"
    labels = local.labels
  }

  rule {
    verbs      = ["get"]
    api_groups = ["external.metrics.k8s.io"]
    resources  = ["externalmetrics"]
  }
}

resource "kubernetes_cluster_role" "keda_webhook" {
  metadata {
    name   = "${local.app_name}-webhook"
    labels = local.labels
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["keda.sh"]
    resources  = ["scaledobjects"]
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = ["apps"]
    resources  = ["deployments", "statefulsets"]
  }

  rule {
    verbs      = ["list"]
    api_groups = [""]
    resources  = ["limitranges"]
  }
}

resource "kubernetes_cluster_role_binding" "keda_operator" {
  metadata {
    name   = "${local.app_name}-operator"
    labels = local.labels
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${local.app_name}-operator"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${local.app_name}-operator"
  }
}

resource "kubernetes_cluster_role_binding" "keda_minimal" {
  metadata {
    name   = "${local.app_name}-operator-minimal"
    labels = local.labels
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${local.app_name}-operator"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${local.app_name}-operator-minimal-cluster-role"
  }
}

resource "kubernetes_cluster_role_binding" "keda_system_auth_delegator" {
  metadata {
    name   = "${local.app_name}-system-auth-delegator"
    labels = local.labels
  }

  subject {
    kind      = "ServiceAccount"
    name      = "metrics-server"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
}

resource "kubernetes_cluster_role_binding" "keda_hpa_external_metrics" {
  metadata {
    name   = "${local.app_name}-external-metrics"
    labels = local.labels
  }

  subject {
    kind      = "ServiceAccount"
    name      = "horizontal-pod-autoscaler"
    namespace = "kube-system"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${local.app_name}-metrics-reader"
  }
}

resource "kubernetes_cluster_role_binding" "keda_webhook" {
  metadata {
    name   = "${local.app_name}-webhook"
    labels = local.labels
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${local.app_name}-webhook"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "${local.app_name}-webhook"
  }
}

resource "kubernetes_role" "keda_certs" {
  metadata {
    name      = "${local.app_name}-certs"
    namespace = var.namespace
    labels    = local.labels
  }

  rule {
    verbs      = ["create", "delete", "get", "list", "patch", "update", "watch"]
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
  }
}

resource "kubernetes_role_binding" "keda_certs" {
  metadata {
    name      = "${local.app_name}-certs"
    namespace = var.namespace
    labels    = local.labels
  }

  subject {
    kind      = "ServiceAccount"
    name      = "${local.app_name}-operator"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "${local.app_name}-certs"
  }
}

resource "kubernetes_role_binding" "keda_auth_reader" {
  metadata {
    name      = "${local.app_name}-auth-reader"
    namespace = "kube-system"
    labels    = local.labels
  }

  subject {
    kind      = "ServiceAccount"
    name      = "metrics-server"
    namespace = var.namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "extension-apiserver-authentication-reader"
  }
}
