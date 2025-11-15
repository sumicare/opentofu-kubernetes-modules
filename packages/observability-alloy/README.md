## Sumicare [Grafana Alloy](https://github.com/grafana/alloy) OpenTofu Modules

This module deploys [Grafana Alloy](https://github.com/grafana/alloy) to the cluster.

Grafana Alloy is an OpenTelemetry Collector distribution with configuration inspired by Terraform.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  alloy_version = "1.11.3"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "alloy_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-alloy/modules/alloy-image"
  debian_version = locals.debian_version
  alloy_version = locals.alloy_version

  depends_on = [module.debian_images]
}

module "alloy" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-alloy/modules/alloy-chart"
  alloy_version = locals.alloy_version

  depends_on = [module.alloy_image]
}
```

### Parameters

| Name           | Description                     | Type   | Default                  | Required   |
|----------------|---------------------------------|--------|--------------------------|------------|
| debian_version | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| alloy_version  | Alloy version to deploy         | string | `"1.11.3"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
