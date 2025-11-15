## Sumicare [Dex](https://github.com/dexidp/dex) OpenTofu Modules

This module deploys [Dex](https://github.com/dexidp/dex) to the cluster.

Dex is an identity service that uses OpenID Connect to drive authentication for other apps. It acts as a portal to other identity providers through connectors.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  dex_version = "2.44.0"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "dex_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/development-dex/modules/dex-image"
  debian_version = locals.debian_version
  dex_version = locals.dex_version

  depends_on = [module.debian_images]
}

module "dex" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/development-dex/modules/dex-chart"
  dex_version = locals.dex_version

  depends_on = [module.dex_image]
}
```

### Parameters

| Name           | Description                     | Type   | Default                  | Required   |
|----------------|---------------------------------|--------|--------------------------|------------|
| debian_version | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| dex_version    | Dex version to deploy           | string | `"2.44.0"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
