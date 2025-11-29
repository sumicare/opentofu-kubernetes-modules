## Sumicare [Zot](https://github.com/project-zot/zot) OpenTofu Modules

Deploys [Zot](https://github.com/project-zot/zot) as a lightweight OCI-native artifact registry.

Zot provides a single-binary, vendor-neutral registry for container images and OCI artifacts with built-in deduplication, garbage collection, and optional S3 backend support—ideal for air-gapped environments and edge deployments.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  zot_version = "2.1.11"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "zot_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/development-zot/modules/zot-image"
  debian_version = locals.debian_version
  zot_version = locals.zot_version

  depends_on = [module.debian_images]
}

module "zot" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/development-zot/modules/zot-chart"
  zot_version = locals.zot_version

  depends_on = [module.zot_image]
}
```

### Parameters

| Name           | Description                     | Type   | Default                  | Required   |
|----------------|---------------------------------|--------|--------------------------|------------|
| debian_version | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| zot_version    | Zot version to deploy           | string | `"2.1.11"` | no         |

### License

Copyright 2025 Sumicare

By using this project for academic, advertising, enterprise, or any other purpose, <br/>
you grant your **Implicit Agreement** to the Sumicare OSS [Terms of Use](../../OSS_TERMS.md).

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
