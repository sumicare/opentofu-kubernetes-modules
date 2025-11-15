## Sumicare [Vertical Pod Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler) OpenTofu Modules

This module deploys [Vertical Pod Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler) to the cluster.

Vertical Pod Autoscaler (VPA) frees users from the necessity of setting up-to-date resource requests for the containers in their pods. VPA is a pre-requisite for [Goldilocks](../compute-goldilocks/).

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  vpa_version = "1.5.1"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "vpa_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/compute-vpa/modules/vpa-image"
  debian_version = locals.debian_version
  vpa_version = locals.vpa_version

  depends_on = [module.debian_images]
}

module "vpa" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/compute-vpa/modules/vpa-chart"
  vpa_version = locals.vpa_version

  depends_on = [module.vpa_image]
}
```

### Parameters

| Name           | Description                     | Type   | Default                  | Required   |
|----------------|---------------------------------|--------|--------------------------|------------|
| debian_version | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| vpa_version    | VPA version to deploy           | string | `"1.5.1"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
