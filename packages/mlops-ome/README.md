## Sumicare [OME](https://github.com/sgl-project/ome) OpenTofu Modules

This module deploys [OME](https://github.com/sgl-project/ome) to the cluster.

OME (Open Model Engine) is a high-performance inference engine for large language models.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  ome_version = "0.1.4"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "ome_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/mlops-ome/modules/ome-image"
  debian_version = locals.debian_version
  ome_version = locals.ome_version

  depends_on = [module.debian_images]
}

module "ome" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/mlops-ome/modules/ome-chart"
  ome_version = locals.ome_version

  depends_on = [module.ome_image]
}
```

### Parameters

| Name           | Description                     | Type   | Default                  | Required   |
|----------------|---------------------------------|--------|--------------------------|------------|
| debian_version | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| ome_version    | OME version to deploy           | string | `"0.1.4"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
