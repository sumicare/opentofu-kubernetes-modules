## Sumicare [PVC Autoresizer](https://github.com/topolvm/pvc-autoresizer) OpenTofu Modules

This module deploys [PVC Autoresizer](https://github.com/topolvm/pvc-autoresizer) to the cluster.

PVC Autoresizer is a Kubernetes operator that automatically expands PersistentVolumeClaims when they are running low on capacity.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  pvc_autoresizer_version = "0.18.0"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "pvc_autoresizer_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/storage-pvc-autoresizer/modules/pvc-autoresizer-image"
  debian_version = locals.debian_version
  pvc_autoresizer_version = locals.pvc_autoresizer_version

  depends_on = [module.debian_images]
}

module "pvc_autoresizer" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/storage-pvc-autoresizer/modules/pvc-autoresizer-chart"
  pvc_autoresizer_version = locals.pvc_autoresizer_version

  depends_on = [module.pvc_autoresizer_image]
}
```

### Parameters

| Name                    | Description                        | Type   | Default                  | Required   |
|-------------------------|------------------------------------|--------|--------------------------|------------|
| debian_version          | Debian version for the image       | string | `"trixie-20251117-slim"` | no         |
| pvc_autoresizer_version | PVC Autoresizer version to deploy  | string | `"0.18.0"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
