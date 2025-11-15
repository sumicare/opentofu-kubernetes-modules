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


resource "kubernetes_deployment" "opencost" {
  metadata {
    name      = local.app_name
    namespace = var.namespace
    labels    = local.labels
  }

  spec {
    replicas = var.replicas

    selector {
      match_labels = local.selector_labels
    }

    template {
      metadata {
        labels = local.selector_labels
      }

      spec {
        volume {
          name = "custom-metrics"

          config_map {
            name = kubernetes_config_map.custom_metrics.metadata[0].name
          }
        }

        volume {
          name = "cloud-integration"

          secret {
            secret_name = "${local.app_name}-cloud-integration"

            items {
              key  = "cloud-integration.json"
              path = "cloud-integration.json"
            }
          }
        }

        volume {
          name = "opencost-ui-nginx-config-volume"

          config_map {
            name = kubernetes_config_map.opencost_ui_nginx_config.metadata[0].name

            items {
              key  = "nginx.conf"
              path = "default.nginx.conf"
            }
          }
        }

        volume {
          name = "ca-certs-secret"

          secret {
            secret_name  = "ca-certs-secret"
            default_mode = "0644"
          }
        }

        volume {
          name = "ssl-path"
          empty_dir {}
        }

        init_container {
          name    = "update-ca-trust"
          image   = "${var.opencost_image}:${var.opencost_version}@${var.opencost_image_digest}"
          command = ["sh", "-c", "mkdir -p /etc/ssl/certs; update-ca-certificates;\n"]

          volume_mount {
            name       = "ca-certs-secret"
            mount_path = "/usr/local/share/ca-certificates"
          }

          volume_mount {
            name       = "ssl-path"
            mount_path = "/etc/ssl/certs"
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            run_as_user               = 0
            read_only_root_filesystem = true

            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
        }

        container {
          name  = local.app_name
          image = "${var.opencost_image}:${var.opencost_version}@${var.opencost_image_digest}"

          port {
            name           = "http"
            container_port = var.api_port
          }

          env {
            name  = "LOG_LEVEL"
            value = var.log_level
          }

          env {
            name  = "CUSTOM_COST_ENABLED"
            value = tostring(var.custom_cost_enabled)
          }

          env {
            name  = "INSTALL_NAMESPACE"
            value = var.namespace
          }

          env {
            name  = "PROMETHEUS_QUERY_RESOLUTION_SECONDS"
            value = tostring(var.prometheus_query_resolution_seconds)
          }

          env {
            name  = "METRICS_CONFIGMAP_NAME"
            value = kubernetes_config_map.custom_metrics.metadata[0].name
          }

          env {
            name  = "API_PORT"
            value = tostring(var.api_port)
          }

          env {
            name  = "PROMETHEUS_SERVER_ENDPOINT"
            value = var.prometheus_server_endpoint
          }

          env {
            name  = "INSECURE_SKIP_VERIFY"
            value = tostring(var.insecure_skip_verify)
          }

          env {
            name  = "CLUSTER_ID"
            value = var.cluster_id
          }

          env {
            name = "AWS_ACCESS_KEY_ID"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.prometheus_opencost_secret.metadata[0].name
                key  = "AWS_ACCESS_KEY_ID"
              }
            }
          }

          env {
            name = "AWS_SECRET_ACCESS_KEY"

            value_from {
              secret_key_ref {
                name = kubernetes_secret.prometheus_opencost_secret.metadata[0].name
                key  = "AWS_SECRET_ACCESS_KEY"
              }
            }
          }

          env {
            name = "DB_BASIC_AUTH_USERNAME"

            value_from {
              secret_key_ref {
                name     = kubernetes_secret.prometheus_opencost_secret.metadata[0].name
                key      = "DB_BASIC_AUTH_USERNAME"
                optional = true
              }
            }
          }

          env {
            name = "DB_BASIC_AUTH_PW"

            value_from {
              secret_key_ref {
                name     = kubernetes_secret.prometheus_opencost_secret.metadata[0].name
                key      = "DB_BASIC_AUTH_PW"
                optional = true
              }
            }
          }

          env {
            name  = "RESOLUTION_1D_RETENTION"
            value = tostring(var.resolution_1d_retention)
          }

          env {
            name  = "RESOLUTION_1H_RETENTION"
            value = tostring(var.resolution_1h_retention)
          }

          env {
            name  = "CLOUD_COST_ENABLED"
            value = tostring(var.cloud_cost_enabled)
          }

          env {
            name  = "CLOUD_COST_MONTH_TO_DATE_INTERVAL"
            value = tostring(var.cloud_cost_month_to_date_interval)
          }

          env {
            name  = "CLOUD_COST_REFRESH_RATE_HOURS"
            value = tostring(var.cloud_cost_refresh_rate_hours)
          }

          env {
            name  = "CLOUD_COST_QUERY_WINDOW_DAYS"
            value = tostring(var.cloud_cost_query_window_days)
          }

          env {
            name  = "CLOUD_COST_RUN_WINDOW_DAYS"
            value = tostring(var.cloud_cost_run_window_days)
          }

          resources {
            limits = {
              memory = var.resources_opencost.limits.memory
            }

            requests = {
              cpu    = var.resources_opencost.requests.cpu
              memory = var.resources_opencost.requests.memory
            }
          }

          volume_mount {
            name       = "custom-metrics"
            read_only  = true
            mount_path = "/tmp/custom-config/metrics.json"
            sub_path   = "metrics.json"
          }

          volume_mount {
            name       = "cloud-integration"
            mount_path = "/var/configs/cloud-integration"
          }

          volume_mount {
            name       = "ca-certs-secret"
            mount_path = "/usr/local/share/ca-certificates"
          }

          volume_mount {
            name       = "ssl-path"
            mount_path = "/etc/ssl/certs"
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = tostring(var.api_port)
            }

            initial_delay_seconds = var.liveness_probe_initial_delay
            period_seconds        = var.liveness_probe_period
            failure_threshold     = var.liveness_probe_failure_threshold
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = tostring(var.api_port)
            }

            initial_delay_seconds = var.readiness_probe_initial_delay
            period_seconds        = var.readiness_probe_period
            failure_threshold     = var.readiness_probe_failure_threshold
          }

          startup_probe {
            http_get {
              path = "/healthz"
              port = tostring(var.api_port)
            }

            initial_delay_seconds = var.startup_probe_initial_delay
            period_seconds        = var.startup_probe_period
            failure_threshold     = var.startup_probe_failure_threshold
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

        container {
          name  = "${local.app_name}-ui"
          image = "${var.opencost_ui_image}:${var.opencost_version}@${var.opencost_ui_image_digest}"

          port {
            name           = "http-ui"
            container_port = var.ui_port
          }

          env {
            name  = "API_PORT"
            value = tostring(var.api_port)
          }

          env {
            name  = "UI_PORT"
            value = tostring(var.ui_port)
          }

          resources {
            limits = {
              memory = var.resources_ui.limits.memory
            }

            requests = {
              cpu    = var.resources_ui.requests.cpu
              memory = var.resources_ui.requests.memory
            }
          }

          volume_mount {
            name       = "opencost-ui-nginx-config-volume"
            mount_path = "/etc/nginx/conf.d/default.nginx.conf"
            sub_path   = "default.nginx.conf"
          }

          liveness_probe {
            http_get {
              path = "/healthz"
              port = tostring(var.ui_port)
            }

            initial_delay_seconds = var.ui_liveness_probe_initial_delay
            period_seconds        = var.ui_liveness_probe_period
            failure_threshold     = var.ui_liveness_probe_failure_threshold
          }

          readiness_probe {
            http_get {
              path = "/healthz"
              port = tostring(var.ui_port)
            }

            initial_delay_seconds = var.ui_readiness_probe_initial_delay
            period_seconds        = var.ui_readiness_probe_period
            failure_threshold     = var.ui_readiness_probe_failure_threshold
          }

          image_pull_policy = "IfNotPresent"
        }

        service_account_name            = kubernetes_service_account.opencost.metadata[0].name
        automount_service_account_token = true

        security_context {
          fs_group = var.fs_group
        }
      }
    }

    strategy {
      type = "RollingUpdate"

      rolling_update {
        max_unavailable = "1"
        max_surge       = "1"
      }
    }
  }
}
