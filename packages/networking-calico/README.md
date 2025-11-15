## Sumicare [Calico](https://github.com/projectcalico/calico) OpenTofu Modules

This module deploys [Calico](https://github.com/projectcalico/calico) to the cluster.

Calico is an open source networking and network security solution for containers, virtual machines, and native host-based workloads.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  calico_version = "3.31.2"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "calico_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/networking-calico/modules/calico-image"
  debian_version = locals.debian_version
  calico_version = locals.calico_version

  depends_on = [module.debian_images]
}

module "calico" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/networking-calico/modules/calico-chart"
  calico_version = locals.calico_version

  depends_on = [module.calico_image]
}
```

### Parameters

| Name           | Description                     | Type   | Default                  | Required   |
|----------------|---------------------------------|--------|--------------------------|------------|
| debian_version | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| calico_version | Calico version to deploy        | string | `"3.31.2"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
