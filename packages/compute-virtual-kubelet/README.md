## Sumicare [Virtual Kubelet](https://github.com/virtual-kubelet/virtual-kubelet) OpenTofu Modules

This module deploys [Virtual Kubelet](https://github.com/virtual-kubelet/virtual-kubelet) to the cluster.

Virtual Kubelet is an open source Kubernetes kubelet implementation that masquerades as a kubelet for the purposes of connecting Kubernetes to other APIs.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  virtual_kubelet_version = "1.11.0"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "virtual_kubelet_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/compute-virtual-kubelet/modules/virtual-kubelet-image"
  debian_version = locals.debian_version
  virtual_kubelet_version = locals.virtual_kubelet_version

  depends_on = [module.debian_images]
}

module "virtual_kubelet" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/compute-virtual-kubelet/modules/virtual-kubelet-chart"
  virtual_kubelet_version = locals.virtual_kubelet_version

  depends_on = [module.virtual_kubelet_image]
}
```

### Parameters

| Name                    | Description                        | Type   | Default                  | Required   |
|-------------------------|------------------------------------|--------|--------------------------|------------|
| debian_version          | Debian version for the image       | string | `"trixie-20251117-slim"` | no         |
| virtual_kubelet_version | Virtual Kubelet version to deploy  | string | `"1.11.0"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
