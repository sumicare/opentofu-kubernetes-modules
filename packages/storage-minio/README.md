## Sumicare [MinIO](https://min.io/) OpenTofu Modules

Deploys [MinIO](https://min.io/) for S3-compatible object storage on Kubernetes.

MinIO provides high-performance, distributed object storage with full S3 API compatibility, enabling cloud-native applications to use familiar S3 SDKs while keeping data on-premises or in any cloud with erasure coding and encryption.

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

By using this project for academic, advertising, enterprise, or any other purpose, <br/>
you grant your **Implicit Agreement** to the Sumicare OSS [Terms of Use](../../OSS_TERMS.md).

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
