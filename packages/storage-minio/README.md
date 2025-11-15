## Sumicare [MinIO](https://min.io/) OpenTofu Modules

This module deploys [MinIO](https://min.io/) to the cluster.

MinIO is a high-performance, S3 compatible object storage solution.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  minio_version = "2020-10-27T04-03-55Z"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "minio_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/storage-minio/modules/minio-image"
  debian_version = locals.debian_version
  minio_version = locals.minio_version

  depends_on = [module.debian_images]
}

module "minio" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/storage-minio/modules/minio-chart"
  minio_version = locals.minio_version

  depends_on = [module.minio_image]
}
```

### Parameters

| Name           | Description                     | Type   | Default                  | Required   |
|----------------|---------------------------------|--------|--------------------------|------------|
| debian_version | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| minio_version  | MinIO version to deploy         | string | `"2020-10-27T04-03-55Z"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
