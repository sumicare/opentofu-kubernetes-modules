resource "kubernetes_service_account" "release_name_cloudcost_exporter" {
  metadata {
    name = "release-name-cloudcost-exporter"

    labels = {
      "app.kubernetes.io/instance"   = "release-name"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "cloudcost-exporter"
      "app.kubernetes.io/version"    = "0.10.0"
      "helm.sh/chart"                = "cloudcost-exporter-1.0.6"
      name                           = "cloudcost-exporter"
    }
  }
}

resource "kubernetes_service" "release_name_cloudcost_exporter" {
  metadata {
    name = "release-name-cloudcost-exporter"

    labels = {
      "app.kubernetes.io/instance"   = "release-name"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "cloudcost-exporter"
      "app.kubernetes.io/version"    = "0.10.0"
      "helm.sh/chart"                = "cloudcost-exporter-1.0.6"
      name                           = "cloudcost-exporter"
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
      "app.kubernetes.io/name"     = "cloudcost-exporter"
      name                         = "cloudcost-exporter"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_deployment" "release_name_cloudcost_exporter" {
  metadata {
    name = "release-name-cloudcost-exporter"

    labels = {
      "app.kubernetes.io/instance"   = "release-name"
      "app.kubernetes.io/managed-by" = "Helm"
      "app.kubernetes.io/name"       = "cloudcost-exporter"
      "app.kubernetes.io/version"    = "0.10.0"
      "helm.sh/chart"                = "cloudcost-exporter-1.0.6"
      name                           = "cloudcost-exporter"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        "app.kubernetes.io/instance" = "release-name"
        "app.kubernetes.io/name"     = "cloudcost-exporter"
        name                         = "cloudcost-exporter"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/instance" = "release-name"
          "app.kubernetes.io/name"     = "cloudcost-exporter"
          name                         = "cloudcost-exporter"
        }
      }

      spec {
        container {
          name  = "cloudcost-exporter"
          image = "grafana/cloudcost-exporter:0.10.0"

          port {
            name           = "http"
            container_port = 8080
            protocol       = "TCP"
          }

          resources {
            limits = {
              cpu    = "2"
              memory = "2Gi"
            }

            requests = {
              cpu    = "1"
              memory = "1Gi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = "http"
            }
          }

          readiness_probe {
            http_get {
              path = "/"
              port = "http"
            }
          }

          image_pull_policy = "IfNotPresent"
        }

        service_account_name = "release-name-cloudcost-exporter"

        security_context {
          fs_group = 10001
        }
      }
    }

    min_ready_seconds      = 10
    revision_history_limit = 10
  }
}

