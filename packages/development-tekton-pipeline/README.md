## Sumicare [Tekton Pipeline](https://github.com/tektoncd/pipeline) OpenTofu Modules

This module deploys [Tekton Pipeline](https://github.com/tektoncd/pipeline) to the cluster.

Tekton Pipelines is a Kubernetes-native CI/CD solution that provides cloud-native building blocks for creating CI/CD systems.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  tekton_pipeline_version = "1.6.0"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "tekton_pipeline_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/development-tekton-pipeline/modules/tekton-pipeline-image"
  debian_version = locals.debian_version
  tekton_pipeline_version = locals.tekton_pipeline_version

  depends_on = [module.debian_images]
}

module "tekton_pipeline" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/development-tekton-pipeline/modules/tekton-pipeline-chart"
  tekton_pipeline_version = locals.tekton_pipeline_version

  depends_on = [module.tekton_pipeline_image]
}
```

### Parameters

| Name                    | Description                         | Type   | Default                  | Required   |
|-------------------------|-------------------------------------|--------|--------------------------|------------|
| debian_version          | Debian version for the image        | string | `"trixie-20251117-slim"` | no         |
| tekton_pipeline_version | Tekton Pipeline version to deploy   | string | `"1.6.0"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
