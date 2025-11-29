## Sumicare [Linkerd Viz](https://github.com/linkerd/linkerd-viz) OpenTofu Modules

Deploys [Linkerd Viz](https://github.com/linkerd/linkerd-viz) for service mesh observability.

Linkerd Viz adds a web dashboard, Prometheus metrics, and Grafana dashboards to Linkerd, visualizing service dependencies, request flows, and golden metrics with tap/top commands for real-time traffic inspection and debugging.

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

By using this project for academic, advertising, enterprise, or any other purpose, <br/>
you grant your **Implicit Agreement** to the Sumicare OSS [Terms of Use](../../OSS_TERMS.md).

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
