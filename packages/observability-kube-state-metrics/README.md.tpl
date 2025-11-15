## Sumicare [Kube State Metrics](https://github.com/kubernetes/kube-state-metrics) OpenTofu Modules

Deploys [Kube State Metrics](https://github.com/kubernetes/kube-state-metrics) for Kubernetes object state monitoring.

Kube State Metrics exposes Prometheus metrics for Kubernetes objects (deployments, pods, nodes, PVCs), enabling alerting on desired vs actual state, resource quotas, and workload health without instrumenting applications.

### Usage

```terraform

locals {
  debian_version = "{{index .Versions "debian"}}"
  kube_state_metrics_version = "{{index .Versions "observability-kube-state-metrics"}}"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "kube_state_metrics_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-kube-state-metrics/modules/kube-state-metrics-image"
  debian_version = locals.debian_version
  kube_state_metrics_version = locals.kube_state_metrics_version

  depends_on = [module.debian_images]
}

module "kube_state_metrics" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-kube-state-metrics/modules/kube-state-metrics-chart"
  kube_state_metrics_version = locals.kube_state_metrics_version

  depends_on = [module.kube_state_metrics_image]
}
```

### Parameters

| Name                       | Description                           | Type   | Default                  | Required   |
|----------------------------|---------------------------------------|--------|--------------------------|------------|
| debian_version             | Debian version for the image          | string | `"{{index .Versions "debian"}}"` | no         |
| kube_state_metrics_version | Kube State Metrics version to deploy  | string | `"{{index .Versions "observability-kube-state-metrics"}}"` | no         |

### License

Copyright 2025 Sumicare

By using this project for academic, advertising, enterprise, or any other purpose, <br/>
you grant your **Implicit Agreement** to the Sumicare OSS [Terms of Use](../../OSS_TERMS.md).

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
