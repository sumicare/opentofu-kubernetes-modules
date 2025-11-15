## Sumicare [Metrics Server](https://github.com/kubernetes-sigs/metrics-server) OpenTofu Modules

This module deploys [Metrics Server](https://github.com/kubernetes-sigs/metrics-server) to the cluster.

Metrics Server is a scalable, efficient source of container resource metrics for Kubernetes built-in autoscaling pipelines.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  metrics_server_version = "0.8.0"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "metrics_server_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-metrics-server/modules/metrics-server-image"
  debian_version = locals.debian_version
  metrics_server_version = locals.metrics_server_version

  depends_on = [module.debian_images]
}

module "metrics_server" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-metrics-server/modules/metrics-server-chart"
  metrics_server_version = locals.metrics_server_version

  depends_on = [module.metrics_server_image]
}
```

### Parameters

| Name                   | Description                        | Type   | Default                  | Required   |
|------------------------|------------------------------------|--------|--------------------------|------------|
| debian_version         | Debian version for the image       | string | `"trixie-20251117-slim"` | no         |
| metrics_server_version | Metrics Server version to deploy   | string | `"0.8.0"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
