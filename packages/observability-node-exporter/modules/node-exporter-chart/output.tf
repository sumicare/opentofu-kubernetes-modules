resource "kubernetes_network_policy" "release_name_prometheus_node_exporter" {
  metadata {
    name      = "release-name-prometheus-node-exporter"
    namespace = "node-exporter"

    labels = {
      "app.kubernetes.io/component"  = "metrics"
      "app.kubernetes.io/instance"   = "release-name"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "prometheus-node-exporter"
      "app.kubernetes.io/part-of"    = "prometheus-node-exporter"
      "app.kubernetes.io/version"    = "1.10.2"
      "helm.sh/chart"                = "prometheus-node-exporter-4.49.1"
    }

    annotations = {
      "prometheus.io/scrape" = "true"
    }
  }

  spec {
    pod_selector {
      match_labels = {
        "app.kubernetes.io/instance" = "release-name"
        "app.kubernetes.io/name"     = "prometheus-node-exporter"
      }
    }

    ingress {
      ports {
        port = "9100"
      }
    }

    policy_types = ["Egress", "Ingress"]
  }
}

resource "kubernetes_service_account" "release_name_prometheus_node_exporter" {
  metadata {
    name      = "release-name-prometheus-node-exporter"
    namespace = "node-exporter"

    labels = {
      "app.kubernetes.io/component"  = "metrics"
      "app.kubernetes.io/instance"   = "release-name"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "prometheus-node-exporter"
      "app.kubernetes.io/part-of"    = "prometheus-node-exporter"
      "app.kubernetes.io/version"    = "1.10.2"
      "helm.sh/chart"                = "prometheus-node-exporter-4.49.1"
    }
  }
}

resource "kubernetes_service" "release_name_prometheus_node_exporter" {
  metadata {
    name      = "release-name-prometheus-node-exporter"
    namespace = "node-exporter"

    labels = {
      "app.kubernetes.io/component"  = "metrics"
      "app.kubernetes.io/instance"   = "release-name"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "prometheus-node-exporter"
      "app.kubernetes.io/part-of"    = "prometheus-node-exporter"
      "app.kubernetes.io/version"    = "1.10.2"
      "helm.sh/chart"                = "prometheus-node-exporter-4.49.1"
    }

    annotations = {
      "prometheus.io/scrape" = "true"
    }
  }

  spec {
    port {
      name        = "metrics"
      protocol    = "TCP"
      port        = 9100
      target_port = "9100"
    }

    selector = {
      "app.kubernetes.io/instance" = "release-name"
      "app.kubernetes.io/name"     = "prometheus-node-exporter"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_daemonset" "release_name_prometheus_node_exporter" {
  metadata {
    name      = "release-name-prometheus-node-exporter"
    namespace = "node-exporter"

    labels = {
      "app.kubernetes.io/component"  = "metrics"
      "app.kubernetes.io/instance"   = "release-name"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "prometheus-node-exporter"
      "app.kubernetes.io/part-of"    = "prometheus-node-exporter"
      "app.kubernetes.io/version"    = "1.10.2"
      "helm.sh/chart"                = "prometheus-node-exporter-4.49.1"
    }
  }

  spec {
    selector {
      match_labels = {
        "app.kubernetes.io/instance" = "release-name"
        "app.kubernetes.io/name"     = "prometheus-node-exporter"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/component"  = "metrics"
          "app.kubernetes.io/instance"   = "release-name"
          "app.kubernetes.io/managed-by" = "Helm"
          "app.kubernetes.io/name"       = "prometheus-node-exporter"
          "app.kubernetes.io/part-of"    = "prometheus-node-exporter"
          "app.kubernetes.io/version"    = "1.10.2"
          "helm.sh/chart"                = "prometheus-node-exporter-4.49.1"
        }

        annotations = {
          "cluster-autoscaler.kubernetes.io/safe-to-evict" = "true"
        }
      }

      spec {
        volume {
          name = "proc"

          host_path {
            path = "/proc"
          }
        }

        volume {
          name = "sys"

          host_path {
            path = "/sys"
          }
        }

        volume {
          name = "root"

          host_path {
            path = "/"
          }
        }

        volume {
          name = "prometheus-node-exporter-tls"

          secret {
            secret_name = "prometheus-node-exporter-tls"

            items {
              key  = "tls.crt"
              path = "tls.crt"
            }

            items {
              key  = "tls.key"
              path = "tls.key"
            }

            items {
              key  = "ca.crt"
              path = "ca.crt"
            }
          }
        }

        container {
          name  = "node-exporter"
          image = "quay.io/prometheus/node-exporter:v1.10.2"
          args  = ["--path.procfs=/host/proc", "--path.sysfs=/host/sys", "--path.rootfs=/host/root", "--path.udev.data=/host/root/run/udev/data", "--web.listen-address=[$(HOST_IP)]:9100"]

          port {
            name           = "metrics"
            container_port = 9100
            protocol       = "TCP"
          }

          env {
            name  = "HOST_IP"
            value = "0.0.0.0"
          }

          resources {
            limits = {
              cpu    = "200m"
              memory = "50Mi"
            }

            requests = {
              cpu    = "100m"
              memory = "30Mi"
            }
          }

          volume_mount {
            name       = "proc"
            read_only  = true
            mount_path = "/host/proc"
          }

          volume_mount {
            name       = "sys"
            read_only  = true
            mount_path = "/host/sys"
          }

          volume_mount {
            name              = "root"
            read_only         = true
            mount_path        = "/host/root"
            mount_propagation = "HostToContainer"
          }

          liveness_probe {
            http_get {
              path   = "/"
              port   = "metrics"
              scheme = "HTTP"
            }

            timeout_seconds   = 1
            period_seconds    = 10
            success_threshold = 1
            failure_threshold = 3
          }

          readiness_probe {
            http_get {
              path   = "/"
              port   = "metrics"
              scheme = "HTTP"
            }

            timeout_seconds   = 1
            period_seconds    = 10
            success_threshold = 1
            failure_threshold = 3
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            read_only_root_filesystem = true
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "release-name-prometheus-node-exporter"
        host_network         = true
        host_pid             = true

        security_context {
          run_as_user     = 65534
          run_as_group    = 65534
          run_as_non_root = true
          fs_group        = 65534
        }

        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "eks.amazonaws.com/compute-type"
                  operator = "NotIn"
                  values   = ["fargate"]
                }

                match_expressions {
                  key      = "type"
                  operator = "NotIn"
                  values   = ["virtual-kubelet"]
                }
              }
            }
          }
        }

        toleration {
          operator = "Exists"
          effect   = "NoSchedule"
        }
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_unavailable = "1"
      }
    }

    revision_history_limit = 10
  }
}

