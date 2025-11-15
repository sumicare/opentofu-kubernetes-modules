## Sumicare [Grafana Rollout Operator](https://github.com/grafana/rollout-operator) OpenTofu Modules

This module deploys [Grafana Rollout Operator](https://github.com/grafana/rollout-operator) to the cluster.

Grafana Rollout Operator coordinates the rollout of pods between different StatefulSets within a specific namespace.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  grafana_rollout_operator_version = "0.32.0"
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
| debian_version                   | Debian version for the image               | string | `"trixie-20251117-slim"` | no         |
| grafana_rollout_operator_version | Grafana Rollout Operator version to deploy | string | `"0.32.0"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
