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


resource "kubernetes_cluster_role" "linkerd_linkerd_viz_metrics_api" {
  metadata {
    name = "linkerd-linkerd-viz-metrics-api"

    labels = {
      component              = "metrics-api"
      "linkerd.io/extension" = "viz"
    }
  }

  rule {
    verbs      = ["list", "get", "watch"]
    api_groups = ["extensions", "apps"]
    resources  = ["daemonsets", "deployments", "replicasets", "statefulsets"]
  }

  rule {
    verbs      = ["list", "get", "watch"]
    api_groups = ["extensions", "batch"]
    resources  = ["cronjobs", "jobs"]
  }

  rule {
    verbs      = ["list", "get", "watch"]
    api_groups = [""]
    resources  = ["pods", "endpoints", "services", "replicationcontrollers", "namespaces"]
  }

  rule {
    verbs      = ["list", "get", "watch"]
    api_groups = ["linkerd.io"]
    resources  = ["serviceprofiles"]
  }

  rule {
    verbs      = ["list", "get"]
    api_groups = ["policy.linkerd.io"]
    resources  = ["servers", "serverauthorizations", "authorizationpolicies", "httproutes"]
  }
}

resource "kubernetes_cluster_role_binding" "linkerd_linkerd_viz_metrics_api" {
  metadata {
    name = "linkerd-linkerd-viz-metrics-api"

    labels = {
      component              = "metrics-api"
      "linkerd.io/extension" = "viz"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "metrics-api"
    namespace = "linkerd-viz"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "linkerd-linkerd-viz-metrics-api"
  }
}

resource "kubernetes_cluster_role" "linkerd_linkerd_viz_prometheus" {
  metadata {
    name = "linkerd-linkerd-viz-prometheus"

    labels = {
      component              = "prometheus"
      "linkerd.io/extension" = "viz"
    }
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["nodes", "nodes/proxy", "pods"]
  }
}

resource "kubernetes_cluster_role_binding" "linkerd_linkerd_viz_prometheus" {
  metadata {
    name = "linkerd-linkerd-viz-prometheus"

    labels = {
      component              = "prometheus"
      "linkerd.io/extension" = "viz"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "prometheus"
    namespace = "linkerd-viz"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "linkerd-linkerd-viz-prometheus"
  }
}

resource "kubernetes_cluster_role" "linkerd_linkerd_viz_tap" {
  metadata {
    name = "linkerd-linkerd-viz-tap"

    labels = {
      component              = "tap"
      "linkerd.io/extension" = "viz"
    }
  }

  rule {
    verbs      = ["list", "get", "watch"]
    api_groups = [""]
    resources  = ["pods", "services", "replicationcontrollers", "namespaces", "nodes"]
  }

  rule {
    verbs      = ["list", "get", "watch"]
    api_groups = ["extensions", "apps"]
    resources  = ["daemonsets", "deployments", "replicasets", "statefulsets"]
  }

  rule {
    verbs      = ["list", "get", "watch"]
    api_groups = ["extensions", "batch"]
    resources  = ["cronjobs", "jobs"]
  }
}

resource "kubernetes_cluster_role" "linkerd_linkerd_viz_tap_admin" {
  metadata {
    name = "linkerd-linkerd-viz-tap-admin"

    labels = {
      component              = "tap"
      "linkerd.io/extension" = "viz"
    }
  }

  rule {
    verbs      = ["list"]
    api_groups = [""]
    resources  = ["namespaces"]
  }

  rule {
    verbs      = ["watch"]
    api_groups = ["tap.linkerd.io"]
    resources  = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "linkerd_linkerd_viz_tap" {
  metadata {
    name = "linkerd-linkerd-viz-tap"

    labels = {
      component              = "tap"
      "linkerd.io/extension" = "viz"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "tap"
    namespace = "linkerd-viz"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "linkerd-linkerd-viz-tap"
  }
}

resource "kubernetes_cluster_role_binding" "linkerd_linkerd_viz_tap_auth_delegator" {
  metadata {
    name = "linkerd-linkerd-viz-tap-auth-delegator"

    labels = {
      component              = "tap"
      "linkerd.io/extension" = "viz"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "tap"
    namespace = "linkerd-viz"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
  }
}

resource "kubernetes_role_binding" "linkerd_linkerd_viz_tap_auth_reader" {
  metadata {
    name      = "linkerd-linkerd-viz-tap-auth-reader"
    namespace = "kube-system"

    labels = {
      component              = "tap"
      "linkerd.io/extension" = "viz"
      namespace              = "linkerd-viz"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "tap"
    namespace = "linkerd-viz"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "extension-apiserver-authentication-reader"
  }
}

resource "kubernetes_role" "web" {
  metadata {
    name      = "web"
    namespace = "linkerd"

    labels = {
      component              = "web"
      "linkerd.io/extension" = "viz"
      namespace              = "linkerd"
    }
  }

  rule {
    verbs          = ["get"]
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["linkerd-config"]
  }

  rule {
    verbs      = ["get"]
    api_groups = [""]
    resources  = ["namespaces", "configmaps"]
  }

  rule {
    verbs      = ["list"]
    api_groups = [""]
    resources  = ["serviceaccounts", "pods"]
  }

  rule {
    verbs      = ["list"]
    api_groups = ["apps"]
    resources  = ["replicasets"]
  }
}

resource "kubernetes_role_binding" "web" {
  metadata {
    name      = "web"
    namespace = "linkerd"

    labels = {
      component              = "web"
      "linkerd.io/extension" = "viz"
      namespace              = "linkerd"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "web"
    namespace = "linkerd-viz"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "web"
  }
}

resource "kubernetes_cluster_role" "linkerd_linkerd_viz_web_check" {
  metadata {
    name = "linkerd-linkerd-viz-web-check"

    labels = {
      component              = "web"
      "linkerd.io/extension" = "viz"
    }
  }

  rule {
    verbs      = ["list"]
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["clusterroles", "clusterrolebindings"]
  }

  rule {
    verbs      = ["list"]
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
  }

  rule {
    verbs      = ["list"]
    api_groups = ["admissionregistration.k8s.io"]
    resources  = ["mutatingwebhookconfigurations", "validatingwebhookconfigurations"]
  }

  rule {
    verbs      = ["list"]
    api_groups = ["linkerd.io"]
    resources  = ["serviceprofiles"]
  }

  rule {
    verbs      = ["list"]
    api_groups = [""]
    resources  = ["nodes", "pods", "services"]
  }

  rule {
    verbs      = ["get"]
    api_groups = ["apiregistration.k8s.io"]
    resources  = ["apiservices"]
  }
}

resource "kubernetes_cluster_role_binding" "linkerd_linkerd_viz_web_check" {
  metadata {
    name = "linkerd-linkerd-viz-web-check"

    labels = {
      component              = "web"
      "linkerd.io/extension" = "viz"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "web"
    namespace = "linkerd-viz"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "linkerd-linkerd-viz-web-check"
  }
}

resource "kubernetes_cluster_role_binding" "linkerd_linkerd_viz_web_admin" {
  metadata {
    name = "linkerd-linkerd-viz-web-admin"

    labels = {
      component              = "web"
      "linkerd.io/extension" = "viz"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "web"
    namespace = "linkerd-viz"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "linkerd-linkerd-viz-tap-admin"
  }
}

resource "kubernetes_cluster_role" "linkerd_linkerd_viz_web_api" {
  metadata {
    name = "linkerd-linkerd-viz-web-api"

    labels = {
      component              = "web"
      "linkerd.io/extension" = "viz"
    }
  }

  rule {
    verbs      = ["list"]
    api_groups = [""]
    resources  = ["namespaces"]
  }
}

resource "kubernetes_cluster_role_binding" "linkerd_linkerd_viz_web_api" {
  metadata {
    name = "linkerd-linkerd-viz-web-api"

    labels = {
      component              = "web"
      "linkerd.io/extension" = "viz"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "web"
    namespace = "linkerd-viz"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "linkerd-linkerd-viz-web-api"
  }
}

resource "kubernetes_cluster_role" "linkerd_tap_injector" {
  metadata {
    name = "linkerd-tap-injector"

    labels = {
      "linkerd.io/extension" = "viz"
    }
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["namespaces"]
  }
}

resource "kubernetes_cluster_role_binding" "linkerd_tap_injector" {
  metadata {
    name = "linkerd-tap-injector"

    labels = {
      "linkerd.io/extension" = "viz"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "tap-injector"
    namespace = "linkerd-viz"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "linkerd-tap-injector"
  }
}

