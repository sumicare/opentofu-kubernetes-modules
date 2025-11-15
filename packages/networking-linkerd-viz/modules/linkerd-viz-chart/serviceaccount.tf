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


resource "kubernetes_service_account" "metrics_api" {
  metadata {
    name      = "metrics-api"
    namespace = "linkerd-viz"

    labels = {
      component              = "metrics-api"
      "linkerd.io/extension" = "viz"
    }
  }
}

resource "kubernetes_service_account" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "linkerd-viz"

    labels = {
      component              = "prometheus"
      "linkerd.io/extension" = "viz"
      namespace              = "linkerd-viz"
    }
  }
}

resource "kubernetes_service_account" "tap" {
  metadata {
    name      = "tap"
    namespace = "linkerd-viz"

    labels = {
      component              = "tap"
      "linkerd.io/extension" = "viz"
      namespace              = "linkerd-viz"
    }
  }
}

resource "kubernetes_service_account" "web" {
  metadata {
    name      = "web"
    namespace = "linkerd-viz"

    labels = {
      component              = "web"
      "linkerd.io/extension" = "viz"
      namespace              = "linkerd-viz"
    }
  }
}

resource "kubernetes_service_account" "tap_injector" {
  metadata {
    name      = "tap-injector"
    namespace = "linkerd-viz"

    labels = {
      "linkerd.io/extension" = "viz"
    }
  }
}

