## Sumicare [Grafana MCP](https://github.com/grafana/mcp-grafana) OpenTofu Modules

This module deploys [Grafana MCP](https://github.com/grafana/mcp-grafana) to the cluster.

Grafana MCP is a Model Context Protocol server for Grafana.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  grafana_mcp_version = "0.7.9"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "grafana_mcp_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-grafana-mcp/modules/grafana-mcp-image"
  debian_version = locals.debian_version
  grafana_mcp_version = locals.grafana_mcp_version

  depends_on = [module.debian_images]
}

module "grafana_mcp" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-grafana-mcp/modules/grafana-mcp-chart"
  grafana_mcp_version = locals.grafana_mcp_version

  depends_on = [module.grafana_mcp_image]
}
```

### Parameters

| Name                | Description                      | Type   | Default                  | Required   |
|---------------------|----------------------------------|--------|--------------------------|------------|
| debian_version      | Debian version for the image     | string | `"trixie-20251117-slim"` | no         |
| grafana_mcp_version | Grafana MCP version to deploy    | string | `"0.7.9"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
