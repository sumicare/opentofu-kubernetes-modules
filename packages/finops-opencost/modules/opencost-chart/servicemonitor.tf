resource "kubernetes_manifest" "servicemonitor_release_name_opencost" {
  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata   = {
      name      = local.app_name
      namespace = var.namespace
      labels    = local.labels
    }
    spec       = {
      endpoints = [
        {
          honor_labels = true
          interval     = "30s"
          path         = "/metrics"
          port         = "http"
          scheme       = "http"
          scrape_timeout = "10s"
        },
      ]
      namespaceSelector = {
        matchNames = [
          var.namespace,
        ]
      }
      selector = {
        matchLabels = local.selector_labels
      }
    }
  }
}
