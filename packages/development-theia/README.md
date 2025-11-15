## Sumicare [Eclipse Theia](https://github.com/eclipse-theia/theia) OpenTofu Modules

This module deploys [Eclipse Theia](https://github.com/eclipse-theia/theia) to the cluster.

Eclipse Theia is an extensible platform to develop multi-language Cloud & Desktop IDEs with state-of-the-art web technologies.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  theia_version = "1.66.2"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "theia_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/development-theia/modules/theia-image"
  debian_version = locals.debian_version
  theia_version = locals.theia_version

  depends_on = [module.debian_images]
}

module "theia" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/development-theia/modules/theia-chart"
  theia_version = locals.theia_version

  depends_on = [module.theia_image]
}
```

### Parameters

| Name           | Description                     | Type   | Default                  | Required   |
|----------------|---------------------------------|--------|--------------------------|------------|
| debian_version | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| theia_version  | Theia version to deploy         | string | `"1.66.2"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
