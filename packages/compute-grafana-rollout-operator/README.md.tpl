## Sumicare [Grafana Rollout Operator](https://github.com/grafana/rollout-operator) OpenTofu Modules

Deploys [Grafana Rollout Operator](https://github.com/grafana/rollout-operator) for coordinated StatefulSet updates.

Grafana Rollout Operator orchestrates safe, ordered rollouts across multiple StatefulSets in a namespace, ensuring dependent services are updated in the correct sequence with configurable parallelism and health checks.

### Usage

```terraform

locals {
  debian_version = "{{index .Versions "debian"}}"
  grafana_rollout_operator_version = "{{index .Versions "compute-grafana-rollout-operator"}}"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "grafana_rollout_operator_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/compute-grafana-rollout-operator/modules/grafana-rollout-operator-image"
  debian_version = locals.debian_version
  grafana_rollout_operator_version = locals.grafana_rollout_operator_version

  depends_on = [module.debian_images]
}

module "grafana_rollout_operator" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/compute-grafana-rollout-operator/modules/grafana-rollout-operator-chart"
  grafana_rollout_operator_version = locals.grafana_rollout_operator_version

  depends_on = [module.grafana_rollout_operator_image]
}
```

### Parameters

| Name                             | Description                                | Type   | Default                  | Required   |
|----------------------------------|--------------------------------------------|--------|--------------------------|------------|
| debian_version                   | Debian version for the image               | string | `"{{index .Versions "debian"}}"` | no         |
| grafana_rollout_operator_version | Grafana Rollout Operator version to deploy | string | `"{{index .Versions "compute-grafana-rollout-operator"}}"` | no         |

### License

Copyright 2025 Sumicare

By using this project for academic, advertising, enterprise, or any other purpose, <br/>
you grant your **Implicit Agreement** to the Sumicare OSS [Terms of Use](../../OSS_TERMS.md).

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
