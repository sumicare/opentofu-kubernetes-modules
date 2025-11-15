## Sumicare [KEDA](https://github.com/kedacore/keda) OpenTofu Modules

This module deploys [KEDA](https://github.com/kedacore/keda) to the cluster.

KEDA (Kubernetes Event-driven Autoscaling) is a single-purpose and lightweight component that can be added to any Kubernetes cluster. It allows for fine-grained autoscaling for event-driven workloads.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  keda_version = "2.18.1"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "keda_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/compute-keda/modules/keda-image"
  debian_version = locals.debian_version
  keda_version = locals.keda_version

  depends_on = [module.debian_images]
}

module "keda" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/compute-keda/modules/keda-chart"
  keda_version = locals.keda_version

  depends_on = [module.keda_image]
}
```

### Parameters

| Name           | Description                     | Type   | Default                  | Required   |
|----------------|---------------------------------|--------|--------------------------|------------|
| debian_version | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| keda_version   | KEDA version to deploy          | string | `"2.18.1"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
