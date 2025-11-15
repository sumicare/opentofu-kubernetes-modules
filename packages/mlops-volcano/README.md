## Sumicare [Volcano](https://github.com/volcano-sh/volcano) OpenTofu Modules

This module deploys [Volcano](https://github.com/volcano-sh/volcano) to the cluster.

Volcano is a batch system built on Kubernetes for high-performance workloads including machine learning, deep learning, bioinformatics, and genomics.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  volcano_version = "1.13.0"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "volcano_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/mlops-volcano/modules/volcano-images"
  debian_version = locals.debian_version
  volcano_version = locals.volcano_version

  depends_on = [module.debian_images]
}

module "volcano" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/mlops-volcano/modules/volcano-chart"
  volcano_version = locals.volcano_version

  depends_on = [module.volcano_image]
}
```

### Parameters

| Name            | Description                     | Type   | Default                  | Required   |
|-----------------|---------------------------------|--------|--------------------------|------------|
| debian_version  | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| volcano_version | Volcano version to deploy       | string | `"1.13.0"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
