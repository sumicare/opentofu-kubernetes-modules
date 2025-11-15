## Sumicare [Local Path Provisioner](https://github.com/rancher/local-path-provisioner) OpenTofu Modules

This module deploys [Local Path Provisioner](https://github.com/rancher/local-path-provisioner) to the cluster.

Local Path Provisioner provides a way for Kubernetes users to utilize the local storage in each node.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  local_path_provisioner_version = "0.0.32"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "local_path_provisioner_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/storage-local-path-provisioner/modules/local-path-provisioner-image"
  debian_version = locals.debian_version
  local_path_provisioner_version = locals.local_path_provisioner_version

  depends_on = [module.debian_images]
}

module "local_path_provisioner" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/storage-local-path-provisioner/modules/local-path-provisioner-chart"
  local_path_provisioner_version = locals.local_path_provisioner_version

  depends_on = [module.local_path_provisioner_image]
}
```

### Parameters

| Name                           | Description                              | Type   | Default                  | Required   |
|--------------------------------|------------------------------------------|--------|--------------------------|------------|
| debian_version                 | Debian version for the image             | string | `"trixie-20251117-slim"` | no         |
| local_path_provisioner_version | Local Path Provisioner version to deploy | string | `"0.0.32"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
