## Sumicare [Gateway API](https://github.com/kubernetes-sigs/gateway-api) OpenTofu Modules

This module deploys [Gateway API](https://github.com/kubernetes-sigs/gateway-api) to the cluster.

Gateway API is an official Kubernetes project focused on L4 and L7 routing in Kubernetes.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  gateway_api_version = "1.4.0"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "gateway_api_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/networking-gateway-api/modules/gateway-api-image"
  debian_version = locals.debian_version
  gateway_api_version = locals.gateway_api_version

  depends_on = [module.debian_images]
}

module "gateway_api" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/networking-gateway-api/modules/gateway-api-chart"
  gateway_api_version = locals.gateway_api_version

  depends_on = [module.gateway_api_image]
}
```

### Parameters

| Name                | Description                      | Type   | Default                  | Required   |
|---------------------|----------------------------------|--------|--------------------------|------------|
| debian_version      | Debian version for the image     | string | `"trixie-20251117-slim"` | no         |
| gateway_api_version | Gateway API version to deploy    | string | `"1.4.0"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
