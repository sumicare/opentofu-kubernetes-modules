## Sumicare [Tempo](https://github.com/grafana/tempo) OpenTofu Modules

This module deploys [Tempo](https://github.com/grafana/tempo) to the cluster.

Grafana Tempo is an open source, easy-to-use, and high-scale distributed tracing backend.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  tempo_version = "2.9.0"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "tempo_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-tempo/modules/tempo-image"
  debian_version = locals.debian_version
  tempo_version = locals.tempo_version

  depends_on = [module.debian_images]
}

module "tempo" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-tempo/modules/tempo-chart"
  tempo_version = locals.tempo_version

  depends_on = [module.tempo_image]
}
```

### Parameters

| Name           | Description                     | Type   | Default                  | Required   |
|----------------|---------------------------------|--------|--------------------------|------------|
| debian_version | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| tempo_version  | Tempo version to deploy         | string | `"2.9.0"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
