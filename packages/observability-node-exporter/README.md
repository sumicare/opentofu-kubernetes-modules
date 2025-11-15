## Sumicare [Node Exporter](https://github.com/prometheus/node_exporter) OpenTofu Modules

This module deploys [Node Exporter](https://github.com/prometheus/node_exporter) to the cluster.

Node Exporter is a Prometheus exporter for hardware and OS metrics exposed by *NIX kernels.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  node_exporter_version = "1.10.2"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "node_exporter_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-node-exporter/modules/node-exporter-image"
  debian_version = locals.debian_version
  node_exporter_version = locals.node_exporter_version

  depends_on = [module.debian_images]
}

module "node_exporter" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-node-exporter/modules/node-exporter-chart"
  node_exporter_version = locals.node_exporter_version

  depends_on = [module.node_exporter_image]
}
```

### Parameters

| Name                  | Description                       | Type   | Default                  | Required   |
|-----------------------|-----------------------------------|--------|--------------------------|------------|
| debian_version        | Debian version for the image      | string | `"trixie-20251117-slim"` | no         |
| node_exporter_version | Node Exporter version to deploy   | string | `"1.10.2"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
