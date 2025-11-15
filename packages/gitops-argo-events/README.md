## Sumicare [Argo Events](https://github.com/argoproj/argo-events) OpenTofu Modules

This module deploys [Argo Events](https://github.com/argoproj/argo-events) to the cluster.

Argo Events is an event-driven workflow automation framework for Kubernetes.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  argo_events_version = "1.9.8"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "argo_events_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/gitops-argo-events/modules/argo-events-image"
  debian_version = locals.debian_version
  argo_events_version = locals.argo_events_version

  depends_on = [module.debian_images]
}

module "argo_events" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/gitops-argo-events/modules/argo-events-chart"
  argo_events_version = locals.argo_events_version

  depends_on = [module.argo_events_image]
}
```

### Parameters

| Name                | Description                     | Type   | Default                  | Required   |
|---------------------|---------------------------------|--------|--------------------------|------------|
| debian_version      | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| argo_events_version | Argo Events version to deploy   | string | `"1.9.8"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
