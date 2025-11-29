## Sumicare [OpenCost](https://github.com/opencost/opencost) OpenTofu Modules

Deploys [OpenCost](https://github.com/opencost/opencost) for real-time Kubernetes cost allocation.

OpenCost provides granular cost visibility by namespace, deployment, pod, and label, combining cloud billing data with actual resource consumption to enable accurate showback/chargeback, budget alerts, and cost optimization recommendations.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  opencost_version = "1.118.0"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "opencost_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/finops-opencost/modules/opencost-image"
  debian_version = locals.debian_version
  opencost_version = locals.opencost_version

  depends_on = [module.debian_images]
}

module "opencost" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/finops-opencost/modules/opencost-chart"
  opencost_version = locals.opencost_version

  depends_on = [module.opencost_image]
}
```

### Parameters

| Name             | Description                     | Type   | Default                  | Required   |
|------------------|---------------------------------|--------|--------------------------|------------|
| debian_version   | Debian version for the image    | string | `"trixie-20251117-slim"` | no         |
| opencost_version | OpenCost version to deploy      | string | `"1.118.0"` | no         |

### License

Copyright 2025 Sumicare

By using this project for academic, advertising, enterprise, or any other purpose, <br/>
you grant your **Implicit Agreement** to the Sumicare OSS [Terms of Use](../../OSS_TERMS.md).

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
