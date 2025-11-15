## Sumicare [DataFusion Ballista](https://github.com/apache/datafusion-ballista) OpenTofu Modules

This module deploys [DataFusion Ballista](https://github.com/apache/datafusion-ballista) to the cluster.

Apache DataFusion Ballista is a distributed SQL query engine powered by Apache Arrow.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  data_fusion_ballista_version = "50.0.0"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "data_fusion_ballista_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/mlops-data-fusion-ballista/modules/data-fusion-ballista-image"
  debian_version = locals.debian_version
  data_fusion_ballista_version = locals.data_fusion_ballista_version

  depends_on = [module.debian_images]
}

module "data_fusion_ballista" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/mlops-data-fusion-ballista/modules/data-fusion-ballista-chart"
  data_fusion_ballista_version = locals.data_fusion_ballista_version

  depends_on = [module.data_fusion_ballista_image]
}
```

### Parameters

| Name                         | Description                             | Type   | Default                  | Required   |
|------------------------------|-----------------------------------------|--------|--------------------------|------------|
| debian_version               | Debian version for the image            | string | `"trixie-20251117-slim"` | no         |
| data_fusion_ballista_version | DataFusion Ballista version to deploy   | string | `"50.0.0"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
