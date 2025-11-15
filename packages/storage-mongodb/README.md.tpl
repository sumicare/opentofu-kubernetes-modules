## Sumicare [MongoDB Kubernetes Operator](https://github.com/mongodb/mongodb-kubernetes-operator) OpenTofu Modules

This module deploys [MongoDB Kubernetes Operator](https://github.com/mongodb/mongodb-kubernetes-operator) to the cluster.

MongoDB Kubernetes Operator is a Kubernetes operator that enables easy deployment of MongoDB Community into Kubernetes clusters.

### Usage

```terraform

locals {
  debian_version = "{{index .Versions "debian"}}"
  mongodb_version = "{{index .Versions "storage-mongodb"}}"
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
| debian_version  | Debian version for the image    | string | `"{{index .Versions "debian"}}"` | no         |
| mongodb_version | MongoDB version to deploy       | string | `"{{index .Versions "storage-mongodb"}}"` | no         |

### License

Copyright 2025 Sumicare

By using this project for academic, advertising, enterprise, or any other purpose, <br/>
you grant your **Implicit Agreement** to the Sumicare OSS [Terms of Use](../../OSS_TERMS.md).

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
