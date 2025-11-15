## Sumicare Debian Terraform Modules

Builds base build and distroless terraform modules.

### Usage

```terraform
locals {
  debian_version = "trixie-20251117-slim"
}

module "debian_images" {
    source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
    debian_version = locals.debian_version
}
```

### Parameters

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
