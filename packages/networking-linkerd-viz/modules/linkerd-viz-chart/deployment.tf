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


resource "kubernetes_deployment" "metrics_api" {
  metadata {
    name      = "metrics-api"
    namespace = "linkerd-viz"

    labels = {
      "app.kubernetes.io/name"    = "metrics-api"
      "app.kubernetes.io/part-of" = "Linkerd"
      "app.kubernetes.io/version" = "edge-25.8.5"
      component                   = "metrics-api"
      "linkerd.io/extension"      = "viz"
    }

    annotations = {
      "config.linkerd.io/proxy-await" = "enabled"
      "linkerd.io/created-by"         = "linkerd/cli edge-25.8.5"
      "linkerd.io/inject"             = "enabled"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        component              = "metrics-api"
        "linkerd.io/extension" = "viz"
      }
    }

    template {
      metadata {
        labels = {
          component              = "metrics-api"
          "linkerd.io/extension" = "viz"
        }

        annotations = {
          "cluster-autoscaler.kubernetes.io/safe-to-evict"         = "true"
          "config.alpha.linkerd.io/proxy-wait-before-exit-seconds" = "0"
          "linkerd.io/created-by"                                  = "linkerd/cli edge-25.8.5"
          "linkerd.io/inject"                                      = "enabled"
        }
      }

      spec {
        volume {
          name = "kube-api-access"

          projected {
            sources {
              service_account_token {
                expiration_seconds = 3607
                path               = "token"
              }
            }

            sources {
              config_map {
                name = "kube-root-ca.crt"

                items {
                  key  = "ca.crt"
                  path = "ca.crt"
                }
              }
            }

            sources {
              downward_api {
                items {
                  path = "namespace"

                  field_ref {
                    api_version = "v1"
                    field_path  = "metadata.namespace"
                  }
                }
              }
            }

            default_mode = "0644"
          }
        }

        container {
          name  = "metrics-api"
          image = "cr.l5d.io/linkerd/metrics-api:edge-25.8.5"
          args  = ["-controller-namespace=linkerd", "-log-level=info", "-log-format=plain", "-cluster-domain=cluster.local", "-prometheus-url=http://prometheus.linkerd-viz.svc.cluster.local:9090", "-enable-pprof=false"]

          port {
            name           = "http"
            container_port = 8085
          }

          port {
            name           = "admin"
            container_port = 9995
          }

          volume_mount {
            name       = "kube-api-access"
            read_only  = true
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
          }

          liveness_probe {
            http_get {
              path = "/ping"
              port = "9995"
            }

            initial_delay_seconds = 10
          }

          readiness_probe {
            http_get {
              path = "/ready"
              port = "9995"
            }

            failure_threshold = 7
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            capabilities {
              drop = ["ALL"]
            }

            run_as_user               = 2103
            run_as_group              = 2103
            run_as_non_root           = true
            read_only_root_filesystem = true

            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "metrics-api"

        security_context {
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }
      }
    }

    revision_history_limit = 10
  }
}

resource "kubernetes_deployment" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "linkerd-viz"

    labels = {
      "app.kubernetes.io/name"    = "prometheus"
      "app.kubernetes.io/part-of" = "Linkerd"
      "app.kubernetes.io/version" = "edge-25.8.5"
      component                   = "prometheus"
      "linkerd.io/extension"      = "viz"
      namespace                   = "linkerd-viz"
    }

    annotations = {
      "config.linkerd.io/proxy-await" = "enabled"
      "linkerd.io/created-by"         = "linkerd/cli edge-25.8.5"
      "linkerd.io/inject"             = "enabled"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        component              = "prometheus"
        "linkerd.io/extension" = "viz"
        namespace              = "linkerd-viz"
      }
    }

    template {
      metadata {
        labels = {
          component              = "prometheus"
          "linkerd.io/extension" = "viz"
          namespace              = "linkerd-viz"
        }

        annotations = {
          "config.alpha.linkerd.io/proxy-wait-before-exit-seconds" = "0"
          "linkerd.io/created-by"                                  = "linkerd/cli edge-25.8.5"
          "linkerd.io/inject"                                      = "enabled"
        }
      }

      spec {
        volume {
          name      = "data"
          empty_dir = {}
        }

        volume {
          name = "prometheus-config"

          config_map {
            name = "prometheus-config"
          }
        }

        volume {
          name = "kube-api-access"

          projected {
            sources {
              service_account_token {
                expiration_seconds = 3607
                path               = "token"
              }
            }

            sources {
              config_map {
                name = "kube-root-ca.crt"

                items {
                  key  = "ca.crt"
                  path = "ca.crt"
                }
              }
            }

            sources {
              downward_api {
                items {
                  path = "namespace"

                  field_ref {
                    api_version = "v1"
                    field_path  = "metadata.namespace"
                  }
                }
              }
            }

            default_mode = "0644"
          }
        }

        container {
          name  = "prometheus"
          image = "prom/prometheus:v2.55.1"
          args  = ["--log.level=info", "--log.format=logfmt", "--config.file=/etc/prometheus/prometheus.yml", "--storage.tsdb.path=/data", "--storage.tsdb.retention.time=6h"]

          port {
            name           = "admin"
            container_port = 9090
          }

          volume_mount {
            name       = "data"
            mount_path = "/data"
          }

          volume_mount {
            name       = "prometheus-config"
            read_only  = true
            mount_path = "/etc/prometheus/prometheus.yml"
            sub_path   = "prometheus.yml"
          }

          volume_mount {
            name       = "kube-api-access"
            read_only  = true
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
          }

          liveness_probe {
            http_get {
              path = "/-/healthy"
              port = "9090"
            }

            initial_delay_seconds = 30
            timeout_seconds       = 30
          }

          readiness_probe {
            http_get {
              path = "/-/ready"
              port = "9090"
            }

            initial_delay_seconds = 30
            timeout_seconds       = 30
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            capabilities {
              drop = ["ALL"]
            }

            run_as_user               = 65534
            run_as_group              = 65534
            run_as_non_root           = true
            read_only_root_filesystem = true

            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "prometheus"

        security_context {
          fs_group = 65534

          seccomp_profile {
            type = "RuntimeDefault"
          }
        }
      }
    }

    revision_history_limit = 10
  }
}

resource "kubernetes_deployment" "tap" {
  metadata {
    name      = "tap"
    namespace = "linkerd-viz"

    labels = {
      "app.kubernetes.io/name"    = "tap"
      "app.kubernetes.io/part-of" = "Linkerd"
      "app.kubernetes.io/version" = "edge-25.8.5"
      component                   = "tap"
      "linkerd.io/extension"      = "viz"
      namespace                   = "linkerd-viz"
    }

    annotations = {
      "config.linkerd.io/proxy-await" = "enabled"
      "linkerd.io/created-by"         = "linkerd/cli edge-25.8.5"
      "linkerd.io/inject"             = "enabled"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        component              = "tap"
        "linkerd.io/extension" = "viz"
        namespace              = "linkerd-viz"
      }
    }

    template {
      metadata {
        labels = {
          component              = "tap"
          "linkerd.io/extension" = "viz"
          namespace              = "linkerd-viz"
        }

        annotations = {
          "cluster-autoscaler.kubernetes.io/safe-to-evict"         = "true"
          "config.alpha.linkerd.io/proxy-wait-before-exit-seconds" = "0"
          "linkerd.io/created-by"                                  = "linkerd/cli edge-25.8.5"
          "linkerd.io/inject"                                      = "enabled"
        }
      }

      spec {
        volume {
          name = "tls"

          secret {
            secret_name = "tap-k8s-tls"
          }
        }

        volume {
          name = "kube-api-access"

          projected {
            sources {
              service_account_token {
                expiration_seconds = 3607
                path               = "token"
              }
            }

            sources {
              config_map {
                name = "kube-root-ca.crt"

                items {
                  key  = "ca.crt"
                  path = "ca.crt"
                }
              }
            }

            sources {
              downward_api {
                items {
                  path = "namespace"

                  field_ref {
                    api_version = "v1"
                    field_path  = "metadata.namespace"
                  }
                }
              }
            }

            default_mode = "0644"
          }
        }

        container {
          name  = "tap"
          image = "cr.l5d.io/linkerd/tap:edge-25.8.5"
          args  = ["api", "-api-namespace=linkerd", "-log-level=info", "-log-format=plain", "-identity-trust-domain=cluster.local", "-enable-pprof=false"]

          port {
            name           = "grpc"
            container_port = 8088
          }

          port {
            name           = "apiserver"
            container_port = 8089
          }

          port {
            name           = "admin"
            container_port = 9998
          }

          volume_mount {
            name       = "tls"
            read_only  = true
            mount_path = "/var/run/linkerd/tls"
          }

          volume_mount {
            name       = "kube-api-access"
            read_only  = true
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
          }

          liveness_probe {
            http_get {
              path = "/ping"
              port = "9998"
            }

            initial_delay_seconds = 10
          }

          readiness_probe {
            http_get {
              path = "/ready"
              port = "9998"
            }

            failure_threshold = 7
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            capabilities {
              drop = ["ALL"]
            }

            run_as_user               = 2103
            run_as_group              = 2103
            run_as_non_root           = true
            read_only_root_filesystem = true

            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "tap"

        security_context {
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }
      }
    }

    revision_history_limit = 10
  }
}

resource "kubernetes_deployment" "tap_injector" {
  metadata {
    name      = "tap-injector"
    namespace = "linkerd-viz"

    labels = {
      "app.kubernetes.io/name"    = "tap-injector"
      "app.kubernetes.io/part-of" = "Linkerd"
      component                   = "tap-injector"
      "linkerd.io/extension"      = "viz"
    }

    annotations = {
      "config.linkerd.io/proxy-await" = "enabled"
      "linkerd.io/created-by"         = "linkerd/cli edge-25.8.5"
      "linkerd.io/inject"             = "enabled"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        component = "tap-injector"
      }
    }

    template {
      metadata {
        labels = {
          component              = "tap-injector"
          "linkerd.io/extension" = "viz"
        }

        annotations = {
          "cluster-autoscaler.kubernetes.io/safe-to-evict"         = "true"
          "config.alpha.linkerd.io/proxy-wait-before-exit-seconds" = "0"
          "linkerd.io/created-by"                                  = "linkerd/cli edge-25.8.5"
          "linkerd.io/inject"                                      = "enabled"
        }
      }

      spec {
        volume {
          name = "tls"

          secret {
            secret_name = "tap-injector-k8s-tls"
          }
        }

        volume {
          name = "kube-api-access"

          projected {
            sources {
              service_account_token {
                expiration_seconds = 3607
                path               = "token"
              }
            }

            sources {
              config_map {
                name = "kube-root-ca.crt"

                items {
                  key  = "ca.crt"
                  path = "ca.crt"
                }
              }
            }

            sources {
              downward_api {
                items {
                  path = "namespace"

                  field_ref {
                    api_version = "v1"
                    field_path  = "metadata.namespace"
                  }
                }
              }
            }

            default_mode = "0644"
          }
        }

        container {
          name  = "tap-injector"
          image = "cr.l5d.io/linkerd/tap:edge-25.8.5"
          args  = ["injector", "-tap-service-name=tap.linkerd-viz.serviceaccount.identity.linkerd.cluster.local", "-log-level=info", "-log-format=plain", "-enable-pprof=false"]

          port {
            name           = "tap-injector"
            container_port = 8443
          }

          port {
            name           = "admin"
            container_port = 9995
          }

          volume_mount {
            name       = "tls"
            read_only  = true
            mount_path = "/var/run/linkerd/tls"
          }

          volume_mount {
            name       = "kube-api-access"
            read_only  = true
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
          }

          liveness_probe {
            http_get {
              path = "/ping"
              port = "9995"
            }

            initial_delay_seconds = 10
          }

          readiness_probe {
            http_get {
              path = "/ready"
              port = "9995"
            }

            failure_threshold = 7
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            capabilities {
              drop = ["ALL"]
            }

            run_as_user               = 2103
            run_as_group              = 2103
            run_as_non_root           = true
            read_only_root_filesystem = true

            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "tap-injector"

        security_context {
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }
      }
    }

    revision_history_limit = 10
  }
}

resource "kubernetes_deployment" "web" {
  metadata {
    name      = "web"
    namespace = "linkerd-viz"

    labels = {
      "app.kubernetes.io/name"    = "web"
      "app.kubernetes.io/part-of" = "Linkerd"
      "app.kubernetes.io/version" = "edge-25.8.5"
      component                   = "web"
      "linkerd.io/extension"      = "viz"
      namespace                   = "linkerd-viz"
    }

    annotations = {
      "config.linkerd.io/proxy-await" = "enabled"
      "linkerd.io/created-by"         = "linkerd/cli edge-25.8.5"
      "linkerd.io/inject"             = "enabled"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        component              = "web"
        "linkerd.io/extension" = "viz"
        namespace              = "linkerd-viz"
      }
    }

    template {
      metadata {
        labels = {
          component              = "web"
          "linkerd.io/extension" = "viz"
          namespace              = "linkerd-viz"
        }

        annotations = {
          "cluster-autoscaler.kubernetes.io/safe-to-evict"         = "true"
          "config.alpha.linkerd.io/proxy-wait-before-exit-seconds" = "0"
          "linkerd.io/created-by"                                  = "linkerd/cli edge-25.8.5"
          "linkerd.io/inject"                                      = "enabled"
        }
      }

      spec {
        volume {
          name = "kube-api-access"

          projected {
            sources {
              service_account_token {
                expiration_seconds = 3607
                path               = "token"
              }
            }

            sources {
              config_map {
                name = "kube-root-ca.crt"

                items {
                  key  = "ca.crt"
                  path = "ca.crt"
                }
              }
            }

            sources {
              downward_api {
                items {
                  path = "namespace"

                  field_ref {
                    api_version = "v1"
                    field_path  = "metadata.namespace"
                  }
                }
              }
            }

            default_mode = "0644"
          }
        }

        container {
          name  = "web"
          image = "cr.l5d.io/linkerd/web:edge-25.8.5"
          args  = ["-linkerd-metrics-api-addr=metrics-api.linkerd-viz.svc.cluster.local:8085", "-cluster-domain=cluster.local", "-controller-namespace=linkerd", "-log-level=info", "-log-format=plain", "-enforced-host=^(localhost|127\\.0\\.0\\.1|web\\.linkerd-viz\\.svc\\.cluster\\.local|web\\.linkerd-viz\\.svc|\\[::1\\])(:\\d+)?$", "-enable-pprof=false"]

          port {
            name           = "http"
            container_port = 8084
          }

          port {
            name           = "admin"
            container_port = 9994
          }

          volume_mount {
            name       = "kube-api-access"
            read_only  = true
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
          }

          liveness_probe {
            http_get {
              path = "/ping"
              port = "9994"
            }

            initial_delay_seconds = 10
          }

          readiness_probe {
            http_get {
              path = "/ready"
              port = "9994"
            }

            failure_threshold = 7
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            capabilities {
              drop = ["ALL"]
            }

            run_as_user               = 2103
            run_as_group              = 2103
            run_as_non_root           = true
            read_only_root_filesystem = true

            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "web"

        security_context {
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }
      }
    }

    revision_history_limit = 10
  }
}

