## Sumicare [Argo CD](https://github.com/argoproj/argo-cd) OpenTofu Modules

This module deploys [Argo CD](https://github.com/argoproj/argo-cd) to the cluster.

Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  argo_cd_version = "3.2.0"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "argo_cd_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/gitops-argo-cd/modules/argo-cd-image"
  debian_version = locals.debian_version
  argo_cd_version = locals.argo_cd_version

  depends_on = [module.debian_images]
}

module "argo_cd" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/gitops-argo-cd/modules/argo-cd-chart"
  argo_cd_version = locals.argo_cd_version

  depends_on = [module.argo_cd_image]
}
```

### Parameters

| Name            | Description                     | Type   | Default                  | Required   |
|-----------------|---------------------------------|--------|--------------------------|------------|
| debian_version  | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| argo_cd_version | Argo CD version to deploy       | string | `"3.2.0"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
