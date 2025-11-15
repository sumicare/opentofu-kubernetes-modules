## Sumicare [OpenBao](https://github.com/openbao/openbao) OpenTofu Modules

This module deploys [OpenBao](https://github.com/openbao/openbao) to the cluster.

OpenBao is an open source fork of HashiCorp Vault, providing secrets management, encryption as a service, and privileged access management.

### Usage

```terraform

locals {
  debian_version = "{{index .Versions "debian"}}"
  openbao_version = "{{index .Versions "security-openbao"}}"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "openbao_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/security-openbao/modules/openbao-image"
  debian_version = locals.debian_version
  openbao_version = locals.openbao_version

  depends_on = [module.debian_images]
}

module "openbao" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/security-openbao/modules/openbao-chart"
  openbao_version = locals.openbao_version

  depends_on = [module.openbao_image]
}
```

### Parameters

| Name            | Description                     | Type   | Default                  | Required   |
|-----------------|---------------------------------|--------|--------------------------|------------|
| debian_version  | Debian version for the image    | string | `"{{index .Versions "debian"}}"` | no         |
| openbao_version | OpenBao version to deploy       | string | `"{{index .Versions "security-openbao"}}"` | no         |

### License

Copyright 2025 Sumicare

By using this project for academic, advertising, enterprise, or any other purpose, <br/>
you grant your **Implicit Agreement** to the Sumicare OSS [Terms of Use](../../OSS_TERMS.md).

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
