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


resource "kubernetes_service" "metrics_api" {
  metadata {
    name      = "metrics-api"
    namespace = "linkerd-viz"

    labels = {
      component              = "metrics-api"
      "linkerd.io/extension" = "viz"
    }

    annotations = {
      "linkerd.io/created-by" = "linkerd/cli edge-25.8.5"
      "linkerd.io/inject"     = "enabled"
    }
  }

  spec {
    port {
      name        = "http"
      port        = 8085
      target_port = "8085"
    }

    selector = {
      component              = "metrics-api"
      "linkerd.io/extension" = "viz"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "linkerd-viz"

    labels = {
      component              = "prometheus"
      "linkerd.io/extension" = "viz"
      namespace              = "linkerd-viz"
    }

    annotations = {
      "linkerd.io/created-by" = "linkerd/cli edge-25.8.5"
      "linkerd.io/inject"     = "enabled"
    }
  }

  spec {
    port {
      name        = "admin"
      port        = 9090
      target_port = "9090"
    }

    selector = {
      component              = "prometheus"
      "linkerd.io/extension" = "viz"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "tap" {
  metadata {
    name      = "tap"
    namespace = "linkerd-viz"

    labels = {
      component              = "tap"
      "linkerd.io/extension" = "viz"
      namespace              = "linkerd-viz"
    }

    annotations = {
      "linkerd.io/created-by" = "linkerd/cli edge-25.8.5"
      "linkerd.io/inject"     = "enabled"
    }
  }

  spec {
    port {
      name        = "grpc"
      port        = 8088
      target_port = "8088"
    }

    port {
      name        = "apiserver"
      port        = 443
      target_port = "apiserver"
    }

    selector = {
      component              = "tap"
      "linkerd.io/extension" = "viz"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "tap_injector" {
  metadata {
    name      = "tap-injector"
    namespace = "linkerd-viz"

    labels = {
      component              = "tap-injector"
      "linkerd.io/extension" = "viz"
    }

    annotations = {
      "linkerd.io/created-by" = "linkerd/cli edge-25.8.5"
      "linkerd.io/inject"     = "enabled"
    }
  }

  spec {
    port {
      name        = "tap-injector"
      port        = 443
      target_port = "tap-injector"
    }

    selector = {
      component              = "tap-injector"
      "linkerd.io/extension" = "viz"
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_service" "web" {
  metadata {
    name      = "web"
    namespace = "linkerd-viz"

    labels = {
      component              = "web"
      "linkerd.io/extension" = "viz"
      namespace              = "linkerd-viz"
    }

    annotations = {
      "linkerd.io/created-by" = "linkerd/cli edge-25.8.5"
      "linkerd.io/inject"     = "enabled"
    }
  }

  spec {
    port {
      name        = "http"
      port        = 8084
      target_port = "8084"
    }

    port {
      name        = "admin"
      port        = 9994
      target_port = "9994"
    }

    selector = {
      component              = "web"
      "linkerd.io/extension" = "viz"
    }

    type = "ClusterIP"
  }
}

