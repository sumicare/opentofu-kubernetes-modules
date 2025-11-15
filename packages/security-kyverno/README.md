## Sumicare [Kyverno](https://github.com/kyverno/kyverno) OpenTofu Modules

This module deploys [Kyverno](https://github.com/kyverno/kyverno) to the cluster.

Kyverno is a policy engine designed for Kubernetes that can validate, mutate, and generate configurations using admission controls and background scans.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  kyverno_version = "1.16.0"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "kyverno_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/security-kyverno/modules/kyverno-image"
  debian_version = locals.debian_version
  kyverno_version = locals.kyverno_version

  depends_on = [module.debian_images]
}

module "kyverno" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/security-kyverno/modules/kyverno-chart"
  kyverno_version = locals.kyverno_version

  depends_on = [module.kyverno_image]
}
```

### Parameters

| Name            | Description                     | Type   | Default                  | Required   |
|-----------------|---------------------------------|--------|--------------------------|------------|
| debian_version  | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| kyverno_version | Kyverno version to deploy       | string | `"1.16.0"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
