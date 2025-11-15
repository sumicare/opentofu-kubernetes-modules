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


resource "kubernetes_deployment" "metrics_server" {
  metadata {
    name      = "metrics-server"
    namespace = "kube-system"

    labels = {
      k8s-app = "metrics-server"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        k8s-app = "metrics-server"
      }
    }

    template {
      metadata {
        labels = {
          k8s-app = "metrics-server"
        }
      }

      spec {
        volume {
          name      = "tmp-dir"
          empty_dir = {}
        }

        container {
          name  = "metrics-server"
          image = "registry.k8s.io/metrics-server/metrics-server:v0.8.0"
          args  = ["--cert-dir=/tmp", "--secure-port=10250", "--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname", "--kubelet-use-node-status-port", "--metric-resolution=15s"]

          port {
            name           = "https"
            container_port = 10250
            protocol       = "TCP"
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "200Mi"
            }
          }

          volume_mount {
            name       = "tmp-dir"
            mount_path = "/tmp"
          }

          liveness_probe {
            http_get {
              path   = "/livez"
              port   = "https"
              scheme = "HTTPS"
            }

            period_seconds    = 10
            failure_threshold = 3
          }

          readiness_probe {
            http_get {
              path   = "/readyz"
              port   = "https"
              scheme = "HTTPS"
            }

            initial_delay_seconds = 20
            period_seconds        = 10
            failure_threshold     = 3
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            capabilities {
              drop = ["ALL"]
            }

            run_as_user               = 1000
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

        service_account_name = "metrics-server"

        affinity {
          pod_anti_affinity {
            required_during_scheduling_ignored_during_execution {
              label_selector {
                match_labels = {
                  k8s-app = "metrics-server"
                }
              }

              namespaces   = ["kube-system"]
              topology_key = "kubernetes.io/hostname"
            }
          }
        }

        priority_class_name = "system-cluster-critical"
      }
    }

    strategy {
      rolling_update {
        max_unavailable = "1"
      }
    }
  }
}

