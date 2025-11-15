## Sumicare [Tekton Chains](https://github.com/tektoncd/chains) OpenTofu Modules

This module deploys [Tekton Chains](https://github.com/tektoncd/chains) to the cluster.

Tekton Chains is a Kubernetes Custom Resource Definition (CRD) controller that allows you to manage your supply chain security in Tekton Pipelines.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  tekton_chains_version = "0.26.0"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "tekton_chains_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/development-tekton-chains/modules/tekton-chains-image"
  debian_version = locals.debian_version
  tekton_chains_version = locals.tekton_chains_version

  depends_on = [module.debian_images]
}

module "tekton_chains" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/development-tekton-chains/modules/tekton-chains-chart"
  tekton_chains_version = locals.tekton_chains_version

  depends_on = [module.tekton_chains_image]
}
```

### Parameters

| Name                  | Description                       | Type   | Default                  | Required   |
|-----------------------|-----------------------------------|--------|--------------------------|------------|
| debian_version        | Debian version for the image      | string | `"trixie-20251117-slim"` | no         |
| tekton_chains_version | Tekton Chains version to deploy   | string | `"0.26.0"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
