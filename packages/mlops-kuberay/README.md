## Sumicare [KubeRay](https://github.com/ray-project/kuberay) OpenTofu Modules

This module deploys [KubeRay](https://github.com/ray-project/kuberay) to the cluster.

KubeRay is a Kubernetes operator for Ray, making it easy to run Ray applications on Kubernetes.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  kuberay_version = "1.5.1"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "kuberay_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/mlops-kuberay/modules/kuberay-image"
  debian_version = locals.debian_version
  kuberay_version = locals.kuberay_version

  depends_on = [module.debian_images]
}

module "kuberay" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/mlops-kuberay/modules/kuberay-chart"
  kuberay_version = locals.kuberay_version

  depends_on = [module.kuberay_image]
}
```

### Parameters

| Name            | Description                     | Type   | Default                  | Required   |
|-----------------|---------------------------------|--------|--------------------------|------------|
| debian_version  | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| kuberay_version | KubeRay version to deploy       | string | `"1.5.1"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
