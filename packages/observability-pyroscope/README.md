## Sumicare [Pyroscope](https://github.com/grafana/pyroscope) OpenTofu Modules

This module deploys [Pyroscope](https://github.com/grafana/pyroscope) to the cluster.

Grafana Pyroscope is an open source continuous profiling platform for debugging performance issues.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  pyroscope_version = "1.16.0"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "pyroscope_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-pyroscope/modules/pyroscope-image"
  debian_version = locals.debian_version
  pyroscope_version = locals.pyroscope_version

  depends_on = [module.debian_images]
}

module "pyroscope" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-pyroscope/modules/pyroscope-chart"
  pyroscope_version = locals.pyroscope_version

  depends_on = [module.pyroscope_image]
}
```

### Parameters

| Name              | Description                     | Type   | Default                  | Required   |
|-------------------|---------------------------------|--------|--------------------------|------------|
| debian_version    | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| pyroscope_version | Pyroscope version to deploy     | string | `"1.16.0"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
