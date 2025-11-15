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


resource "kubernetes_stateful_set" "zot" {
  metadata {
    name      = local.app_name
    namespace = var.namespace
    labels    = local.labels
  }

  spec {
    service_name           = local.app_name
    replicas               = var.replicas
    pod_management_policy  = "Parallel"
    revision_history_limit = var.revision_history_limit

    selector {
      match_labels = local.selector_labels
    }

    update_strategy {
      type = "RollingUpdate"

      rolling_update {
        # Partition controls which pods get updated. Pods with ordinal >= partition will be updated.
        # For a rollout_percentage, we keep (100 - rollout_percentage)% of pods on old version.
        # Example: replicas=4, rollout_percentage=25 -> partition=3 (only pod-3 updates, 25%)
        partition = ceil(var.replicas * (100 - var.rollout_percentage) / 100)
      }
    }

    template {
      metadata {
        labels = local.selector_labels

        annotations = {
          "checksum/config" = sha256(file("${path.module}/config.json"))
        }
      }

      spec {
        service_account_name             = local.app_name
        dns_policy                       = "ClusterFirst"
        termination_grace_period_seconds = var.termination_grace_period_seconds

        security_context {
          fs_group            = var.security_context_fs_group
          run_as_non_root     = true
          run_as_user         = var.security_context_run_as_user
          supplemental_groups = [var.security_context_fs_group]
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
                    key      = "app.kubernetes.io/part-of"
                    operator = "In"
                    values   = [local.app_name]
                  }

                  match_expressions {
                    key      = "app.kubernetes.io/component"
                    operator = "In"
                    values   = ["registry"]
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
                    key      = "app.kubernetes.io/part-of"
                    operator = "In"
                    values   = [local.app_name]
                  }

                  match_expressions {
                    key      = "app.kubernetes.io/component"
                    operator = "In"
                    values   = ["registry"]
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
            match_labels = local.selector_labels
          }
        }

        topology_spread_constraint {
          max_skew           = 1
          topology_key       = "kubernetes.io/hostname"
          when_unsatisfiable = "ScheduleAnyway"

          label_selector {
            match_labels = local.selector_labels
          }
        }

        volume {
          name = "config"

          config_map {
            name = kubernetes_config_map.zot_config.metadata[0].name
          }
        }

        container {
          name              = local.app_name
          image             = "${var.image}:${var.zot_version}"
          image_pull_policy = "IfNotPresent"

          port {
            name           = "http"
            container_port = var.http_port
            protocol       = "TCP"
          }

          volume_mount {
            name       = "${local.app_name}-pvc"
            mount_path = "/var/lib/registry"
          }

          volume_mount {
            name       = "config"
            mount_path = "/etc/zot"
            read_only  = true
          }

          security_context {
            allow_privilege_escalation = false
            read_only_root_filesystem  = false
            run_as_non_root            = true
            run_as_user                = var.security_context_run_as_user

            capabilities {
              drop = ["ALL"]
            }
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

          liveness_probe {
            http_get {
              path   = "/livez"
              port   = var.http_port
              scheme = "HTTP"
            }

            initial_delay_seconds = 0
            timeout_seconds       = var.liveness_probe_timeout
            period_seconds        = var.liveness_probe_period
            failure_threshold     = var.liveness_probe_failure_threshold
          }

          readiness_probe {
            http_get {
              path   = "/readyz"
              port   = var.http_port
              scheme = "HTTP"
            }

            initial_delay_seconds = var.readiness_probe_initial_delay
            timeout_seconds       = var.readiness_probe_timeout
            period_seconds        = var.readiness_probe_period
            failure_threshold     = var.readiness_probe_failure_threshold
          }

          startup_probe {
            http_get {
              path   = "/startupz"
              port   = var.http_port
              scheme = "HTTP"
            }

            initial_delay_seconds = var.startup_probe_initial_delay
            timeout_seconds       = var.startup_probe_timeout
            period_seconds        = var.startup_probe_period
            failure_threshold     = var.startup_probe_failure_threshold
          }
        }
      }
    }

    volume_claim_template {
      metadata {
        name   = "${local.app_name}-pvc"
        labels = local.labels
      }

      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = var.storage_class_name

        resources {
          requests = {
            storage = var.storage_size
          }
        }
      }
    }

    min_ready_seconds = 10
  }

  lifecycle {
    # This is managed by VPA recommender
    ignore_changes = [
      spec[0].template[0].spec[0].container[0].resources.requests,
      spec[0].template[0].spec[0].container[0].resources.limits,
    ]
  }
}
