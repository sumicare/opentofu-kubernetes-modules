## Sumicare [Grafana](https://github.com/grafana/grafana) OpenTofu Modules

This module deploys [Grafana](https://github.com/grafana/grafana) to the cluster.

Grafana is the open source analytics and monitoring solution for every database.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  grafana_version = "12.3.0"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "grafana_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-grafana/modules/grafana-image"
  debian_version = locals.debian_version
  grafana_version = locals.grafana_version

  depends_on = [module.debian_images]
}

module "grafana" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-grafana/modules/grafana-chart"
  grafana_version = locals.grafana_version

  depends_on = [module.grafana_image]
}
```

### Parameters

| Name            | Description                     | Type   | Default                  | Required   |
|-----------------|---------------------------------|--------|--------------------------|------------|
| debian_version  | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| grafana_version | Grafana version to deploy       | string | `"12.3.0"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
