## Sumicare [Linkerd](https://linkerd.io/) OpenTofu Modules

This module deploys [Linkerd](https://linkerd.io/) to the cluster.

Linkerd is an ultralight, security-first service mesh for Kubernetes.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  linkerd_version = "25.11.3"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "linkerd_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/networking-linkerd/modules/linkerd-image"
  debian_version = locals.debian_version
  linkerd_version = locals.linkerd_version

  depends_on = [module.debian_images]
}

module "linkerd" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/networking-linkerd/modules/linkerd-chart"
  linkerd_version = locals.linkerd_version

  depends_on = [module.linkerd_image]
}
```

### Parameters

| Name            | Description                     | Type   | Default                  | Required   |
|-----------------|---------------------------------|--------|--------------------------|------------|
| debian_version  | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| linkerd_version | Linkerd version to deploy       | string | `"25.11.3"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
