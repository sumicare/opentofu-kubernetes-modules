## Sumicare [Strimzi](https://github.com/strimzi/strimzi-kafka-operator) OpenTofu Modules

This module deploys [Strimzi](https://github.com/strimzi/strimzi-kafka-operator) to the cluster.

Strimzi provides a way to run an Apache Kafka cluster on Kubernetes in various deployment configurations.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  strimzi_version = "0.49.0"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "strimzi_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/storage-strimzi/modules/strimzi-image"
  debian_version = locals.debian_version
  strimzi_version = locals.strimzi_version

  depends_on = [module.debian_images]
}

module "strimzi" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/storage-strimzi/modules/strimzi-chart"
  strimzi_version = locals.strimzi_version

  depends_on = [module.strimzi_image]
}
```

### Parameters

| Name            | Description                     | Type   | Default                  | Required   |
|-----------------|---------------------------------|--------|--------------------------|------------|
| debian_version  | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| strimzi_version | Strimzi version to deploy       | string | `"0.49.0"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
