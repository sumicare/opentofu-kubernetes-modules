## Sumicare [External DNS](https://github.com/kubernetes-sigs/external-dns) OpenTofu Modules

This module deploys [External DNS](https://github.com/kubernetes-sigs/external-dns) to the cluster.

ExternalDNS synchronizes exposed Kubernetes Services and Ingresses with DNS providers.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  external_dns_version = "0.20.0"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "external_dns_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/networking-external-dns/modules/external-dns-image"
  debian_version = locals.debian_version
  external_dns_version = locals.external_dns_version

  depends_on = [module.debian_images]
}

module "external_dns" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/networking-external-dns/modules/external-dns-chart"
  external_dns_version = locals.external_dns_version

  depends_on = [module.external_dns_image]
}
```

### Parameters

| Name                 | Description                       | Type   | Default                  | Required   |
|----------------------|-----------------------------------|--------|--------------------------|------------|
| debian_version       | Debian version for the image      | string | `"trixie-20251117-slim"` | no         |
| external_dns_version | External DNS version to deploy    | string | `"0.20.0"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
