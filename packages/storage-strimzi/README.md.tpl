## Sumicare [Strimzi](https://github.com/strimzi/strimzi-kafka-operator) OpenTofu Modules

Deploys [Strimzi](https://github.com/strimzi/strimzi-kafka-operator) for Kubernetes-native Apache Kafka management.

Strimzi operates Kafka clusters, topics, users, and connectors through CRDs, providing automated rolling updates, rack awareness, TLS encryption, and authentication while integrating with Kubernetes storage and networking primitives.

### Usage

```terraform

locals {
  debian_version = "{{index .Versions "debian"}}"
  strimzi_version = "{{index .Versions "storage-strimzi"}}"
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
| debian_version  | Debian version for the image    | string | `"{{index .Versions "debian"}}"` | no         |
| strimzi_version | Strimzi version to deploy       | string | `"{{index .Versions "storage-strimzi"}}"` | no         |

### License

Copyright 2025 Sumicare

By using this project for academic, advertising, enterprise, or any other purpose, <br/>
you grant your **Implicit Agreement** to the Sumicare OSS [Terms of Use](../../OSS_TERMS.md).

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
