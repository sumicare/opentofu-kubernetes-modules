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

