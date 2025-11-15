## Sumicare [Linkerd Viz](https://github.com/linkerd/linkerd-viz) OpenTofu Modules

This module deploys [Linkerd Viz](https://github.com/linkerd/linkerd-viz) to the cluster.

Linkerd Viz is the observability extension for Linkerd, providing a dashboard and metrics for your service mesh.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  linkerd_viz_version = "0.2.0"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "linkerd_viz_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/networking-linkerd-viz/modules/linkerd-viz-image"
  debian_version = locals.debian_version
  linkerd_viz_version = locals.linkerd_viz_version

  depends_on = [module.debian_images]
}

module "linkerd_viz" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/networking-linkerd-viz/modules/linkerd-viz-chart"
  linkerd_viz_version = locals.linkerd_viz_version

  depends_on = [module.linkerd_viz_image]
}
```

### Parameters

| Name                | Description                      | Type   | Default                  | Required   |
|---------------------|----------------------------------|--------|--------------------------|------------|
| debian_version      | Debian version for the image     | string | `"trixie-20251117-slim"` | no         |
| linkerd_viz_version | Linkerd Viz version to deploy    | string | `"0.2.0"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
