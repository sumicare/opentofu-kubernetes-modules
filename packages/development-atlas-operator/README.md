## Sumicare [Atlas Operator](https://github.com/ariga/atlas-operator) OpenTofu Modules

This module deploys [Atlas Operator](https://github.com/ariga/atlas-operator) to the cluster.

Atlas Operator is a Kubernetes operator that enables declarative database schema management using Atlas.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  atlas_operator_version = "0.7.13"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "atlas_operator_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/development-atlas-operator/modules/atlas-operator-image"
  debian_version = locals.debian_version
  atlas_operator_version = locals.atlas_operator_version

  depends_on = [module.debian_images]
}

module "atlas_operator" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/development-atlas-operator/modules/atlas-operator-chart"
  atlas_operator_version = locals.atlas_operator_version

  depends_on = [module.atlas_operator_image]
}
```

### Parameters

| Name                   | Description                        | Type   | Default                  | Required   |
|------------------------|------------------------------------|--------|--------------------------|------------|
| debian_version         | Debian version for the image       | string | `"trixie-20251117-slim"` | no         |
| atlas_operator_version | Atlas Operator version to deploy   | string | `"0.7.13"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
