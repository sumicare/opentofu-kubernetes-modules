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


resource "kubernetes_manifest" "webhook_config" {
  manifest = {
    apiVersion = "admissionregistration.k8s.io/v1"
    kind       = "MutatingWebhookConfiguration"
    metadata = {
      labels = local.labels
      name   = "${local.app_name}-webhook-config"
    }
    annotations = {
      "cert-manager.io/inject-ca-from" = "${var.namespace}/${local.app_name}-tls-certificates"
    }
    webhooks = [
      {
        admissionReviewVersions = [
          "v1",
        ]
        clientConfig = {
          service = {
            name      = "${local.app_name}-webhook"
            namespace = var.namespace
            port      = 443
          }
        }
        failurePolicy      = "Ignore"
        matchPolicy        = "Equivalent"
        name               = "vpa.k8s.io"
        namespaceSelector  = {}
        objectSelector     = {}
        reinvocationPolicy = "Never"
        rules = [
          {
            apiGroups = [
              "",
            ]
            apiVersions = [
              "v1",
            ]
            operations = [
              "CREATE",
            ]
            resources = [
              "pods",
            ]
            scope = "*"
          },
          {
            apiGroups = [
              "autoscaling.k8s.io",
            ]
            apiVersions = [
              "*",
            ]
            operations = [
              "CREATE",
              "UPDATE",
            ]
            resources = [
              "verticalpodautoscalers",
            ]
            scope = "*"
          },
        ]
        sideEffects    = "None"
        timeoutSeconds = var.webhook_timeout_seconds
      },
    ]
  }
}
