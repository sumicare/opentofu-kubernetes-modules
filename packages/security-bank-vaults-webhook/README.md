## Sumicare [Bank-Vaults Webhook](https://github.com/bank-vaults/secrets-webhook) OpenTofu Modules

This module deploys [Bank-Vaults Webhook](https://github.com/bank-vaults/secrets-webhook) to the cluster.

Bank-Vaults Secrets Webhook is a mutating webhook that injects secrets from Vault into Kubernetes pods.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  bank_vaults_webhook_version = "0.3.0"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "bank_vaults_webhook_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/security-bank-vaults-webhook/modules/bank-vaults-webhook-image"
  debian_version = locals.debian_version
  bank_vaults_webhook_version = locals.bank_vaults_webhook_version

  depends_on = [module.debian_images]
}

module "bank_vaults_webhook" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/security-bank-vaults-webhook/modules/bank-vaults-webhook-chart"
  bank_vaults_webhook_version = locals.bank_vaults_webhook_version

  depends_on = [module.bank_vaults_webhook_image]
}
```

### Parameters

| Name                        | Description                            | Type   | Default                  | Required   |
|-----------------------------|----------------------------------------|--------|--------------------------|------------|
| debian_version              | Debian version for the image           | string | `"trixie-20251117-slim"` | no         |
| bank_vaults_webhook_version | Bank-Vaults Webhook version to deploy  | string | `"0.3.0"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
