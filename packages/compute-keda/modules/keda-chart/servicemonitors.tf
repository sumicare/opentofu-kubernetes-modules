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


resource "kubernetes_manifest" "servicemonitor_keda_operator" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      labels = local.labels
      name   = "${local.app_name}-operator"
    }
    spec = {
      endpoints = [
        {
          path   = "/metrics"
          port   = "metrics"
          scheme = "http"
        },
      ]
      namespaceSelector = {
        matchNames = [
          var.namespace
        ]
      }
      selector = {
        matchLabels = local.operator_labels
      }
    }
  }
}

resource "kubernetes_manifest" "servicemonitor_keda_operator_metrics_apiserver" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      labels = local.labels
      name   = "${local.app_name}-operator-metrics-apiserver"
    }
    spec = {
      endpoints = [
        {
          path   = "/metrics"
          port   = "metrics"
          scheme = "http"
        },
      ]
      namespaceSelector = {
        matchNames = [
          var.namespace
        ]
      }
      selector = {
        matchLabels = local.metrics_server_labels
      }
    }
  }
}

resource "kubernetes_manifest" "servicemonitor_keda_admission_webhooks" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata = {
      labels = local.labels
      name   = "${local.app_name}-admission-webhooks"
    }
    spec = {
      endpoints = [
        {
          path   = "/metrics"
          port   = "metrics"
          scheme = "http"
        },
      ]
      namespaceSelector = {
        matchNames = [
          var.namespace
        ]
      }
      selector = {
        matchLabels = local.webhook_labels
      }
    }
  }
}
