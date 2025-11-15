## Sumicare [Tekton Triggers](https://github.com/tektoncd/triggers) OpenTofu Modules

This module deploys [Tekton Triggers](https://github.com/tektoncd/triggers) to the cluster.

Tekton Triggers is a Kubernetes Custom Resource Definition (CRD) controller that allows you to create Kubernetes resources based on information extracted from event payloads.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  tekton_triggers_version = "0.34.0"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "tekton_triggers_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/development-tekton-triggers/modules/tekton-trigger-image"
  debian_version = locals.debian_version
  tekton_triggers_version = locals.tekton_triggers_version

  depends_on = [module.debian_images]
}

module "tekton_triggers" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/development-tekton-triggers/modules/tekton-trigger-chart"
  tekton_triggers_version = locals.tekton_triggers_version

  depends_on = [module.tekton_triggers_image]
}
```

### Parameters

| Name                    | Description                         | Type   | Default                  | Required   |
|-------------------------|-------------------------------------|--------|--------------------------|------------|
| debian_version          | Debian version for the image        | string | `"trixie-20251117-slim"` | no         |
| tekton_triggers_version | Tekton Triggers version to deploy   | string | `"0.34.0"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
