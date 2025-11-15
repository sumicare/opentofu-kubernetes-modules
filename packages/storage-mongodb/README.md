## Sumicare [MongoDB Kubernetes Operator](https://github.com/mongodb/mongodb-kubernetes-operator) OpenTofu Modules

This module deploys [MongoDB Kubernetes Operator](https://github.com/mongodb/mongodb-kubernetes-operator) to the cluster.

MongoDB Kubernetes Operator is a Kubernetes operator that enables easy deployment of MongoDB Community into Kubernetes clusters.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  mongodb_version = "0.13.0"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "mongodb_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/storage-mongodb/modules/mongodb-image"
  debian_version = locals.debian_version
  mongodb_version = locals.mongodb_version

  depends_on = [module.debian_images]
}

module "mongodb" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/storage-mongodb/modules/mongodb-chart"
  mongodb_version = locals.mongodb_version

  depends_on = [module.mongodb_image]
}
```

### Parameters

| Name            | Description                     | Type   | Default                  | Required   |
|-----------------|---------------------------------|--------|--------------------------|------------|
| debian_version  | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| mongodb_version | MongoDB version to deploy       | string | `"0.13.0"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
