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


resource "kubernetes_manifest" "validatingwebhookconfiguration_keda_admission" {
  manifest = {
    apiVersion = "admissionregistration.k8s.io/v1"
    kind       = "ValidatingWebhookConfiguration"
    metadata = {
      annotations = {
        "cert-manager.io/inject-ca-from" = "${var.namespace}/${local.app_name}-tls-certificates"
      }
      labels = local.labels
      name   = "keda-admission"
    }
    webhooks = [
      {
        admissionReviewVersions = [
          "v1",
        ]
        clientConfig = {
          service = {
            name      = "keda-admission-webhooks"
            namespace = "keda"
            path      = "/validate-keda-sh-v1alpha1-scaledobject"
          }
        }
        failurePolicy     = "Ignore"
        matchPolicy       = "Equivalent"
        name              = "vscaledobject.kb.io"
        namespaceSelector = {}
        objectSelector    = {}
        rules = [
          {
            apiGroups = [
              "keda.sh",
            ]
            apiVersions = [
              "v1alpha1",
            ]
            operations = [
              "CREATE",
              "UPDATE",
            ]
            resources = [
              "scaledobjects",
            ]
          },
        ]
        sideEffects    = "None"
        timeoutSeconds = 10
      },
      {
        admissionReviewVersions = [
          "v1",
        ]
        clientConfig = {
          service = {
            name      = "keda-admission-webhooks"
            namespace = "keda"
            path      = "/validate-keda-sh-v1alpha1-triggerauthentication"
          }
        }
        failurePolicy     = "Ignore"
        matchPolicy       = "Equivalent"
        name              = "vstriggerauthentication.kb.io"
        namespaceSelector = {}
        objectSelector    = {}
        rules = [
          {
            apiGroups = [
              "keda.sh",
            ]
            apiVersions = [
              "v1alpha1",
            ]
            operations = [
              "CREATE",
              "UPDATE",
            ]
            resources = [
              "triggerauthentications",
            ]
          },
        ]
        sideEffects    = "None"
        timeoutSeconds = 10
      },
      {
        admissionReviewVersions = [
          "v1",
        ]
        clientConfig = {
          service = {
            name      = "keda-admission-webhooks"
            namespace = "keda"
            path      = "/validate-keda-sh-v1alpha1-clustertriggerauthentication"
          }
        }
        failurePolicy     = "Ignore"
        matchPolicy       = "Equivalent"
        name              = "vsclustertriggerauthentication.kb.io"
        namespaceSelector = {}
        objectSelector    = {}
        rules = [
          {
            apiGroups = [
              "keda.sh",
            ]
            apiVersions = [
              "v1alpha1",
            ]
            operations = [
              "CREATE",
              "UPDATE",
            ]
            resources = [
              "clustertriggerauthentications",
            ]
          },
        ]
        sideEffects    = "None"
        timeoutSeconds = 10
      },
    ]
  }
}
