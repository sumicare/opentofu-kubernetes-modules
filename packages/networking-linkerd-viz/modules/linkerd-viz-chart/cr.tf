resource "kubernetes_manifest" "apiservice_v1alpha1_tap_linkerd_io" {
  manifest = {
    "apiVersion" = "apiregistration.k8s.io/v1"
    "kind"       = "APIService"
    "metadata" = {
      "labels" = {
        "component"            = "tap"
        "linkerd.io/extension" = "viz"
      }
      "name" = "v1alpha1.tap.linkerd.io"
    }
    "spec" = {
      "caBundle"             = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURKakNDQWc2Z0F3SUJBZ0lSQVA5c0pTRUN5SDVSVEd5R3BxU21RMHN3RFFZSktvWklodmNOQVFFTEJRQXcKSGpFY01Cb0dBMVVFQXhNVGRHRndMbXhwYm10bGNtUXRkbWw2TG5OMll6QWVGdzB5TlRFeE1EVXhNRE15TWpWYQpGdzB5TmpFeE1EVXhNRE15TWpWYU1CNHhIREFhQmdOVkJBTVRFM1JoY0M1c2FXNXJaWEprTFhacGVpNXpkbU13CmdnRWlNQTBHQ1NxR1NJYjNEUUVCQVFVQUE0SUJEd0F3Z2dFS0FvSUJBUURiZWw5aWErY1FoM2hid0o3ejRqbXQKN2RnN2ZqRVkxSjQ3dTRvalJRRGlYVWx1VWlFbEtraWJ0Q0djeERNT1NRVkpVZDZrY3l1QVhPK0oyTjRCcnFmbwpPZVpkTkhEdmVOcjlaNUlKTjhjWnk4WHRidEdON1pkVzRLeVZZbGh1K3JyRlM5OVBjMkxYNHBQWGhkMit3YXM1CmlpVWZjQmQ0TFBqd3FZdEhvOGptaGhGa29KY3FDSVBBdWl0Yjl6OGtsanY0OVJUNzBjMkN1Q3k5amZtaGhxNlEKUlBtdk1YTUVZdTZoM2E0NlBZbzlMZG12cEJwUWZpRTd0YUdCUFF1elhRWlVOSERWeEZwaEJvckk4aytRODJ2aAo5aEttc3JFN01HcHF1cU03MVJFeUM2T3FQVjhQdnhDT2lQcUVsNzZIYVRNZXdLUjUxMFp3ZkIyN1FFNUNJTnFMCkFnTUJBQUdqWHpCZE1BNEdBMVVkRHdFQi93UUVBd0lGb0RBZEJnTlZIU1VFRmpBVUJnZ3JCZ0VGQlFjREFRWUkKS3dZQkJRVUhBd0l3REFZRFZSMFRBUUgvQkFJd0FEQWVCZ05WSFJFRUZ6QVZnaE4wWVhBdWJHbHVhMlZ5WkMxMgphWG91YzNaak1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQkZwbGFwb0FHa1V3bmIzeVVINktwU3FaOHZWbkRMCjBZcHhMVTNPZ0hyRzM0RkxydDdHMnRJTWkzSlBKUWVVbTNobTJ5UEUwbnZFR1lvRkN2WUZPUnlhdU5XUGI4R3oKK21CSDhzWlhIdVhkK2FXV1RxY08zYUxnNW5jMTR3OWRJSTJQOWJNeGZuZlVMaFRzY1pLTkxpd0VLdXpnV21xSgpiNmZUTjZOZDhaMnlhUGhqVHZob2VXbDQvOUlTTVB6Zy9GUjRCRkFWS2crQ0orUTd6T2hmOGNRclphbU5PRkxGClRJQ0NZT0FnSDBKK081OGJBcVFaaHlGNU9VOGM3QjF4S1RyajY5TlY4QVA5VkxmSXpHRG5FV3dvY1JSdTVkaG0KaDNJVDNTai84ak1FZFFaUmswb3JqSGFRUGhpcDBXbVpoMDdqWUc0NzhiL3hRQUw4OEUybVBhRjUKLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQ=="
      "group"                = "tap.linkerd.io"
      "groupPriorityMinimum" = 1000
      "service" = {
        "name"      = "tap"
        "namespace" = "linkerd-viz"
      }
      "version"         = "v1alpha1"
      "versionPriority" = 100
    }
  }
}

resource "kubernetes_manifest" "server_linkerd_viz_metrics_api" {
  manifest = {
    "apiVersion" = "policy.linkerd.io/v1beta3"
    "kind"       = "Server"
    "metadata" = {
      "annotations" = {
        "linkerd.io/created-by" = "linkerd/cli edge-25.8.5"
      }
      "labels" = {
        "component"            = "metrics-api"
        "linkerd.io/extension" = "viz"
      }
      "name"      = "metrics-api"
      "namespace" = "linkerd-viz"
    }
    "spec" = {
      "podSelector" = {
        "matchLabels" = {
          "component"            = "metrics-api"
          "linkerd.io/extension" = "viz"
        }
      }
      "port"          = "http"
      "proxyProtocol" = "HTTP/1"
    }
  }
}

resource "kubernetes_manifest" "authorizationpolicy_linkerd_viz_metrics_api" {
  manifest = {
    "apiVersion" = "policy.linkerd.io/v1alpha1"
    "kind"       = "AuthorizationPolicy"
    "metadata" = {
      "annotations" = {
        "linkerd.io/created-by" = "linkerd/cli edge-25.8.5"
      }
      "labels" = {
        "component"            = "metrics-api"
        "linkerd.io/extension" = "viz"
      }
      "name"      = "metrics-api"
      "namespace" = "linkerd-viz"
    }
    "spec" = {
      "requiredAuthenticationRefs" = [
        {
          "group" = "policy.linkerd.io"
          "kind"  = "MeshTLSAuthentication"
          "name"  = "metrics-api-web"
        },
      ]
      "targetRef" = {
        "group" = "policy.linkerd.io"
        "kind"  = "Server"
        "name"  = "metrics-api"
      }
    }
  }
}

resource "kubernetes_manifest" "meshtlsauthentication_linkerd_viz_metrics_api_web" {
  manifest = {
    "apiVersion" = "policy.linkerd.io/v1alpha1"
    "kind"       = "MeshTLSAuthentication"
    "metadata" = {
      "annotations" = {
        "linkerd.io/created-by" = "linkerd/cli edge-25.8.5"
      }
      "labels" = {
        "component"            = "metrics-api"
        "linkerd.io/extension" = "viz"
      }
      "name"      = "metrics-api-web"
      "namespace" = "linkerd-viz"
    }
    "spec" = {
      "identityRefs" = [
        {
          "kind" = "ServiceAccount"
          "name" = "web"
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "networkauthentication_linkerd_viz_kubelet" {
  manifest = {
    "apiVersion" = "policy.linkerd.io/v1alpha1"
    "kind"       = "NetworkAuthentication"
    "metadata" = {
      "annotations" = {
        "linkerd.io/created-by" = "linkerd/cli edge-25.8.5"
      }
      "labels" = {
        "linkerd.io/extension" = "viz"
      }
      "name"      = "kubelet"
      "namespace" = "linkerd-viz"
    }
    "spec" = {
      "networks" = [
        {
          "cidr" = "0.0.0.0/0"
        },
        {
          "cidr" = "::/0"
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "server_linkerd_viz_prometheus_admin" {
  manifest = {
    "apiVersion" = "policy.linkerd.io/v1beta3"
    "kind"       = "Server"
    "metadata" = {
      "annotations" = {
        "linkerd.io/created-by" = "linkerd/cli edge-25.8.5"
      }
      "labels" = {
        "linkerd.io/extension" = "viz"
      }
      "name"      = "prometheus-admin"
      "namespace" = "linkerd-viz"
    }
    "spec" = {
      "podSelector" = {
        "matchLabels" = {
          "component"            = "prometheus"
          "linkerd.io/extension" = "viz"
          "namespace"            = "linkerd-viz"
        }
      }
      "port"          = "admin"
      "proxyProtocol" = "HTTP/1"
    }
  }
}

resource "kubernetes_manifest" "authorizationpolicy_linkerd_viz_prometheus_admin" {
  manifest = {
    "apiVersion" = "policy.linkerd.io/v1alpha1"
    "kind"       = "AuthorizationPolicy"
    "metadata" = {
      "annotations" = {
        "linkerd.io/created-by" = "linkerd/cli edge-25.8.5"
      }
      "labels" = {
        "linkerd.io/extension" = "viz"
      }
      "name"      = "prometheus-admin"
      "namespace" = "linkerd-viz"
    }
    "spec" = {
      "requiredAuthenticationRefs" = [
        {
          "kind"      = "ServiceAccount"
          "name"      = "metrics-api"
          "namespace" = "linkerd-viz"
        },
      ]
      "targetRef" = {
        "group" = "policy.linkerd.io"
        "kind"  = "Server"
        "name"  = "prometheus-admin"
      }
    }
  }
}

resource "kubernetes_manifest" "server_linkerd_viz_tap_api" {
  manifest = {
    "apiVersion" = "policy.linkerd.io/v1beta3"
    "kind"       = "Server"
    "metadata" = {
      "annotations" = {
        "linkerd.io/created-by" = "linkerd/cli edge-25.8.5"
      }
      "labels" = {
        "component"            = "tap"
        "linkerd.io/extension" = "viz"
      }
      "name"      = "tap-api"
      "namespace" = "linkerd-viz"
    }
    "spec" = {
      "podSelector" = {
        "matchLabels" = {
          "component"            = "tap"
          "linkerd.io/extension" = "viz"
        }
      }
      "port"          = "apiserver"
      "proxyProtocol" = "TLS"
    }
  }
}

resource "kubernetes_manifest" "authorizationpolicy_linkerd_viz_tap" {
  manifest = {
    "apiVersion" = "policy.linkerd.io/v1alpha1"
    "kind"       = "AuthorizationPolicy"
    "metadata" = {
      "annotations" = {
        "linkerd.io/created-by" = "linkerd/cli edge-25.8.5"
      }
      "labels" = {
        "component"            = "tap"
        "linkerd.io/extension" = "viz"
      }
      "name"      = "tap"
      "namespace" = "linkerd-viz"
    }
    "spec" = {
      "requiredAuthenticationRefs" = [
        {
          "group" = "policy.linkerd.io"
          "kind"  = "NetworkAuthentication"
          "name"  = "kube-api-server"
        },
      ]
      "targetRef" = {
        "group" = "policy.linkerd.io"
        "kind"  = "Server"
        "name"  = "tap-api"
      }
    }
  }
}

resource "kubernetes_manifest" "mutatingwebhookconfiguration_linkerd_tap_injector_webhook_config" {
  manifest = {
    "apiVersion" = "admissionregistration.k8s.io/v1"
    "kind"       = "MutatingWebhookConfiguration"
    "metadata" = {
      "labels" = {
        "linkerd.io/extension" = "viz"
      }
      "name" = "linkerd-tap-injector-webhook-config"
    }
    "webhooks" = [
      {
        "admissionReviewVersions" = [
          "v1",
          "v1beta1",
        ]
        "clientConfig" = {
          "caBundle" = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURRRENDQWlpZ0F3SUJBZ0lRU0p1c2lPYzAvTEZpNHVkM01VM24zakFOQmdrcWhraUc5dzBCQVFzRkFEQW4KTVNVd0l3WURWUVFERXh4MFlYQXRhVzVxWldOMGIzSXViR2x1YTJWeVpDMTJhWG91YzNaak1CNFhEVEkxTVRFdwpOVEV3TXpJeU5Wb1hEVEkyTVRFd05URXdNekl5TlZvd0p6RWxNQ01HQTFVRUF4TWNkR0Z3TFdsdWFtVmpkRzl5CkxteHBibXRsY21RdGRtbDZMbk4yWXpDQ0FTSXdEUVlKS29aSWh2Y05BUUVCQlFBRGdnRVBBRENDQVFvQ2dnRUIKQU1LamsrZllRdW5LYkZFWGN6eUlSU2w0amRSRUN2TGhjbkczVFh6Smlud3JqSE43bnZ6NG0zU2EwZkxleDhCVgpHUlVaSlZIZlFuUkhNMU9yejdYZkhFSGIrN3ZmaEM1cEhuT0hDUDh4d2lTVnlNdTJIazdvRkJXUTNqYzBiWXZLCllxbWVzZk1kOXJJZFA2by92MmpoaVZaVFZWMS92YnNycWgrTzgzQ3AvR1R6NThzY1owaWQwOVFocVIwdEtkZTIKUFNXL2Jsd2Y0US9qOExOZUFLUG9LR2E0bUtrZWZKbkZ3aEdlSE5oNGRzQWgvVWhLU0Eybk9IanQyT2QwSitkVQpVamlGTmxKNlBxMlJrMVBGQWVObGZJbVlsM281NGhlYTQ5NFVURXhXUzBrWEtkdVRuTS8wSlVrRUk1U1dEdWlMCnVFU2Q0QUY3d1ZKWGxLRWRFaVd1SElFQ0F3RUFBYU5vTUdZd0RnWURWUjBQQVFIL0JBUURBZ1dnTUIwR0ExVWQKSlFRV01CUUdDQ3NHQVFVRkJ3TUJCZ2dyQmdFRkJRY0RBakFNQmdOVkhSTUJBZjhFQWpBQU1DY0dBMVVkRVFRZwpNQjZDSEhSaGNDMXBibXBsWTNSdmNpNXNhVzVyWlhKa0xYWnBlaTV6ZG1Nd0RRWUpLb1pJaHZjTkFRRUxCUUFECmdnRUJBRFJ1cndVbUJYTmJsTjF2Wno3MWdPcjZXb1NyRVZiTkk2ZEl4YTB4K2t5aVJZSVRkU3hvUiszeWY2ZEYKZnlNam1zUml3aWpka1FrcjloUmZOVW1sRWRzdkZsMDFzbGlJNnVRRFBwV3VXODQ2NUZOajU2MjdIK0FFRjdNYwpMQnNBb3lMNitSMERmL3dnVk9wNUVGcXFXRU00NzA5eDZ0bi8xQTMwbFM1WGdIMjBpL25rQ0VHOW5xOWRHWWpvCkUyVnZhYXZJN0IxOExDZjBCTUJieWZlTUlNeEJuSHFnU2RKdTlWV0FsOFlaSnhGQk9reDd6VE1oY2U2eFJoS3MKWlo4MTRNd3BlNjNXR0N4TmZyMjl0TnRlWlBKZ1hDejMwN24xT0d2NFNTa3JDQUZ5M3VoTEZKblBRRnpXakg2cgptdkFXNFdlNGJLYm5xQ1RRRlUrMkFZSVRLRWs9Ci0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0="
          "service" = {
            "name"      = "tap-injector"
            "namespace" = "linkerd-viz"
            "path"      = "/"
          }
        }
        "failurePolicy" = "Ignore"
        "name"          = "tap-injector.linkerd.io"
        "namespaceSelector" = {
          "matchExpressions" = [
            {
              "key"      = "kubernetes.io/metadata.name"
              "operator" = "NotIn"
              "values" = [
                "kube-system",
              ]
            },
          ]
        }
        "reinvocationPolicy" = "IfNeeded"
        "rules" = [
          {
            "apiGroups" = [
              "",
            ]
            "apiVersions" = [
              "v1",
            ]
            "operations" = [
              "CREATE",
            ]
            "resources" = [
              "pods",
            ]
            "scope" = "Namespaced"
          },
        ]
        "sideEffects" = "None"
      },
    ]
  }
}

resource "kubernetes_manifest" "server_linkerd_viz_tap_injector_webhook" {
  manifest = {
    "apiVersion" = "policy.linkerd.io/v1beta3"
    "kind"       = "Server"
    "metadata" = {
      "annotations" = {
        "linkerd.io/created-by" = "linkerd/cli edge-25.8.5"
      }
      "labels" = {
        "component"            = "tap-injector"
        "linkerd.io/extension" = "viz"
      }
      "name"      = "tap-injector-webhook"
      "namespace" = "linkerd-viz"
    }
    "spec" = {
      "podSelector" = {
        "matchLabels" = {
          "component"            = "tap-injector"
          "linkerd.io/extension" = "viz"
        }
      }
      "port"          = "tap-injector"
      "proxyProtocol" = "TLS"
    }
  }
}

resource "kubernetes_manifest" "authorizationpolicy_linkerd_viz_tap_injector" {
  manifest = {
    "apiVersion" = "policy.linkerd.io/v1alpha1"
    "kind"       = "AuthorizationPolicy"
    "metadata" = {
      "annotations" = {
        "linkerd.io/created-by" = "linkerd/cli edge-25.8.5"
      }
      "labels" = {
        "component"            = "tap-injector"
        "linkerd.io/extension" = "viz"
      }
      "name"      = "tap-injector"
      "namespace" = "linkerd-viz"
    }
    "spec" = {
      "requiredAuthenticationRefs" = [
        {
          "group" = "policy.linkerd.io"
          "kind"  = "NetworkAuthentication"
          "name"  = "kube-api-server"
        },
      ]
      "targetRef" = {
        "group" = "policy.linkerd.io"
        "kind"  = "Server"
        "name"  = "tap-injector-webhook"
      }
    }
  }
}

resource "kubernetes_manifest" "networkauthentication_linkerd_viz_kube_api_server" {
  manifest = {
    "apiVersion" = "policy.linkerd.io/v1alpha1"
    "kind"       = "NetworkAuthentication"
    "metadata" = {
      "annotations" = {
        "linkerd.io/created-by" = "linkerd/cli edge-25.8.5"
      }
      "labels" = {
        "linkerd.io/extension" = "viz"
      }
      "name"      = "kube-api-server"
      "namespace" = "linkerd-viz"
    }
    "spec" = {
      "networks" = [
        {
          "cidr" = "0.0.0.0/0"
        },
        {
          "cidr" = "::/0"
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "serviceprofile_linkerd_viz_metrics_api_linkerd_viz_svc_cluster_local" {
  manifest = {
    "apiVersion" = "linkerd.io/v1alpha2"
    "kind"       = "ServiceProfile"
    "metadata" = {
      "labels" = {
        "linkerd.io/extension" = "viz"
      }
      "name"      = "metrics-api.linkerd-viz.svc.cluster.local"
      "namespace" = "linkerd-viz"
    }
    "spec" = {
      "routes" = [
        {
          "condition" = {
            "method"    = "POST"
            "pathRegex" = "/api/v1/StatSummary"
          }
          "name" = "POST /api/v1/StatSummary"
        },
        {
          "condition" = {
            "method"    = "POST"
            "pathRegex" = "/api/v1/TopRoutes"
          }
          "name" = "POST /api/v1/TopRoutes"
        },
        {
          "condition" = {
            "method"    = "POST"
            "pathRegex" = "/api/v1/ListPods"
          }
          "name" = "POST /api/v1/ListPods"
        },
        {
          "condition" = {
            "method"    = "POST"
            "pathRegex" = "/api/v1/ListServices"
          }
          "name" = "POST /api/v1/ListServices"
        },
        {
          "condition" = {
            "method"    = "POST"
            "pathRegex" = "/api/v1/SelfCheck"
          }
          "name" = "POST /api/v1/SelfCheck"
        },
        {
          "condition" = {
            "method"    = "POST"
            "pathRegex" = "/api/v1/Gateways"
          }
          "name" = "POST /api/v1/Gateways"
        },
        {
          "condition" = {
            "method"    = "POST"
            "pathRegex" = "/api/v1/Edges"
          }
          "name" = "POST /api/v1/Edges"
        },
      ]
    }
  }
}

resource "kubernetes_manifest" "serviceprofile_linkerd_viz_prometheus_linkerd_viz_svc_cluster_local" {
  manifest = {
    "apiVersion" = "linkerd.io/v1alpha2"
    "kind"       = "ServiceProfile"
    "metadata" = {
      "labels" = {
        "linkerd.io/extension" = "viz"
      }
      "name"      = "prometheus.linkerd-viz.svc.cluster.local"
      "namespace" = "linkerd-viz"
    }
    "spec" = {
      "routes" = [
        {
          "condition" = {
            "method"    = "POST"
            "pathRegex" = "/api/v1/query"
          }
          "name" = "POST /api/v1/query"
        },
        {
          "condition" = {
            "method"    = "GET"
            "pathRegex" = "/api/v1/query_range"
          }
          "name" = "GET /api/v1/query_range"
        },
        {
          "condition" = {
            "method"    = "GET"
            "pathRegex" = "/api/v1/series"
          }
          "name" = "GET /api/v1/series"
        },
      ]
    }
  }
}
