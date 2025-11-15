## Sumicare [Goldilocks](https://github.com/FairwindsOps/goldilocks) OpenTofu Modules

This module deploys [Goldilocks](https://github.com/FairwindsOps/goldilocks) to the cluster.

Goldilocks is a Kubernetes operator that enforces resource requests and limits based on the cluster's capacity. It automatically creates VPA custom resources for each target namespace.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  goldilocks_version = "4.14.7"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "goldilocks_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/compute-goldilocks/modules/goldilocks-image"
  debian_version = locals.debian_version
  goldilocks_version = locals.goldilocks_version

  depends_on = [module.debian_images]
}

module "goldilocks" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/compute-goldilocks/modules/goldilocks-chart"
  goldilocks_version = locals.goldilocks_version

  depends_on = [module.goldilocks_image]
}
```

### Parameters

| Name               | Description                     | Type   | Default                  | Required   |
|--------------------|---------------------------------|--------|--------------------------|------------|
| debian_version     | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| goldilocks_version | Goldilocks version to deploy    | string | `"4.14.7"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
