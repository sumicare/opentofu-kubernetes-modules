## Sumicare [Falco](https://github.com/falcosecurity/falco) OpenTofu Modules

This module deploys [Falco](https://github.com/falcosecurity/falco) to the cluster.

Falco is a cloud-native runtime security tool for Linux operating systems that detects unexpected application behavior and alerts on threats at runtime.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  falco_version = "0.42.1"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "falco_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/security-falco/modules/falco-image"
  debian_version = locals.debian_version
  falco_version = locals.falco_version

  depends_on = [module.debian_images]
}

module "falco" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/security-falco/modules/falco-chart"
  falco_version = locals.falco_version

  depends_on = [module.falco_image]
}
```

### Parameters

| Name           | Description                     | Type   | Default                  | Required   |
|----------------|---------------------------------|--------|--------------------------|------------|
| debian_version | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| falco_version  | Falco version to deploy         | string | `"0.42.1"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
