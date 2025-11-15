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


resource "kubernetes_deployment" "updater" {
  metadata {
    name      = "${local.app_name}-updater"
    namespace = var.namespace
    labels    = local.labels
  }

  spec {
    replicas = var.updater_replicas

    selector {
      match_labels = local.updater_labels
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
        labels = local.updater_labels
      }

      spec {
        container {
          name  = "${local.app_name}-updater"
          image = "registry.k8s.io/autoscaling/vpa-updater:${var.vpa_version}"

          port {
            name           = "metrics"
            container_port = 8943
            protocol       = "TCP"
          }

          env {
            name = "NAMESPACE"

            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }

          resources {
            limits = {
              cpu    = var.updater_resources.limits.cpu
              memory = var.updater_resources.limits.memory
            }

            requests = {
              cpu    = var.updater_resources.requests.cpu
              memory = var.updater_resources.requests.memory
            }
          }

          liveness_probe {
            http_get {
              path   = "/health-check"
              port   = "metrics"
              scheme = "HTTP"
            }

            timeout_seconds   = var.liveness_probe_timeout_seconds
            period_seconds    = var.liveness_probe_period_seconds
            success_threshold = 1
            failure_threshold = var.liveness_probe_failure_threshold
          }

          readiness_probe {
            http_get {
              path   = "/health-check"
              port   = "metrics"
              scheme = "HTTP"
            }

            timeout_seconds   = var.liveness_probe_timeout_seconds
            period_seconds    = var.liveness_probe_period_seconds
            success_threshold = 1
            failure_threshold = var.readiness_probe_failure_threshold
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

        service_account_name = "${local.app_name}-updater"

        security_context {
          run_as_user     = var.run_as_user
          run_as_non_root = true

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
                    values   = ["updater"]
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
                    values   = ["updater"]
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
            match_labels = {
              "app.kubernetes.io/name"      = local.app_name
              "app.kubernetes.io/component" = "updater"
            }
          }
        }

        topology_spread_constraint {
          max_skew           = 1
          topology_key       = "kubernetes.io/hostname"
          when_unsatisfiable = "ScheduleAnyway"

          label_selector {
            match_labels = {
              "app.kubernetes.io/name"      = local.app_name
              "app.kubernetes.io/component" = "updater"
            }
          }
        }
      }
    }

    revision_history_limit = var.revision_history_limit
  }
}
