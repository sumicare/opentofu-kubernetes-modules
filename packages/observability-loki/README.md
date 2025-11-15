## Sumicare [Loki](https://github.com/grafana/loki) OpenTofu Modules

This module deploys [Loki](https://github.com/grafana/loki) to the cluster.

Loki is a horizontally-scalable, highly-available, multi-tenant log aggregation system inspired by Prometheus.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  loki_version = "2.8.3"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "loki_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-loki/modules/loki-image"
  debian_version = locals.debian_version
  loki_version = locals.loki_version

  depends_on = [module.debian_images]
}

module "loki" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-loki/modules/loki-chart"
  loki_version = locals.loki_version

  depends_on = [module.loki_image]
}
```

### Parameters

| Name           | Description                     | Type   | Default                  | Required   |
|----------------|---------------------------------|--------|--------------------------|------------|
| debian_version | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| loki_version   | Loki version to deploy          | string | `"2.8.3"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
