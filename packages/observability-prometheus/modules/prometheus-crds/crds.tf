#
# Copyright 2025 Sumicare
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

###           DO NOT EDIT            ###
# This file is automagically generated #

resource "kubernetes_manifest" "customresourcedefinition_prometheusagents_monitoring_coreos_com" {
  manifest = yamldecode(file("${path.module}/prometheusagents.monitoring.coreos.com.yaml"))
}

resource "kubernetes_manifest" "customresourcedefinition_prometheuses_monitoring_coreos_com" {
  manifest = yamldecode(file("${path.module}/prometheuses.monitoring.coreos.com.yaml"))
}

resource "kubernetes_manifest" "customresourcedefinition_scrapeconfigs_monitoring_coreos_com" {
  manifest = yamldecode(file("${path.module}/scrapeconfigs.monitoring.coreos.com.yaml"))
}

resource "kubernetes_manifest" "customresourcedefinition_alertmanagers_monitoring_coreos_com" {
  manifest = yamldecode(file("${path.module}/alertmanagers.monitoring.coreos.com.yaml"))
}

resource "kubernetes_manifest" "customresourcedefinition_prometheusrules_monitoring_coreos_com" {
  manifest = yamldecode(file("${path.module}/prometheusrules.monitoring.coreos.com.yaml"))
}

resource "kubernetes_manifest" "customresourcedefinition_servicemonitors_monitoring_coreos_com" {
  manifest = yamldecode(file("${path.module}/servicemonitors.monitoring.coreos.com.yaml"))
}

resource "kubernetes_manifest" "customresourcedefinition_thanosrulers_monitoring_coreos_com" {
  manifest = yamldecode(file("${path.module}/thanosrulers.monitoring.coreos.com.yaml"))
}

resource "kubernetes_manifest" "customresourcedefinition_alertmanagerconfigs_monitoring_coreos_com" {
  manifest = yamldecode(file("${path.module}/alertmanagerconfigs.monitoring.coreos.com.yaml"))
}

resource "kubernetes_manifest" "customresourcedefinition_podmonitors_monitoring_coreos_com" {
  manifest = yamldecode(file("${path.module}/podmonitors.monitoring.coreos.com.yaml"))
}

resource "kubernetes_manifest" "customresourcedefinition_probes_monitoring_coreos_com" {
  manifest = yamldecode(file("${path.module}/probes.monitoring.coreos.com.yaml"))
}

