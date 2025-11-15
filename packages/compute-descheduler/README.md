## Sumicare [Descheduler](https://github.com/kubernetes-sigs/descheduler) OpenTofu Modules

This module deploys [Descheduler](https://github.com/kubernetes-sigs/descheduler) to the cluster, as [deployment](https://github.com/kubernetes-sigs/descheduler?tab=readme-ov-file#quick-start).

Descheduler is a Kubernetes operator that deschedules pods in order to resolve accumulated scheduling issues over time.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  descheduler_version = "0.34.0"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "descheduler_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/compute-descheduler/modules/descheduler-image"
  debian_version = locals.debian_version
  descheduler_version = locals.descheduler_version

  depends_on = [module.debian_images]
}

module "descheduler" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/compute-descheduler/modules/descheduler-chart"
  descheduler_version = locals.descheduler_version

  depends_on = [module.descheduler_image]
}
```

### Parameters

| Name                | Description                     | Type   | Default                  | Required   |
|---------------------|---------------------------------|--------|--------------------------|------------|
| debian_version      | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| descheduler_version | Descheduler version to deploy   | string | `"0.34.0"`               | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
