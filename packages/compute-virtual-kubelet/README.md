## Sumicare [Virtual Kubelet](https://github.com/virtual-kubelet/virtual-kubelet) OpenTofu Modules

Deploys [Virtual Kubelet](https://github.com/virtual-kubelet/virtual-kubelet) to extend cluster capacity with external compute.

Virtual Kubelet presents external services (serverless platforms, IoT devices, other clusters) as virtual nodes in Kubernetes, enabling seamless workload bursting to cloud providers or hybrid infrastructure without managing additional physical nodes.

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

By using this project for academic, advertising, enterprise, or any other purpose, <br/>
you grant your **Implicit Agreement** to the Sumicare OSS [Terms of Use](../../OSS_TERMS.md).

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
