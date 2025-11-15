## Sumicare [Argo Workflows](https://github.com/argoproj/argo-workflows) OpenTofu Modules

This module deploys [Argo Workflows](https://github.com/argoproj/argo-workflows) to the cluster.

Argo Workflows is an open source container-native workflow engine for orchestrating parallel jobs on Kubernetes.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  argo_workflows_version = "3.7.4"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "argo_workflows_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/gitops-argo-workflows/modules/argo-workflows-image"
  debian_version = locals.debian_version
  argo_workflows_version = locals.argo_workflows_version

  depends_on = [module.debian_images]
}

module "argo_workflows" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/gitops-argo-workflows/modules/argo-workflows-chart"
  argo_workflows_version = locals.argo_workflows_version

  depends_on = [module.argo_workflows_image]
}
```

### Parameters

| Name                   | Description                        | Type   | Default                  | Required   |
|------------------------|------------------------------------|--------|--------------------------|------------|
| debian_version         | Debian version for the image       | string | `"trixie-20251117-slim"` | no         |
| argo_workflows_version | Argo Workflows version to deploy   | string | `"3.7.4"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
