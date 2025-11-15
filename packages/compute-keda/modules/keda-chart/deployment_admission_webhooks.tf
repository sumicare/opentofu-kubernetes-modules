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


resource "kubernetes_deployment" "keda_admission_webhooks" {
  metadata {
    name      = "${local.app_name}-admission-webhooks"
    namespace = var.namespace
    labels    = local.labels
  }

  spec {
    replicas = var.webhook_replicas

    selector {
      match_labels = local.webhook_labels
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_unavailable = "25%"
        max_surge       = "25%"
      }
    }

    template {
      metadata {
        labels = local.webhook_labels
      }

      spec {
        volume {
          name = "certificates"

          secret {
            secret_name  = "${local.app_name}-certs"
            default_mode = "0644"
          }
        }

        container {
          name    = "${local.app_name}-admission-webhooks"
          image   = "${var.webhook_image}:${var.keda_version}"
          command = ["/keda-admission-webhooks"]
          args = [
            "--zap-log-level=info",
            "--zap-encoder=console",
            "--zap-time-encoding=rfc3339",
            "--cert-dir=/certs",
            "--health-probe-bind-address=:8081",
            "--metrics-bind-address=:8080"
          ]

          port {
            name           = "http"
            container_port = 9443
            protocol       = "TCP"
          }

          env {
            name = "WATCH_NAMESPACE"
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
            limits   = var.resources.limits
            requests = var.resources.requests
          }

          volume_mount {
            name       = "certificates"
            read_only  = true
            mount_path = "/certs"
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = "8081"
            }

            initial_delay_seconds = var.liveness_probe_initial_delay
            timeout_seconds       = var.liveness_probe_timeout
            period_seconds        = var.liveness_probe_period
            success_threshold     = var.liveness_probe_success_threshold
            failure_threshold     = var.liveness_probe_failure_threshold
          }

          readiness_probe {
            http_get {
              path = "/readyz"
              port = "8081"
            }

            initial_delay_seconds = var.readiness_probe_initial_delay
            timeout_seconds       = var.readiness_probe_timeout
            period_seconds        = var.readiness_probe_period
            success_threshold     = var.readiness_probe_success_threshold
            failure_threshold     = var.readiness_probe_failure_threshold
          }

          image_pull_policy = var.image_pull_policy

          security_context {
            capabilities {
              drop = ["ALL"]
            }

            read_only_root_filesystem = true

            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "${local.app_name}-webhook"

        security_context {
          run_as_non_root = true
        }

        affinity {
          node_affinity {
            required_during_scheduling_ignored_during_execution {
              node_selector_term {
                match_expressions {
                  key      = "eks.amazonaws.com/compute-type"
                  operator = "NotIn"
                  values   = ["fargate", "auto"]
                }

                match_expressions {
                  key      = "lifecycle"
                  operator = "NotIn"
                  values   = ["Spot"]
                }
              }
            }
          }

          pod_anti_affinity {
            preferred_during_scheduling_ignored_during_execution {
              weight = 100

              pod_affinity_term {
                label_selector {
                  match_expressions {
                    key      = "app.kubernetes.io/name"
                    operator = "In"
                    values   = [local.app_name]
                  }

                  match_expressions {
                    key      = "app.kubernetes.io/component"
                    operator = "In"
                    values   = ["webhook"]
                  }
                }

                topology_key = "kubernetes.io/hostname"
              }
            }

            preferred_during_scheduling_ignored_during_execution {
              weight = 50

              pod_affinity_term {
                label_selector {
                  match_expressions {
                    key      = "app.kubernetes.io/name"
                    operator = "In"
                    values   = [local.app_name]
                  }

                  match_expressions {
                    key      = "app.kubernetes.io/component"
                    operator = "In"
                    values   = ["webhook"]
                  }
                }

                topology_key = "topology.kubernetes.io/zone"
              }
            }
          }
        }

        topology_spread_constraint {
          max_skew           = 1
          topology_key       = "topology.kubernetes.io/zone"
          when_unsatisfiable = "DoNotSchedule"

          label_selector {
            match_labels = local.webhook_labels
          }
        }

        topology_spread_constraint {
          max_skew           = 1
          topology_key       = "kubernetes.io/hostname"
          when_unsatisfiable = "ScheduleAnyway"

          label_selector {
            match_labels = local.webhook_labels
          }
        }

        enable_service_links = true
      }
    }

    revision_history_limit = var.revision_history_limit
  }

  lifecycle {
    # This is managed by VPA recommender
    ignore_changes = [
      spec[0].template[0].spec[0].container[0].resources.requests,
      spec[0].template[0].spec[0].container[0].resources.limits,
    ]
  }
}
