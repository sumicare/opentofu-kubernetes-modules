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

module "descheduler_images" {
  source = "${path.module}/../../../compute-descheduler/modules/descheduler-image"

  org           = var.org
  repository    = var.repository
  registry_auth = var.registry_auth

  debian_version      = local.debian_version
  descheduler_version = local.descheduler_version

  depends_on = [module.debian_images]
}

module "goldilocks_images" {
  source = "${path.module}/../../../compute-goldilocks/modules/goldilocks-image"

  org           = var.org
  repository    = var.repository
  registry_auth = var.registry_auth

  debian_version     = local.debian_version
  goldilocks_version = local.goldilocks_version

  depends_on = [module.debian_images]
}

module "grafana_rollout_operator_images" {
  source = "${path.module}/../../../compute-grafana-rollout-operator/modules/grafana-rollout-operator-image"

  org           = var.org
  repository    = var.repository
  registry_auth = var.registry_auth

  debian_version           = local.debian_version
  rollout_operator_version = local.rollout_operator_version

  depends_on = [module.debian_images]
}

module "kamaji_images" {
  source = "${path.module}/../../../compute-kamaji/modules/kamaji-image"

  org           = var.org
  repository    = var.repository
  registry_auth = var.registry_auth

  debian_version = local.debian_version
  kamaji_version = local.kamaji_version

  depends_on = [module.debian_images]
}

module "keda_images" {
  source = "${path.module}/../../../compute-keda/modules/keda-image"

  org           = var.org
  repository    = var.repository
  registry_auth = var.registry_auth

  debian_version = local.debian_version
  keda_version   = local.keda_version

  depends_on = [module.debian_images]
}

module "virtual_kubelet_images" {
  source = "${path.module}/../../../compute-virtual-kubelet/modules/virtual-kubelet-image"

  org           = var.org
  repository    = var.repository
  registry_auth = var.registry_auth

  debian_version          = local.debian_version
  virtual_kubelet_version = local.virtual_kubelet_version

  depends_on = [module.debian_images]
}

module "vpa_images" {
  source = "${path.module}/../../../compute-vpa/modules/vpa-image"

  org           = var.org
  repository    = var.repository
  registry_auth = var.registry_auth

  debian_version = local.debian_version
  vpa_version    = local.vpa_version

  depends_on = [module.debian_images]
}
