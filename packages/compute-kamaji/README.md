## Sumicare [Kamaji](https://github.com/clastix/kamaji) OpenTofu Modules

This module deploys [Kamaji](https://github.com/clastix/kamaji) to the cluster.

Kamaji is a Kubernetes operator that turns any Kubernetes cluster into a management cluster to host control planes of other Kubernetes clusters.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  kamaji_version = "25.11.5"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "kamaji_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/compute-kamaji/modules/kamaji-image"
  debian_version = locals.debian_version
  kamaji_version = locals.kamaji_version

  depends_on = [module.debian_images]
}

module "kamaji" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/compute-kamaji/modules/kamaji-chart"
  kamaji_version = locals.kamaji_version

  depends_on = [module.kamaji_image]
}
```

### Parameters

| Name           | Description                     | Type   | Default                  | Required   |
|----------------|---------------------------------|--------|--------------------------|------------|
| debian_version | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| kamaji_version | Kamaji version to deploy        | string | `"25.11.5"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
