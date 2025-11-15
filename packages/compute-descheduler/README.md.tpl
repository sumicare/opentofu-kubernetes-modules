## Sumicare [Descheduler](https://github.com/kubernetes-sigs/descheduler) OpenTofu Modules

Deploys [Descheduler](https://github.com/kubernetes-sigs/descheduler) to optimize pod placement across cluster nodes.

Descheduler evicts pods based on configurable policies to rebalance workloads, addressing issues like node underutilization, pod affinity violations, and taint/toleration mismatches that accumulate over time as cluster state changes.

### Usage

```terraform

locals {
  debian_version = "{{index .Versions "debian"}}"
  descheduler_version = "{{index .Versions "compute-descheduler"}}"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "descheduler_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/compute-descheduler/modules/descheduler-image"
  debian_version = locals.debian_version
  descheduler_version = locals.descheduler_version

  depends_on = [module.debian_images]
}

module "descheduler" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/compute-descheduler/modules/descheduler-chart"
  descheduler_version = locals.descheduler_version

  depends_on = [module.descheduler_image]
}
```

### Parameters

| Name                | Description                     | Type   | Default                  | Required   |
|---------------------|---------------------------------|--------|--------------------------|------------|
| debian_version      | Debian version for the image    | string | `"{{index .Versions "debian"}}"` | no         |
| descheduler_version | Descheduler version to deploy   | string | `"{{index .Versions "compute-descheduler"}}"`               | no         |

### License

Copyright 2025 Sumicare

By using this project for academic, advertising, enterprise, or any other purpose, <br/>
you grant your **Implicit Agreement** to the Sumicare OSS [Terms of Use](../../OSS_TERMS.md).

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
