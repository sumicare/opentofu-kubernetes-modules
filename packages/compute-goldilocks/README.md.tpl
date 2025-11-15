## Sumicare [Goldilocks](https://github.com/FairwindsOps/goldilocks) OpenTofu Modules

Deploys [Goldilocks](https://github.com/FairwindsOps/goldilocks) for right-sizing Kubernetes workload resources.

Goldilocks provides a dashboard that analyzes VPA recommendations to help identify optimal CPU and memory requests/limits for your workloads, reducing over-provisioning costs while preventing resource starvation.

### Usage

```terraform

locals {
  debian_version = "{{index .Versions "debian"}}"
  goldilocks_version = "{{index .Versions "compute-goldilocks"}}"
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
| debian_version     | Debian version for the image    | string | `"{{index .Versions "debian"}}"` | no         |
| goldilocks_version | Goldilocks version to deploy    | string | `"{{index .Versions "compute-goldilocks"}}"` | no         |

### License

Copyright 2025 Sumicare

By using this project for academic, advertising, enterprise, or any other purpose, <br/>
you grant your **Implicit Agreement** to the Sumicare OSS [Terms of Use](../../OSS_TERMS.md).

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
