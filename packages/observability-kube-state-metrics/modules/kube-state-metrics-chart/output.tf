resource "kubernetes_network_policy" "release_name_kube_state_metrics" {
  metadata {
    name      = "release-name-kube-state-metrics"
    namespace = "kube-state-metrics"

    labels = {
      "app.kubernetes.io/component"  = "metrics"
      "app.kubernetes.io/instance"   = "release-name"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "kube-state-metrics"
      "app.kubernetes.io/part-of"    = "kube-state-metrics"
      "app.kubernetes.io/version"    = "2.17.0"
      "helm.sh/chart"                = "kube-state-metrics-6.4.1"
    }
  }

  spec {
    pod_selector {
      match_labels = {
        "app.kubernetes.io/instance" = "release-name"
        "app.kubernetes.io/name"     = "kube-state-metrics"
      }
    }

    ingress {
      ports {
        protocol = "TCP"
        port     = "http"
      }
    }

    policy_types = ["Ingress", "Egress"]
  }
}

resource "kubernetes_service_account" "release_name_kube_state_metrics" {
  metadata {
    name      = "release-name-kube-state-metrics"
    namespace = "kube-state-metrics"

    labels = {
      "app.kubernetes.io/component"  = "metrics"
      "app.kubernetes.io/instance"   = "release-name"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "kube-state-metrics"
      "app.kubernetes.io/part-of"    = "kube-state-metrics"
      "app.kubernetes.io/version"    = "2.17.0"
      "helm.sh/chart"                = "kube-state-metrics-6.4.1"
    }
  }

  automount_service_account_token = true
}

resource "kubernetes_config_map" "release_name_kube_state_metrics_customresourcestate_config" {
  metadata {
    name      = "release-name-kube-state-metrics-customresourcestate-config"
    namespace = "kube-state-metrics"

    labels = {
      "app.kubernetes.io/component"  = "metrics"
      "app.kubernetes.io/instance"   = "release-name"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "kube-state-metrics"
      "app.kubernetes.io/part-of"    = "kube-state-metrics"
      "app.kubernetes.io/version"    = "2.17.0"
      "helm.sh/chart"                = "kube-state-metrics-6.4.1"
    }
  }

  data = {
    "config.yaml" = "{}\n"
  }
}

resource "kubernetes_cluster_role" "release_name_kube_state_metrics" {
  metadata {
    name = "release-name-kube-state-metrics"

    labels = {
      "app.kubernetes.io/component"  = "metrics"
      "app.kubernetes.io/instance"   = "release-name"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "kube-state-metrics"
      "app.kubernetes.io/part-of"    = "kube-state-metrics"
      "app.kubernetes.io/version"    = "2.17.0"
      "helm.sh/chart"                = "kube-state-metrics-6.4.1"
    }
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["certificates.k8s.io"]
    resources  = ["certificatesigningrequests"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = [""]
    resources  = ["configmaps"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["batch"]
    resources  = ["cronjobs"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["apps"]
    resources  = ["daemonsets"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["apps"]
    resources  = ["deployments"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = [""]
    resources  = ["endpoints"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["autoscaling"]
    resources  = ["horizontalpodautoscalers"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["ingresses"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["batch"]
    resources  = ["jobs"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["coordination.k8s.io"]
    resources  = ["leases"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = [""]
    resources  = ["limitranges"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["admissionregistration.k8s.io"]
    resources  = ["mutatingwebhookconfigurations"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = [""]
    resources  = ["namespaces"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["networking.k8s.io"]
    resources  = ["networkpolicies"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = [""]
    resources  = ["nodes"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = [""]
    resources  = ["persistentvolumeclaims"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = [""]
    resources  = ["persistentvolumes"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["policy"]
    resources  = ["poddisruptionbudgets"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = [""]
    resources  = ["pods"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["apps"]
    resources  = ["replicasets"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = [""]
    resources  = ["replicationcontrollers"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = [""]
    resources  = ["resourcequotas"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = [""]
    resources  = ["secrets"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = [""]
    resources  = ["services"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["apps"]
    resources  = ["statefulsets"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["storage.k8s.io"]
    resources  = ["storageclasses"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["admissionregistration.k8s.io"]
    resources  = ["validatingwebhookconfigurations"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["storage.k8s.io"]
    resources  = ["volumeattachments"]
  }

  rule {
    verbs      = ["list", "watch"]
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
  }
}

resource "kubernetes_cluster_role_binding" "release_name_kube_state_metrics" {
  metadata {
    name = "release-name-kube-state-metrics"

    labels = {
      "app.kubernetes.io/component"  = "metrics"
      "app.kubernetes.io/instance"   = "release-name"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "kube-state-metrics"
      "app.kubernetes.io/part-of"    = "kube-state-metrics"
      "app.kubernetes.io/version"    = "2.17.0"
      "helm.sh/chart"                = "kube-state-metrics-6.4.1"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "release-name-kube-state-metrics"
    namespace = "kube-state-metrics"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "release-name-kube-state-metrics"
  }
}

resource "kubernetes_role" "stsdiscovery_release_name_kube_state_metrics" {
  metadata {
    name      = "stsdiscovery-release-name-kube-state-metrics"
    namespace = "kube-state-metrics"

    labels = {
      "app.kubernetes.io/component"  = "metrics"
      "app.kubernetes.io/instance"   = "release-name"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "kube-state-metrics"
      "app.kubernetes.io/part-of"    = "kube-state-metrics"
      "app.kubernetes.io/version"    = "2.17.0"
      "helm.sh/chart"                = "kube-state-metrics-6.4.1"
    }
  }

  rule {
    verbs      = ["get"]
    api_groups = [""]
    resources  = ["pods"]
  }

  rule {
    verbs          = ["get", "list", "watch"]
    api_groups     = ["apps"]
    resources      = ["statefulsets"]
    resource_names = ["release-name-kube-state-metrics"]
  }
}

resource "kubernetes_role_binding" "stsdiscovery_release_name_kube_state_metrics" {
  metadata {
    name      = "stsdiscovery-release-name-kube-state-metrics"
    namespace = "kube-state-metrics"

    labels = {
      "app.kubernetes.io/component"  = "metrics"
      "app.kubernetes.io/instance"   = "release-name"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "kube-state-metrics"
      "app.kubernetes.io/part-of"    = "kube-state-metrics"
      "app.kubernetes.io/version"    = "2.17.0"
      "helm.sh/chart"                = "kube-state-metrics-6.4.1"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "release-name-kube-state-metrics"
    namespace = "kube-state-metrics"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "stsdiscovery-release-name-kube-state-metrics"
  }
}

resource "kubernetes_service" "release_name_kube_state_metrics" {
  metadata {
    name      = "release-name-kube-state-metrics"
    namespace = "kube-state-metrics"

    labels = {
      "app.kubernetes.io/component"  = "metrics"
      "app.kubernetes.io/instance"   = "release-name"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "kube-state-metrics"
      "app.kubernetes.io/part-of"    = "kube-state-metrics"
      "app.kubernetes.io/version"    = "2.17.0"
      "helm.sh/chart"                = "kube-state-metrics-6.4.1"
    }

    annotations = {
      "prometheus.io/scrape" = "true"
    }
  }

  spec {
    port {
      name        = "http"
      protocol    = "TCP"
      port        = 8080
      target_port = "http"
    }

    selector = {
      "app.kubernetes.io/instance" = "release-name"
      "app.kubernetes.io/name"     = "kube-state-metrics"
    }

    cluster_ip = "None"
    type       = "ClusterIP"
  }
}

resource "kubernetes_stateful_set" "release_name_kube_state_metrics" {
  metadata {
    name      = "release-name-kube-state-metrics"
    namespace = "kube-state-metrics"

    labels = {
      "app.kubernetes.io/component"  = "metrics"
      "app.kubernetes.io/instance"   = "release-name"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "kube-state-metrics"
      "app.kubernetes.io/part-of"    = "kube-state-metrics"
      "app.kubernetes.io/version"    = "2.17.0"
      "helm.sh/chart"                = "kube-state-metrics-6.4.1"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        "app.kubernetes.io/instance" = "release-name"
        "app.kubernetes.io/name"     = "kube-state-metrics"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/component"  = "metrics"
          "app.kubernetes.io/instance"   = "release-name"
          "app.kubernetes.io/managed-by" = "Helm"
          "app.kubernetes.io/name"       = "kube-state-metrics"
          "app.kubernetes.io/part-of"    = "kube-state-metrics"
          "app.kubernetes.io/version"    = "2.17.0"
          "helm.sh/chart"                = "kube-state-metrics-6.4.1"
        }
      }

      spec {
        volume {
          name = "customresourcestate-config"

          config_map {
            name = "release-name-kube-state-metrics-customresourcestate-config"
          }
        }

        container {
          name  = "kube-state-metrics"
          image = "registry.k8s.io/kube-state-metrics/kube-state-metrics:v2.17.0"
          args  = ["--port=8080", "--resources=certificatesigningrequests,configmaps,cronjobs,daemonsets,deployments,endpoints,horizontalpodautoscalers,ingresses,jobs,leases,limitranges,mutatingwebhookconfigurations,namespaces,networkpolicies,nodes,persistentvolumeclaims,persistentvolumes,poddisruptionbudgets,pods,replicasets,replicationcontrollers,resourcequotas,secrets,services,statefulsets,storageclasses,validatingwebhookconfigurations,volumeattachments", "--pod=$(POD_NAME)", "--pod-namespace=$(POD_NAMESPACE)", "--custom-resource-state-config-file=/etc/customresourcestate/config.yaml"]

          port {
            name           = "http"
            container_port = 8080
          }

          env {
            name = "POD_NAME"

            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }

          env {
            name = "POD_NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          resources {
            limits = {
              cpu    = "100m"
              memory = "64Mi"
            }

            requests = {
              cpu    = "10m"
              memory = "32Mi"
            }
          }

          volume_mount {
            name       = "customresourcestate-config"
            read_only  = true
            mount_path = "/etc/customresourcestate"
          }

          liveness_probe {
            http_get {
              path   = "/livez"
              port   = "8080"
              scheme = "HTTP"
            }

            initial_delay_seconds = 5
            timeout_seconds       = 5
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
          }

          readiness_probe {
            http_get {
              path   = "/readyz"
              port   = "8081"
              scheme = "HTTP"
            }

            initial_delay_seconds = 5
            timeout_seconds       = 5
            period_seconds        = 10
            success_threshold     = 1
            failure_threshold     = 3
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            capabilities {
              drop = ["ALL"]
            }

            read_only_root_filesystem = true
          }
        }

        dns_policy                      = "ClusterFirst"
        service_account_name            = "release-name-kube-state-metrics"
        automount_service_account_token = true

        security_context {
          run_as_user     = 65534
          run_as_group    = 65534
          run_as_non_root = true
          fs_group        = 65534

          seccomp_profile {
            type = "RuntimeDefault"
          }
        }

        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              label_selector {
                match_labels = {
                  "app.kubernetes.io/name" = "kube-state-metrics"
                }
              }

              topology_key = "kubernetes.io/hostname"
            }
          }
        }
      }
    }

    service_name           = "release-name-kube-state-metrics"
    revision_history_limit = 10
  }
}

