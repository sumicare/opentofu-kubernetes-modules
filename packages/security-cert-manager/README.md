## Sumicare [cert-manager](https://github.com/cert-manager/cert-manager) OpenTofu Modules

This module deploys [cert-manager](https://github.com/cert-manager/cert-manager) to the cluster.

cert-manager is a Kubernetes add-on to automate the management and issuance of TLS certificates from various issuing sources.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  cert_manager_version = "1.19.1"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "cert_manager_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/security-cert-manager/modules/cert-manager-image"
  debian_version = locals.debian_version
  cert_manager_version = locals.cert_manager_version

  depends_on = [module.debian_images]
}

module "cert_manager" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/security-cert-manager/modules/cert-manager-chart"
  cert_manager_version = locals.cert_manager_version

  depends_on = [module.cert_manager_image]
}
```

### Parameters

| Name                 | Description                       | Type   | Default                  | Required   |
|----------------------|-----------------------------------|--------|--------------------------|------------|
| debian_version       | Debian version for the image      | string | `"trixie-20251117-slim"` | no         |
| cert_manager_version | cert-manager version to deploy    | string | `"1.19.1"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
