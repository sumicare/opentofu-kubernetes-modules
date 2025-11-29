## Sumicare [Kamaji](https://github.com/clastix/kamaji) OpenTofu Modules

Deploys [Kamaji](https://github.com/clastix/kamaji) for multi-tenant Kubernetes control plane management.

Kamaji enables hosting multiple Kubernetes control planes as pods within a single management cluster, dramatically reducing infrastructure costs and operational overhead for multi-cluster environments while maintaining full tenant isolation.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  kamaji_version = "25.11.5"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "kamaji_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/compute-kamaji/modules/kamaji-image"
  debian_version = locals.debian_version
  kamaji_version = locals.kamaji_version

  depends_on = [module.debian_images]
}

module "kamaji" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/compute-kamaji/modules/kamaji-chart"
  kamaji_version = locals.kamaji_version

  depends_on = [module.kamaji_image]
}
```

### Parameters

| Name           | Description                     | Type   | Default                  | Required   |
|----------------|---------------------------------|--------|--------------------------|------------|
| debian_version | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| kamaji_version | Kamaji version to deploy        | string | `"25.11.5"` | no         |

### License

Copyright 2025 Sumicare

By using this project for academic, advertising, enterprise, or any other purpose, <br/>
you grant your **Implicit Agreement** to the Sumicare OSS [Terms of Use](../../OSS_TERMS.md).

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
