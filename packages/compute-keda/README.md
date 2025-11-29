## Sumicare [KEDA](https://github.com/kedacore/keda) OpenTofu Modules

Deploys [KEDA](https://github.com/kedacore/keda) for event-driven autoscaling beyond CPU/memory metrics.

KEDA extends Kubernetes HPA with 60+ scalers for external event sources like message queues (Kafka, RabbitMQ), databases, cloud services, and custom metrics, enabling scale-to-zero and fine-grained scaling based on actual workload demand.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  keda_version = "2.18.1"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "keda_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/compute-keda/modules/keda-image"
  debian_version = locals.debian_version
  keda_version = locals.keda_version

  depends_on = [module.debian_images]
}

module "keda" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/compute-keda/modules/keda-chart"
  keda_version = locals.keda_version

  depends_on = [module.keda_image]
}
```

### Parameters

| Name           | Description                     | Type   | Default                  | Required   |
|----------------|---------------------------------|--------|--------------------------|------------|
| debian_version | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| keda_version   | KEDA version to deploy          | string | `"2.18.1"` | no         |

### License

Copyright 2025 Sumicare

By using this project for academic, advertising, enterprise, or any other purpose, <br/>
you grant your **Implicit Agreement** to the Sumicare OSS [Terms of Use](../../OSS_TERMS.md).

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
