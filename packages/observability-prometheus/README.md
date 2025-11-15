## Sumicare [Prometheus](https://github.com/prometheus/prometheus) OpenTofu Modules

This module deploys [Prometheus](https://github.com/prometheus/prometheus) to the cluster.

Prometheus is a systems and service monitoring system that collects metrics from configured targets at given intervals.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  prometheus_version = "3.7.3"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "prometheus_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-prometheus/modules/prometheus-image"
  debian_version = locals.debian_version
  prometheus_version = locals.prometheus_version

  depends_on = [module.debian_images]
}

module "prometheus" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-prometheus/modules/prometheus-chart"
  prometheus_version = locals.prometheus_version

  depends_on = [module.prometheus_image]
}
```

### Parameters

| Name               | Description                     | Type   | Default                  | Required   |
|--------------------|---------------------------------|--------|--------------------------|------------|
| debian_version     | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| prometheus_version | Prometheus version to deploy    | string | `"3.7.3"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
