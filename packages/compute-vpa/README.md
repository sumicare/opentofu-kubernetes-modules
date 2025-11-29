## Sumicare [Vertical Pod Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler) OpenTofu Modules

Deploys [Vertical Pod Autoscaler](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler) for automatic resource right-sizing.

VPA continuously analyzes container resource usage and automatically adjusts CPU/memory requests and limits, eliminating manual tuning while optimizing cluster utilization. Required for [Goldilocks](../compute-goldilocks/) recommendations.

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

By using this project for academic, advertising, enterprise, or any other purpose, <br/>
you grant your **Implicit Agreement** to the Sumicare OSS [Terms of Use](../../OSS_TERMS.md).

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
