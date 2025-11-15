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


resource "kubernetes_network_policy_v1" "networkpolicy_keda_operator" {
  metadata {
    labels = merge(local.operator_labels, {
      name = "${local.app_name}-operator"
    })
    name      = "${local.app_name}-operator"
    namespace = var.namespace
  }

  spec {
    pod_selector {
      match_labels = local.operator_labels
    }

    policy_types = ["Ingress", "Egress"]

    # Allow ingress from within the cluster for metrics scraping
    ingress {
      ports {
        port     = "9666"
        protocol = "TCP"
      }
    }

    # Allow egress to kube-apiserver and DNS
    egress {
      # DNS
      ports {
        port     = "53"
        protocol = "UDP"
      }
    }

    egress {
      # HTTPS to kube-apiserver
      ports {
        port     = "443"
        protocol = "TCP"
      }
    }

    egress {
      # HTTP to kube-apiserver (if needed)
      ports {
        port     = "6443"
        protocol = "TCP"
      }
    }
  }
}

resource "kubernetes_network_policy_v1" "networkpolicy_keda_metrics" {
  metadata {
    labels = merge(local.metrics_server_labels, {
      name = "${local.app_name}-metrics"
    })
    name      = "${local.app_name}-metrics"
    namespace = var.namespace
  }

  spec {
    pod_selector {
      match_labels = local.metrics_server_labels
    }

    policy_types = ["Ingress", "Egress"]

    # Allow ingress on HTTPS port for metrics API server
    ingress {
      ports {
        port     = "6443"
        protocol = "TCP"
      }
    }

    # Allow ingress on metrics port
    ingress {
      ports {
        port     = "8080"
        protocol = "TCP"
      }
    }

    # Allow egress to kube-apiserver and DNS
    egress {
      # DNS
      ports {
        port     = "53"
        protocol = "UDP"
      }
    }

    egress {
      # HTTPS to kube-apiserver
      ports {
        port     = "443"
        protocol = "TCP"
      }
    }

    egress {
      # HTTP to kube-apiserver (if needed)
      ports {
        port     = "6443"
        protocol = "TCP"
      }
    }
  }
}

resource "kubernetes_network_policy_v1" "networkpolicy_keda_admission_webhooks" {
  metadata {
    labels = merge(local.webhook_labels, {
      name = "${local.app_name}-admission-webhooks"
    })
    name      = "${local.app_name}-admission-webhooks"
    namespace = var.namespace
  }

  spec {
    pod_selector {
      match_labels = local.webhook_labels
    }

    policy_types = ["Ingress", "Egress"]

    # Allow ingress from kube-apiserver for webhook validation
    ingress {
      ports {
        port     = "9443"
        protocol = "TCP"
      }
    }

    # Allow egress to kube-apiserver and DNS
    egress {
      # DNS
      ports {
        port     = "53"
        protocol = "UDP"
      }
    }

    egress {
      # HTTPS to kube-apiserver
      ports {
        port     = "443"
        protocol = "TCP"
      }
    }

    egress {
      # HTTP to kube-apiserver (if needed)
      ports {
        port     = "6443"
        protocol = "TCP"
      }
    }
  }
}
