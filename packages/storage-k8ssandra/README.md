## Sumicare [K8ssandra](https://github.com/k8ssandra/k8ssandra-operator) OpenTofu Modules

This module deploys [K8ssandra](https://github.com/k8ssandra/k8ssandra-operator) to the cluster.

K8ssandra is a Kubernetes operator for Apache Cassandra that provides a production-ready platform for running Cassandra on Kubernetes.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  k8ssandra_version = "1.29.0"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "k8ssandra_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/storage-k8ssandra/modules/k8ssandra-image"
  debian_version = locals.debian_version
  k8ssandra_version = locals.k8ssandra_version

  depends_on = [module.debian_images]
}

module "k8ssandra" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/storage-k8ssandra/modules/k8ssandra-chart"
  k8ssandra_version = locals.k8ssandra_version

  depends_on = [module.k8ssandra_image]
}
```

### Parameters

| Name              | Description                     | Type   | Default                  | Required   |
|-------------------|---------------------------------|--------|--------------------------|------------|
| debian_version    | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| k8ssandra_version | K8ssandra version to deploy     | string | `"1.29.0"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
