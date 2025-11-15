
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

###           DO NOT EDIT            ###
# This file is automagically generated #

resource "docker_image" "kube_state_metrics" {
  name         = "${var.repository}${var.org}/kube_state_metrics:${var.kube_state_metrics_version}"
  keep_locally = true
  triggers = {
    Dockerfile         = filesha256("${path.module}/Dockerfile")
    DebianVersion      = var.debian_version
    KubeStateMetricsVersion = var.kube_state_metrics_version
  }

  build {
    context    = path.module
    builder    = "default"
    dockerfile = "${path.module}/Dockerfile"
    tag        = ["${var.repository}${var.org}/kube_state_metrics:${var.kube_state_metrics_version}"]
    build_args = {
      REPO : var.repository
      ORG : var.org
      DEBIAN_VERSION : var.debian_version
      KUBE_STATE_METRICS_VERSION : var.kube_state_metrics_version
    }
    label = {
      author : var.org
    }
  }
}

resource "docker_registry_image" "kube_state_metrics" {
  count         = var.registry_auth == null ? 0 : 1
  name          = docker_image.kube_state_metrics.name
  keep_remotely = true

  dynamic "auth_config" {
    for_each = var.registry_auth == null ? [] : [var.registry_auth]
    content {
      address  = auth_config.value.address
      username = auth_config.value.username
      password = auth_config.value.password
    }
  }

  depends_on = [docker_image.kube_state_metrics]
}
