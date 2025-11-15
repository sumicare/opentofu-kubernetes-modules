## Sumicare [Kube State Metrics](https://github.com/kubernetes/kube-state-metrics) OpenTofu Modules

This module deploys [Kube State Metrics](https://github.com/kubernetes/kube-state-metrics) to the cluster.

Kube State Metrics is a simple service that listens to the Kubernetes API server and generates metrics about the state of the objects.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  kube_state_metrics_version = "2.17.0"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "kube_state_metrics_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-kube-state-metrics/modules/kube-state-metrics-image"
  debian_version = locals.debian_version
  kube_state_metrics_version = locals.kube_state_metrics_version

  depends_on = [module.debian_images]
}

module "kube_state_metrics" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-kube-state-metrics/modules/kube-state-metrics-chart"
  kube_state_metrics_version = locals.kube_state_metrics_version

  depends_on = [module.kube_state_metrics_image]
}
```

### Parameters

| Name                       | Description                           | Type   | Default                  | Required   |
|----------------------------|---------------------------------------|--------|--------------------------|------------|
| debian_version             | Debian version for the image          | string | `"trixie-20251117-slim"` | no         |
| kube_state_metrics_version | Kube State Metrics version to deploy  | string | `"2.17.0"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
