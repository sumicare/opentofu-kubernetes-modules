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


resource "kubernetes_manifest" "prometheusrule_keda_operator" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind"       = "PrometheusRule"
    "metadata" = {
      "labels" = local.labels
      "name"   = "${local.app_name}-operator"
    }
    "spec" = {
      "groups" = [
        {
          "name" = "${local.app_name}-operator"
          "rules" = [
            {
              "alert" = "KedaScalerErrors"
              "annotations" = {
                "description" = "Keda scaledObject {{ $labels.scaledObject }} is experiencing errors with {{ $labels.scaler }} scaler"
                "summary"     = "Keda Scaler {{ $labels.scaler }} Errors"
              }
              "expr"   = "sum by ( scaledObject , scaler) (rate(keda_metrics_adapter_scaler_errors[2m]))  > 0"
              "for"    = "2m"
              "labels" = null
            },
          ]
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "prometheusrule_keda_admission_webhooks" {
  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind"       = "PrometheusRule"
    "metadata" = {
      "labels" = local.labels
      "name"   = "${local.app_name}-admission-webhooks"
    }
    "spec" = {
      "groups" = [
        {
          "name"  = "${local.app_name}-admission-webhooks"
          "rules" = []
        },
      ]
    }
  }
}
