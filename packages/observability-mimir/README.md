## Sumicare [Mimir](https://github.com/grafana/mimir) OpenTofu Modules

This module deploys [Mimir](https://github.com/grafana/mimir) to the cluster.

Grafana Mimir is an open source, horizontally scalable, highly available, multi-tenant TSDB for long-term storage for Prometheus.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  mimir_version = "3.0.1"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "mimir_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-mimir/modules/mimir-image"
  debian_version = locals.debian_version
  mimir_version = locals.mimir_version

  depends_on = [module.debian_images]
}

module "mimir" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-mimir/modules/mimir-chart"
  mimir_version = locals.mimir_version

  depends_on = [module.mimir_image]
}
```

### Parameters

| Name           | Description                     | Type   | Default                  | Required   |
|----------------|---------------------------------|--------|--------------------------|------------|
| debian_version | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| mimir_version  | Mimir version to deploy         | string | `"3.0.1"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
