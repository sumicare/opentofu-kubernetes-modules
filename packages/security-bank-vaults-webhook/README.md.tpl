## Sumicare [Bank-Vaults Webhook](https://github.com/bank-vaults/secrets-webhook) OpenTofu Modules

Deploys [Bank-Vaults Webhook](https://github.com/bank-vaults/secrets-webhook) for transparent Vault secret injection.

Bank-Vaults Secrets Webhook mutates pods at admission to inject Vault secrets as environment variables or files, enabling applications to consume secrets without Vault SDK integration or code changes.

### Usage

```terraform

locals {
  debian_version = "{{index .Versions "debian"}}"
  bank_vaults_webhook_version = "{{index .Versions "security-bank-vaults-webhook"}}"
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
| debian_version              | Debian version for the image           | string | `"{{index .Versions "debian"}}"` | no         |
| bank_vaults_webhook_version | Bank-Vaults Webhook version to deploy  | string | `"{{index .Versions "security-bank-vaults-webhook"}}"` | no         |

### License

Copyright 2025 Sumicare

By using this project for academic, advertising, enterprise, or any other purpose, <br/>
you grant your **Implicit Agreement** to the Sumicare OSS [Terms of Use](../../OSS_TERMS.md).

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
