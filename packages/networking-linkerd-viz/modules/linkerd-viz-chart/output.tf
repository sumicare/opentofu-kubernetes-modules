resource "kubernetes_namespace" "linkerd_viz" {
  metadata {
    name = "linkerd-viz"

    labels = {
      "linkerd.io/extension"               = "viz"
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}

resource "kubernetes_cluster_role" "linkerd_linkerd_viz_metrics_api" {
  metadata {
    name = "linkerd-linkerd-viz-metrics-api"

    labels = {
      component              = "metrics-api"
      "linkerd.io/extension" = "viz"
    }
  }

  rule {
    verbs      = ["list", "get", "watch"]
    api_groups = ["extensions", "apps"]
    resources  = ["daemonsets", "deployments", "replicasets", "statefulsets"]
  }

  rule {
    verbs      = ["list", "get", "watch"]
    api_groups = ["extensions", "batch"]
    resources  = ["cronjobs", "jobs"]
  }

  rule {
    verbs      = ["list", "get", "watch"]
    api_groups = [""]
    resources  = ["pods", "endpoints", "services", "replicationcontrollers", "namespaces"]
  }

  rule {
    verbs      = ["list", "get", "watch"]
    api_groups = ["linkerd.io"]
    resources  = ["serviceprofiles"]
  }

  rule {
    verbs      = ["list", "get"]
    api_groups = ["policy.linkerd.io"]
    resources  = ["servers", "serverauthorizations", "authorizationpolicies", "httproutes"]
  }
}

resource "kubernetes_cluster_role_binding" "linkerd_linkerd_viz_metrics_api" {
  metadata {
    name = "linkerd-linkerd-viz-metrics-api"

    labels = {
      component              = "metrics-api"
      "linkerd.io/extension" = "viz"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "metrics-api"
    namespace = "linkerd-viz"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "linkerd-linkerd-viz-metrics-api"
  }
}

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

resource "kubernetes_cluster_role" "linkerd_linkerd_viz_prometheus" {
  metadata {
    name = "linkerd-linkerd-viz-prometheus"

    labels = {
      component              = "prometheus"
      "linkerd.io/extension" = "viz"
    }
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["nodes", "nodes/proxy", "pods"]
  }
}

resource "kubernetes_cluster_role_binding" "linkerd_linkerd_viz_prometheus" {
  metadata {
    name = "linkerd-linkerd-viz-prometheus"

    labels = {
      component              = "prometheus"
      "linkerd.io/extension" = "viz"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "prometheus"
    namespace = "linkerd-viz"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "linkerd-linkerd-viz-prometheus"
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

resource "kubernetes_cluster_role" "linkerd_linkerd_viz_tap" {
  metadata {
    name = "linkerd-linkerd-viz-tap"

    labels = {
      component              = "tap"
      "linkerd.io/extension" = "viz"
    }
  }

  rule {
    verbs      = ["list", "get", "watch"]
    api_groups = [""]
    resources  = ["pods", "services", "replicationcontrollers", "namespaces", "nodes"]
  }

  rule {
    verbs      = ["list", "get", "watch"]
    api_groups = ["extensions", "apps"]
    resources  = ["daemonsets", "deployments", "replicasets", "statefulsets"]
  }

  rule {
    verbs      = ["list", "get", "watch"]
    api_groups = ["extensions", "batch"]
    resources  = ["cronjobs", "jobs"]
  }
}

resource "kubernetes_cluster_role" "linkerd_linkerd_viz_tap_admin" {
  metadata {
    name = "linkerd-linkerd-viz-tap-admin"

    labels = {
      component              = "tap"
      "linkerd.io/extension" = "viz"
    }
  }

  rule {
    verbs      = ["list"]
    api_groups = [""]
    resources  = ["namespaces"]
  }

  rule {
    verbs      = ["watch"]
    api_groups = ["tap.linkerd.io"]
    resources  = ["*"]
  }
}

resource "kubernetes_cluster_role_binding" "linkerd_linkerd_viz_tap" {
  metadata {
    name = "linkerd-linkerd-viz-tap"

    labels = {
      component              = "tap"
      "linkerd.io/extension" = "viz"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "tap"
    namespace = "linkerd-viz"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "linkerd-linkerd-viz-tap"
  }
}

resource "kubernetes_cluster_role_binding" "linkerd_linkerd_viz_tap_auth_delegator" {
  metadata {
    name = "linkerd-linkerd-viz-tap-auth-delegator"

    labels = {
      component              = "tap"
      "linkerd.io/extension" = "viz"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "tap"
    namespace = "linkerd-viz"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "system:auth-delegator"
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

resource "kubernetes_role_binding" "linkerd_linkerd_viz_tap_auth_reader" {
  metadata {
    name      = "linkerd-linkerd-viz-tap-auth-reader"
    namespace = "kube-system"

    labels = {
      component              = "tap"
      "linkerd.io/extension" = "viz"
      namespace              = "linkerd-viz"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "tap"
    namespace = "linkerd-viz"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "extension-apiserver-authentication-reader"
  }
}

resource "kubernetes_secret" "tap_k_8_s_tls" {
  metadata {
    name      = "tap-k8s-tls"
    namespace = "linkerd-viz"

    labels = {
      component              = "tap"
      "linkerd.io/extension" = "viz"
      namespace              = "linkerd-viz"
    }

    annotations = {
      "linkerd.io/created-by" = "linkerd/cli edge-25.8.5"
    }
  }

  data = {
    "tls.crt" = "-----BEGIN CERTIFICATE-----\nMIIDJTCCAg2gAwIBAgIQA+kfoJbR2omit5yz0sW/PTANBgkqhkiG9w0BAQsFADAe\nMRwwGgYDVQQDExN0YXAubGlua2VyZC12aXouc3ZjMB4XDTI1MTEwNTEwMzIyMVoX\nDTI2MTEwNTEwMzIyMVowHjEcMBoGA1UEAxMTdGFwLmxpbmtlcmQtdml6LnN2YzCC\nASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAL352xG3KJSHpcDV38ow1ZW8\nUtVYSpgZQBfj4s2eeuOa0m424B91mEjf9H5C+xqnTju1IAkJWzMWWe/vuJYPwe4s\n8s9KXVqitpqzg9Xf6qAOgcID/ljEZBKHyIzVzWN6cj4tPWtK7Mhp0rIhk0CDPFDm\noWd2ZfQxi9KW6NBdvy5RInuwdxs6J88t8eS1vMXaL6CijqwukBb1Kvh18xH091Jr\nUYLiaBxh6tV8CdPPyZlUwHujCEhKWUtlwgUFfMc9q5wSjEaqz9XFIExGJ1r4ANKR\nSHUvddFzmxnBVUzqrDiePJoKY1zU7E0L8E7zfiOXphmQkLsbjXTwJjDxNJ4GitcC\nAwEAAaNfMF0wDgYDVR0PAQH/BAQDAgWgMB0GA1UdJQQWMBQGCCsGAQUFBwMBBggr\nBgEFBQcDAjAMBgNVHRMBAf8EAjAAMB4GA1UdEQQXMBWCE3RhcC5saW5rZXJkLXZp\nei5zdmMwDQYJKoZIhvcNAQELBQADggEBABolGFE0Mc+7+U0+ex+pbKwk0jGSezgF\n4oE+9/We7ABi+jawLjlkfinXD6a/yl13zuyVvPDrcNMss33+Zu9ckDo8VH/jy3HG\n86wUz6BKgwS/XGNzxjJBwL5YIP5pm5Ifkwd8s0hWJxWaxjGh63WGUOn7zQRpXtqm\nzDcAgHqcy+pYTl4XWt7Mx60rCPTKpMPQSHzzcuPhi8fN6obZnoO0dn7VpE5zWaqb\nXrGhO9YRp3hpC4F+18yG60cMIVQGHqLp+enqG6neELtrl+Sm0Fie7ds/vLP3Ueht\no5ZGHslplBYtuHQxfFgZo26oWXGZJpT2bAKB21SBoXYoM7VMr2mp7Mk=\n-----END CERTIFICATE-----"
    "tls.key" = "-----BEGIN RSA PRIVATE KEY-----\nMIIEogIBAAKCAQEAvfnbEbcolIelwNXfyjDVlbxS1VhKmBlAF+PizZ5645rSbjbg\nH3WYSN/0fkL7GqdOO7UgCQlbMxZZ7++4lg/B7izyz0pdWqK2mrOD1d/qoA6BwgP+\nWMRkEofIjNXNY3pyPi09a0rsyGnSsiGTQIM8UOahZ3Zl9DGL0pbo0F2/LlEie7B3\nGzonzy3x5LW8xdovoKKOrC6QFvUq+HXzEfT3UmtRguJoHGHq1XwJ08/JmVTAe6MI\nSEpZS2XCBQV8xz2rnBKMRqrP1cUgTEYnWvgA0pFIdS910XObGcFVTOqsOJ48mgpj\nXNTsTQvwTvN+I5emGZCQuxuNdPAmMPE0ngaK1wIDAQABAoIBABIQqFxO5nT5UTG9\nJMK9UhIjDl1rP+ymugmLig2zfEwYdNo2LanQLOMBKOa4x9gJAM98sccqNJnvDi5a\nxVq/tNlJPO2pTKdJwcOEPo0f9deyiXRBnPYj9sAsWU3LJvTGuAZhlu2U+l80cOyv\ndKk10Y5/3+lOwPMvovQrlYf64istMgDSK5uYOu5yNwCSDnAH7hHhDBADjPNZWanX\nJogZcuEqJySbGZHkayyFPB89T96Q7m6WsC5TUdfmY5GaZeIgGyfpERKJRxT40c1P\nsUTjU2yZBi/nnujKDWcqFB4MD5WDEvYknOyJGafBxf352CmOZ6/C1c5TSNaguDgJ\nCbaM0wECgYEA3kk9mVCR6yqtUHW/g9fw5f3cegIsNgvqLDyWif7kILQ9gNtVQ3be\n0Bj4FIb21KotIy7gS5sXgtot1DJ1b8mP5StwumIn/Gh0B1TMkZA1tB/JLNbE8zNs\nM2gkFSpX3lO9/cIouKIu6d7B0a0IkT+0xJ6a8+hnRWq3C11rPkr7IzECgYEA2soa\nSK/henqONYeQt7GC1Y5vaGuWB5pk1TIlEGBLNiQNRLXrNItN/Mr1TtTXBYjrRT9n\nwg6oJn6uv9CsqY9XyWWdLcKQ4+4kdGbRYv7SY7SSGUe/rFYFLc453ttBEtdLB5WE\nNgT/zIA5H6DwQoWhGryUxIoIcbJqcjW7ILvvvIcCgYBGOftlEYhYNK52ygyMec+Y\nyeA7B66yEIeWHDovNMEb9/WqXSEN5GM2eXz+9zjKLU1/XRLtr/z4kTeDX8GsZJC6\nhUPjDpm1a8akfkz2/AmLc7NaICwu7aMUhqVHro3+JpTSs+Grm0mZB5BSTwly4h6Z\nM8aeomDmFHXp+ESmdIftMQKBgAkY4DDnh0OVdvZI1b6dlegVTRKVbp6QT+MBe8ML\njfUJWLfjrIz5wdtiAQMvHGWxhL7TXRgXjexT1iZJofRG7oqEPB3b+jRQAZoJcGli\nWRMmPfDpJ9IdnYeDDKr0iOckpo0BLYclfBFfv4BOK89ISSOYdcMaTjGUDpMDIu3A\ngr5fAoGAATxk7DP7LwnUSim2Zg+XagHf53vTczo+LLRKCdzsV+mg7x3LcItVovrF\nhSxPg5U8s/xTy6pJdXttmYI37RBiZqGBC6KCowiXLks1Me0DOvD54BSMfr/1iBMC\ntwjZY51lJYiYNbVJwinGOomJ1cpqVvVGIXnlz4U9sVjmblg3jrg=\n-----END RSA PRIVATE KEY-----"
  }

  type = "kubernetes.io/tls"
}

resource "kubernetes_role" "web" {
  metadata {
    name      = "web"
    namespace = "linkerd"

    labels = {
      component              = "web"
      "linkerd.io/extension" = "viz"
      namespace              = "linkerd"
    }
  }

  rule {
    verbs          = ["get"]
    api_groups     = [""]
    resources      = ["configmaps"]
    resource_names = ["linkerd-config"]
  }

  rule {
    verbs      = ["get"]
    api_groups = [""]
    resources  = ["namespaces", "configmaps"]
  }

  rule {
    verbs      = ["list"]
    api_groups = [""]
    resources  = ["serviceaccounts", "pods"]
  }

  rule {
    verbs      = ["list"]
    api_groups = ["apps"]
    resources  = ["replicasets"]
  }
}

resource "kubernetes_role_binding" "web" {
  metadata {
    name      = "web"
    namespace = "linkerd"

    labels = {
      component              = "web"
      "linkerd.io/extension" = "viz"
      namespace              = "linkerd"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "web"
    namespace = "linkerd-viz"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "web"
  }
}

resource "kubernetes_cluster_role" "linkerd_linkerd_viz_web_check" {
  metadata {
    name = "linkerd-linkerd-viz-web-check"

    labels = {
      component              = "web"
      "linkerd.io/extension" = "viz"
    }
  }

  rule {
    verbs      = ["list"]
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["clusterroles", "clusterrolebindings"]
  }

  rule {
    verbs      = ["list"]
    api_groups = ["apiextensions.k8s.io"]
    resources  = ["customresourcedefinitions"]
  }

  rule {
    verbs      = ["list"]
    api_groups = ["admissionregistration.k8s.io"]
    resources  = ["mutatingwebhookconfigurations", "validatingwebhookconfigurations"]
  }

  rule {
    verbs      = ["list"]
    api_groups = ["linkerd.io"]
    resources  = ["serviceprofiles"]
  }

  rule {
    verbs      = ["list"]
    api_groups = [""]
    resources  = ["nodes", "pods", "services"]
  }

  rule {
    verbs      = ["get"]
    api_groups = ["apiregistration.k8s.io"]
    resources  = ["apiservices"]
  }
}

resource "kubernetes_cluster_role_binding" "linkerd_linkerd_viz_web_check" {
  metadata {
    name = "linkerd-linkerd-viz-web-check"

    labels = {
      component              = "web"
      "linkerd.io/extension" = "viz"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "web"
    namespace = "linkerd-viz"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "linkerd-linkerd-viz-web-check"
  }
}

resource "kubernetes_cluster_role_binding" "linkerd_linkerd_viz_web_admin" {
  metadata {
    name = "linkerd-linkerd-viz-web-admin"

    labels = {
      component              = "web"
      "linkerd.io/extension" = "viz"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "web"
    namespace = "linkerd-viz"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "linkerd-linkerd-viz-tap-admin"
  }
}

resource "kubernetes_cluster_role" "linkerd_linkerd_viz_web_api" {
  metadata {
    name = "linkerd-linkerd-viz-web-api"

    labels = {
      component              = "web"
      "linkerd.io/extension" = "viz"
    }
  }

  rule {
    verbs      = ["list"]
    api_groups = [""]
    resources  = ["namespaces"]
  }
}

resource "kubernetes_cluster_role_binding" "linkerd_linkerd_viz_web_api" {
  metadata {
    name = "linkerd-linkerd-viz-web-api"

    labels = {
      component              = "web"
      "linkerd.io/extension" = "viz"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "web"
    namespace = "linkerd-viz"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "linkerd-linkerd-viz-web-api"
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

resource "kubernetes_deployment" "metrics_api" {
  metadata {
    name      = "metrics-api"
    namespace = "linkerd-viz"

    labels = {
      "app.kubernetes.io/name"    = "metrics-api"
      "app.kubernetes.io/part-of" = "Linkerd"
      "app.kubernetes.io/version" = "edge-25.8.5"
      component                   = "metrics-api"
      "linkerd.io/extension"      = "viz"
    }

    annotations = {
      "config.linkerd.io/proxy-await" = "enabled"
      "linkerd.io/created-by"         = "linkerd/cli edge-25.8.5"
      "linkerd.io/inject"             = "enabled"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        component              = "metrics-api"
        "linkerd.io/extension" = "viz"
      }
    }

    template {
      metadata {
        labels = {
          component              = "metrics-api"
          "linkerd.io/extension" = "viz"
        }

        annotations = {
          "cluster-autoscaler.kubernetes.io/safe-to-evict"         = "true"
          "config.alpha.linkerd.io/proxy-wait-before-exit-seconds" = "0"
          "linkerd.io/created-by"                                  = "linkerd/cli edge-25.8.5"
          "linkerd.io/inject"                                      = "enabled"
        }
      }

      spec {
        volume {
          name = "kube-api-access"

          projected {
            sources {
              service_account_token {
                expiration_seconds = 3607
                path               = "token"
              }
            }

            sources {
              config_map {
                name = "kube-root-ca.crt"

                items {
                  key  = "ca.crt"
                  path = "ca.crt"
                }
              }
            }

            sources {
              downward_api {
                items {
                  path = "namespace"

                  field_ref {
                    api_version = "v1"
                    field_path  = "metadata.namespace"
                  }
                }
              }
            }

            default_mode = "0644"
          }
        }

        container {
          name  = "metrics-api"
          image = "cr.l5d.io/linkerd/metrics-api:edge-25.8.5"
          args  = ["-controller-namespace=linkerd", "-log-level=info", "-log-format=plain", "-cluster-domain=cluster.local", "-prometheus-url=http://prometheus.linkerd-viz.svc.cluster.local:9090", "-enable-pprof=false"]

          port {
            name           = "http"
            container_port = 8085
          }

          port {
            name           = "admin"
            container_port = 9995
          }

          volume_mount {
            name       = "kube-api-access"
            read_only  = true
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
          }

          liveness_probe {
            http_get {
              path = "/ping"
              port = "9995"
            }

            initial_delay_seconds = 10
          }

          readiness_probe {
            http_get {
              path = "/ready"
              port = "9995"
            }

            failure_threshold = 7
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            capabilities {
              drop = ["ALL"]
            }

            run_as_user               = 2103
            run_as_group              = 2103
            run_as_non_root           = true
            read_only_root_filesystem = true

            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "metrics-api"

        security_context {
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }
      }
    }

    revision_history_limit = 10
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

resource "kubernetes_deployment" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = "linkerd-viz"

    labels = {
      "app.kubernetes.io/name"    = "prometheus"
      "app.kubernetes.io/part-of" = "Linkerd"
      "app.kubernetes.io/version" = "edge-25.8.5"
      component                   = "prometheus"
      "linkerd.io/extension"      = "viz"
      namespace                   = "linkerd-viz"
    }

    annotations = {
      "config.linkerd.io/proxy-await" = "enabled"
      "linkerd.io/created-by"         = "linkerd/cli edge-25.8.5"
      "linkerd.io/inject"             = "enabled"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        component              = "prometheus"
        "linkerd.io/extension" = "viz"
        namespace              = "linkerd-viz"
      }
    }

    template {
      metadata {
        labels = {
          component              = "prometheus"
          "linkerd.io/extension" = "viz"
          namespace              = "linkerd-viz"
        }

        annotations = {
          "config.alpha.linkerd.io/proxy-wait-before-exit-seconds" = "0"
          "linkerd.io/created-by"                                  = "linkerd/cli edge-25.8.5"
          "linkerd.io/inject"                                      = "enabled"
        }
      }

      spec {
        volume {
          name      = "data"
          empty_dir = {}
        }

        volume {
          name = "prometheus-config"

          config_map {
            name = "prometheus-config"
          }
        }

        volume {
          name = "kube-api-access"

          projected {
            sources {
              service_account_token {
                expiration_seconds = 3607
                path               = "token"
              }
            }

            sources {
              config_map {
                name = "kube-root-ca.crt"

                items {
                  key  = "ca.crt"
                  path = "ca.crt"
                }
              }
            }

            sources {
              downward_api {
                items {
                  path = "namespace"

                  field_ref {
                    api_version = "v1"
                    field_path  = "metadata.namespace"
                  }
                }
              }
            }

            default_mode = "0644"
          }
        }

        container {
          name  = "prometheus"
          image = "prom/prometheus:v2.55.1"
          args  = ["--log.level=info", "--log.format=logfmt", "--config.file=/etc/prometheus/prometheus.yml", "--storage.tsdb.path=/data", "--storage.tsdb.retention.time=6h"]

          port {
            name           = "admin"
            container_port = 9090
          }

          volume_mount {
            name       = "data"
            mount_path = "/data"
          }

          volume_mount {
            name       = "prometheus-config"
            read_only  = true
            mount_path = "/etc/prometheus/prometheus.yml"
            sub_path   = "prometheus.yml"
          }

          volume_mount {
            name       = "kube-api-access"
            read_only  = true
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
          }

          liveness_probe {
            http_get {
              path = "/-/healthy"
              port = "9090"
            }

            initial_delay_seconds = 30
            timeout_seconds       = 30
          }

          readiness_probe {
            http_get {
              path = "/-/ready"
              port = "9090"
            }

            initial_delay_seconds = 30
            timeout_seconds       = 30
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            capabilities {
              drop = ["ALL"]
            }

            run_as_user               = 65534
            run_as_group              = 65534
            run_as_non_root           = true
            read_only_root_filesystem = true

            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "prometheus"

        security_context {
          fs_group = 65534

          seccomp_profile {
            type = "RuntimeDefault"
          }
        }
      }
    }

    revision_history_limit = 10
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

resource "kubernetes_deployment" "tap" {
  metadata {
    name      = "tap"
    namespace = "linkerd-viz"

    labels = {
      "app.kubernetes.io/name"    = "tap"
      "app.kubernetes.io/part-of" = "Linkerd"
      "app.kubernetes.io/version" = "edge-25.8.5"
      component                   = "tap"
      "linkerd.io/extension"      = "viz"
      namespace                   = "linkerd-viz"
    }

    annotations = {
      "config.linkerd.io/proxy-await" = "enabled"
      "linkerd.io/created-by"         = "linkerd/cli edge-25.8.5"
      "linkerd.io/inject"             = "enabled"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        component              = "tap"
        "linkerd.io/extension" = "viz"
        namespace              = "linkerd-viz"
      }
    }

    template {
      metadata {
        labels = {
          component              = "tap"
          "linkerd.io/extension" = "viz"
          namespace              = "linkerd-viz"
        }

        annotations = {
          "cluster-autoscaler.kubernetes.io/safe-to-evict"         = "true"
          "config.alpha.linkerd.io/proxy-wait-before-exit-seconds" = "0"
          "linkerd.io/created-by"                                  = "linkerd/cli edge-25.8.5"
          "linkerd.io/inject"                                      = "enabled"
        }
      }

      spec {
        volume {
          name = "tls"

          secret {
            secret_name = "tap-k8s-tls"
          }
        }

        volume {
          name = "kube-api-access"

          projected {
            sources {
              service_account_token {
                expiration_seconds = 3607
                path               = "token"
              }
            }

            sources {
              config_map {
                name = "kube-root-ca.crt"

                items {
                  key  = "ca.crt"
                  path = "ca.crt"
                }
              }
            }

            sources {
              downward_api {
                items {
                  path = "namespace"

                  field_ref {
                    api_version = "v1"
                    field_path  = "metadata.namespace"
                  }
                }
              }
            }

            default_mode = "0644"
          }
        }

        container {
          name  = "tap"
          image = "cr.l5d.io/linkerd/tap:edge-25.8.5"
          args  = ["api", "-api-namespace=linkerd", "-log-level=info", "-log-format=plain", "-identity-trust-domain=cluster.local", "-enable-pprof=false"]

          port {
            name           = "grpc"
            container_port = 8088
          }

          port {
            name           = "apiserver"
            container_port = 8089
          }

          port {
            name           = "admin"
            container_port = 9998
          }

          volume_mount {
            name       = "tls"
            read_only  = true
            mount_path = "/var/run/linkerd/tls"
          }

          volume_mount {
            name       = "kube-api-access"
            read_only  = true
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
          }

          liveness_probe {
            http_get {
              path = "/ping"
              port = "9998"
            }

            initial_delay_seconds = 10
          }

          readiness_probe {
            http_get {
              path = "/ready"
              port = "9998"
            }

            failure_threshold = 7
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            capabilities {
              drop = ["ALL"]
            }

            run_as_user               = 2103
            run_as_group              = 2103
            run_as_non_root           = true
            read_only_root_filesystem = true

            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "tap"

        security_context {
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }
      }
    }

    revision_history_limit = 10
  }
}

resource "kubernetes_cluster_role" "linkerd_tap_injector" {
  metadata {
    name = "linkerd-tap-injector"

    labels = {
      "linkerd.io/extension" = "viz"
    }
  }

  rule {
    verbs      = ["get", "list", "watch"]
    api_groups = [""]
    resources  = ["namespaces"]
  }
}

resource "kubernetes_cluster_role_binding" "linkerd_tap_injector" {
  metadata {
    name = "linkerd-tap-injector"

    labels = {
      "linkerd.io/extension" = "viz"
    }
  }

  subject {
    kind      = "ServiceAccount"
    name      = "tap-injector"
    namespace = "linkerd-viz"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "linkerd-tap-injector"
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

resource "kubernetes_secret" "tap_injector_k_8_s_tls" {
  metadata {
    name      = "tap-injector-k8s-tls"
    namespace = "linkerd-viz"

    labels = {
      "linkerd.io/extension" = "viz"
    }

    annotations = {
      "linkerd.io/created-by" = "linkerd/cli edge-25.8.5"
    }
  }

  data = {
    "tls.crt" = "-----BEGIN CERTIFICATE-----\nMIIDQDCCAiigAwIBAgIQFa4TTwlAldF9ebUMkc/IbTANBgkqhkiG9w0BAQsFADAn\nMSUwIwYDVQQDExx0YXAtaW5qZWN0b3IubGlua2VyZC12aXouc3ZjMB4XDTI1MTEw\nNTEwMzIyMVoXDTI2MTEwNTEwMzIyMVowJzElMCMGA1UEAxMcdGFwLWluamVjdG9y\nLmxpbmtlcmQtdml6LnN2YzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB\nAJk7wU/Nf22Ua3IVQTBlOKtp21FjyUZKD6/Gv9eDMeag+UALlCsy9iuexXPgJFIR\nwB/K6bgc6dCF0IoFWLev86e/jojA/Ye3UbC+8Ub0UpP08FUDn4GBAl9fjKNsPNZP\n5sO/I+R1UaU2e33ukNPD3iFy7py41mE3K9WpdKFzPy61V7T5OQfjy5D1spdHilfu\nRY3S6SBQrGY0xIh4wXN2vkhGzTc/yjsqC2UXzziiV4Z0HDwGSPmSSPBt0F7sR74H\nofMLbfDOIAiZdCyCUcRpwN0syfqQpcJ031fmVDEXJnBU/6vCJEN1w6b71G+/mmXE\nzt763JZuy58yN78Fl/NXJx8CAwEAAaNoMGYwDgYDVR0PAQH/BAQDAgWgMB0GA1Ud\nJQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAMBgNVHRMBAf8EAjAAMCcGA1UdEQQg\nMB6CHHRhcC1pbmplY3Rvci5saW5rZXJkLXZpei5zdmMwDQYJKoZIhvcNAQELBQAD\nggEBAJQfWryH1NtiegWovOhwlbMmLYUI8Psh+Za9iv54KVdQlnEeLWHGXFvAoRsY\nOr5/A1Ep4pdRJat8DTkeKB3r492gxmA8eXgbbXgazDkSSYZPPCBsknUeffkyaG6w\n3i2HPzs8ufWd3XlDNrMJ5U5GSSVf76c6OK2XryjyEuJUWgclucOQT2r95QYxIVp6\nveNSu+p9UJCy99Qmpma2G/hzq6eYVoAZjeZRH3+qMqckZjpfjiiKfbOacIthcCXC\nE4htkRC8h7Yxp7t8Jm/AChYoqq/kh1EC4kgDBmcK2QhOoikMzCkhgDlm/u8RaSJA\naub24IvdhdI8w5CeSokz/ekFc8E=\n-----END CERTIFICATE-----"
    "tls.key" = "-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEAmTvBT81/bZRrchVBMGU4q2nbUWPJRkoPr8a/14Mx5qD5QAuU\nKzL2K57Fc+AkUhHAH8rpuBzp0IXQigVYt6/zp7+OiMD9h7dRsL7xRvRSk/TwVQOf\ngYECX1+Mo2w81k/mw78j5HVRpTZ7fe6Q08PeIXLunLjWYTcr1al0oXM/LrVXtPk5\nB+PLkPWyl0eKV+5FjdLpIFCsZjTEiHjBc3a+SEbNNz/KOyoLZRfPOKJXhnQcPAZI\n+ZJI8G3QXuxHvgeh8wtt8M4gCJl0LIJRxGnA3SzJ+pClwnTfV+ZUMRcmcFT/q8Ik\nQ3XDpvvUb7+aZcTO3vrclm7LnzI3vwWX81cnHwIDAQABAoIBAAofKVjFITqyyBok\nD0dMGF8yQdtxdPUgpUKeJUPuFZi/X1d8rE/iMOKWvUI3Nw74vzEabS/NMSCmBi1n\nxwFzLOwSui6MWPLjCBFdu4BNWTsOveVPtPSP+gEkxZxx5N7fLkYV1SAdI8R/Ac9C\nt+xVDtI0zlAp4XdQdqPJarvTagQCulgEq08eoVw3tcPbvvO4ctkaETkm8w3IyPm3\nss0vWeQEqOgXmuoVN3b4vvLlLCP5MH42tGxTL1jrxFWYuBlH6VEhCbdUYEOXVk/S\nG5ikgZHv4xMsBayUt/Us6OOH4nXy+607dwCVyVA/btKlef2+vlGL1Tm9kWyatXgk\ncLm/f/ECgYEAwEbgJxH00dHER9rHI418qPxJRv2sf3P1k7LgEftQEKR4JcVMCzqc\nDjeluabnLtfg8bPrkgJsbk4VAAUtQKSHqYM/psG+Z2cxAteP1RoxWmrjBCe8QLzI\nTMtmMjKzQRtA6yiKXt2ip4TImtZ807e1H92e4eMsO5/6K9wLIcH6c0cCgYEAzARc\npLCSC2Dd6vgFeAfr7jPuJTobrWfRoDeLhspme0sSEtnS7NnfNaQtqyVEtQ/z03Wk\nZ6mGgHIGqKYWcueWpLKZSPc7RPZZ14J1COQq55LJNdLiEGwD8ZY06G2jd7QzvXOY\n+hXEVPYZfyNTai2TBWLOeu60NlYkHPxaY2BcqWkCgYEAj8JuRcf/LAGSp8bDralT\n02UNxK5WEtU4f732Gnu0WT0fN95UBPFFTLv+hNhtcXCnFxBWyUxWlgJ7YRB9zR82\n717acGvbWKSm2GEjgUmcLOZN5gVvk1eSyxgoyM9vhvZBi5E8I8HCo018T4ievA1W\ntwSUjn+zysDJ45EaIZtPDnECgYA82/g+8KVAW68XjtEi00ogDsG1vTXQbq3r22X1\n2Z7knKpRkUUIfp3FRKqS6VUrpgyYQfm/KqUC4AD4gkMkF82qZ9SuHYJCujJmxXXg\nJyBdYD5BnhztxSsQADzcMQiYhtsAYuF5iNC+f4Nvl7wkal/3NVhe96Iuq1euheD4\n0CAUMQKBgCeV572oSnkPiG/PhPhLxNKAn0TpwyAKwrKQOK2aHVi4fsm7JFLjjcle\nc3FO0oCdzOGwfJddpRSszRszr2N+aKW7oLsWxhzyesC0SgcpQWq2+r2K0acAdJZS\nuDRhgdHX0d34P3Evi/AAJmA5ADblMaVrdV0vOPDPwIzgNt01K7pX\n-----END RSA PRIVATE KEY-----"
  }

  type = "kubernetes.io/tls"
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

resource "kubernetes_deployment" "tap_injector" {
  metadata {
    name      = "tap-injector"
    namespace = "linkerd-viz"

    labels = {
      "app.kubernetes.io/name"    = "tap-injector"
      "app.kubernetes.io/part-of" = "Linkerd"
      component                   = "tap-injector"
      "linkerd.io/extension"      = "viz"
    }

    annotations = {
      "config.linkerd.io/proxy-await" = "enabled"
      "linkerd.io/created-by"         = "linkerd/cli edge-25.8.5"
      "linkerd.io/inject"             = "enabled"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        component = "tap-injector"
      }
    }

    template {
      metadata {
        labels = {
          component              = "tap-injector"
          "linkerd.io/extension" = "viz"
        }

        annotations = {
          "cluster-autoscaler.kubernetes.io/safe-to-evict"         = "true"
          "config.alpha.linkerd.io/proxy-wait-before-exit-seconds" = "0"
          "linkerd.io/created-by"                                  = "linkerd/cli edge-25.8.5"
          "linkerd.io/inject"                                      = "enabled"
        }
      }

      spec {
        volume {
          name = "tls"

          secret {
            secret_name = "tap-injector-k8s-tls"
          }
        }

        volume {
          name = "kube-api-access"

          projected {
            sources {
              service_account_token {
                expiration_seconds = 3607
                path               = "token"
              }
            }

            sources {
              config_map {
                name = "kube-root-ca.crt"

                items {
                  key  = "ca.crt"
                  path = "ca.crt"
                }
              }
            }

            sources {
              downward_api {
                items {
                  path = "namespace"

                  field_ref {
                    api_version = "v1"
                    field_path  = "metadata.namespace"
                  }
                }
              }
            }

            default_mode = "0644"
          }
        }

        container {
          name  = "tap-injector"
          image = "cr.l5d.io/linkerd/tap:edge-25.8.5"
          args  = ["injector", "-tap-service-name=tap.linkerd-viz.serviceaccount.identity.linkerd.cluster.local", "-log-level=info", "-log-format=plain", "-enable-pprof=false"]

          port {
            name           = "tap-injector"
            container_port = 8443
          }

          port {
            name           = "admin"
            container_port = 9995
          }

          volume_mount {
            name       = "tls"
            read_only  = true
            mount_path = "/var/run/linkerd/tls"
          }

          volume_mount {
            name       = "kube-api-access"
            read_only  = true
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
          }

          liveness_probe {
            http_get {
              path = "/ping"
              port = "9995"
            }

            initial_delay_seconds = 10
          }

          readiness_probe {
            http_get {
              path = "/ready"
              port = "9995"
            }

            failure_threshold = 7
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            capabilities {
              drop = ["ALL"]
            }

            run_as_user               = 2103
            run_as_group              = 2103
            run_as_non_root           = true
            read_only_root_filesystem = true

            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "tap-injector"

        security_context {
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }
      }
    }

    revision_history_limit = 10
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

resource "kubernetes_deployment" "web" {
  metadata {
    name      = "web"
    namespace = "linkerd-viz"

    labels = {
      "app.kubernetes.io/name"    = "web"
      "app.kubernetes.io/part-of" = "Linkerd"
      "app.kubernetes.io/version" = "edge-25.8.5"
      component                   = "web"
      "linkerd.io/extension"      = "viz"
      namespace                   = "linkerd-viz"
    }

    annotations = {
      "config.linkerd.io/proxy-await" = "enabled"
      "linkerd.io/created-by"         = "linkerd/cli edge-25.8.5"
      "linkerd.io/inject"             = "enabled"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        component              = "web"
        "linkerd.io/extension" = "viz"
        namespace              = "linkerd-viz"
      }
    }

    template {
      metadata {
        labels = {
          component              = "web"
          "linkerd.io/extension" = "viz"
          namespace              = "linkerd-viz"
        }

        annotations = {
          "cluster-autoscaler.kubernetes.io/safe-to-evict"         = "true"
          "config.alpha.linkerd.io/proxy-wait-before-exit-seconds" = "0"
          "linkerd.io/created-by"                                  = "linkerd/cli edge-25.8.5"
          "linkerd.io/inject"                                      = "enabled"
        }
      }

      spec {
        volume {
          name = "kube-api-access"

          projected {
            sources {
              service_account_token {
                expiration_seconds = 3607
                path               = "token"
              }
            }

            sources {
              config_map {
                name = "kube-root-ca.crt"

                items {
                  key  = "ca.crt"
                  path = "ca.crt"
                }
              }
            }

            sources {
              downward_api {
                items {
                  path = "namespace"

                  field_ref {
                    api_version = "v1"
                    field_path  = "metadata.namespace"
                  }
                }
              }
            }

            default_mode = "0644"
          }
        }

        container {
          name  = "web"
          image = "cr.l5d.io/linkerd/web:edge-25.8.5"
          args  = ["-linkerd-metrics-api-addr=metrics-api.linkerd-viz.svc.cluster.local:8085", "-cluster-domain=cluster.local", "-controller-namespace=linkerd", "-log-level=info", "-log-format=plain", "-enforced-host=^(localhost|127\\.0\\.0\\.1|web\\.linkerd-viz\\.svc\\.cluster\\.local|web\\.linkerd-viz\\.svc|\\[::1\\])(:\\d+)?$", "-enable-pprof=false"]

          port {
            name           = "http"
            container_port = 8084
          }

          port {
            name           = "admin"
            container_port = 9994
          }

          volume_mount {
            name       = "kube-api-access"
            read_only  = true
            mount_path = "/var/run/secrets/kubernetes.io/serviceaccount"
          }

          liveness_probe {
            http_get {
              path = "/ping"
              port = "9994"
            }

            initial_delay_seconds = 10
          }

          readiness_probe {
            http_get {
              path = "/ready"
              port = "9994"
            }

            failure_threshold = 7
          }

          image_pull_policy = "IfNotPresent"

          security_context {
            capabilities {
              drop = ["ALL"]
            }

            run_as_user               = 2103
            run_as_group              = 2103
            run_as_non_root           = true
            read_only_root_filesystem = true

            seccomp_profile {
              type = "RuntimeDefault"
            }
          }
        }

        node_selector = {
          "kubernetes.io/os" = "linux"
        }

        service_account_name = "web"

        security_context {
          seccomp_profile {
            type = "RuntimeDefault"
          }
        }
      }
    }

    revision_history_limit = 10
  }
}

