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


resource "kubernetes_deployment" "dashboard" {
  metadata {
    name      = "${local.app_name}-dashboard"
    namespace = var.namespace
    labels    = local.labels
  }

  spec {
    replicas = var.dashboard_replicas

    selector {
      match_labels = local.dashboard_labels
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
        labels = local.dashboard_labels
      }

      spec {
        container {
          name  = local.app_name
          image = "us-docker.pkg.dev/fairwinds-ops/oss/goldilocks:${var.goldilocks_version}"
          command = [
            "/goldilocks",
            "dashboard",
            "--exclude-containers=${var.exclude_containers}",
            "-v2",
            "--on-by-default=${var.on_by_default}"
          ]

          port {
            name           = "http"
            container_port = var.dashboard_container_port
            protocol       = "TCP"
          }

          resources {
            limits = {
              cpu    = var.resources.limits.cpu
              memory = var.resources.limits.memory
            }

            requests = {
              cpu    = var.resources.requests.cpu
              memory = var.resources.requests.memory
            }
          }

          startup_probe {
            http_get {
              path = "/health"
              port = "http"
            }

            initial_delay_seconds = var.liveness_probe_initial_delay
            timeout_seconds       = var.liveness_probe_timeout
            period_seconds        = var.liveness_probe_period
            failure_threshold     = 30
          }

          liveness_probe {
            http_get {
              path = "/health"
              port = "http"
            }

            initial_delay_seconds = var.liveness_probe_initial_delay
            timeout_seconds       = var.liveness_probe_timeout
            period_seconds        = var.liveness_probe_period
            failure_threshold     = var.liveness_probe_failure_threshold
          }

          readiness_probe {
            http_get {
              path = "/health"
              port = "http"
            }

            initial_delay_seconds = var.liveness_probe_initial_delay
            timeout_seconds       = var.liveness_probe_timeout
            period_seconds        = var.liveness_probe_period
            success_threshold     = 1
            failure_threshold     = var.liveness_probe_failure_threshold
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            capabilities {
              drop = ["ALL"]
            }

            run_as_user               = var.run_as_user
            run_as_non_root           = true
            read_only_root_filesystem = true
          }
        }

        service_account_name = "${local.app_name}-dashboard"

        security_context {
          fs_group = var.fs_group

          seccomp_profile {
            type = "RuntimeDefault"
          }
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
                    values   = ["dashboard"]
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
                    values   = ["dashboard"]
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
            match_labels = labels.dashboard_labels
          }
        }

        topology_spread_constraint {
          max_skew           = 1
          topology_key       = "kubernetes.io/hostname"
          when_unsatisfiable = "ScheduleAnyway"

          label_selector {
            match_labels = labels.dashboard_labels
          }
        }
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
