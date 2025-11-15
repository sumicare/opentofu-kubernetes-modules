## Sumicare [Metrics Server](https://github.com/kubernetes-sigs/metrics-server) OpenTofu Modules

Deploys [Metrics Server](https://github.com/kubernetes-sigs/metrics-server) for core Kubernetes resource metrics.

Metrics Server provides real-time CPU and memory metrics required by HPA, VPA, and `kubectl top` commands, collecting data from kubelets and exposing it through the Kubernetes Metrics API for cluster-wide resource visibility.

### Usage

```terraform

locals {
  debian_version = "{{index .Versions "debian"}}"
  metrics_server_version = "{{index .Versions "observability-metrics-server"}}"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "metrics_server_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-metrics-server/modules/metrics-server-image"
  debian_version = locals.debian_version
  metrics_server_version = locals.metrics_server_version

  depends_on = [module.debian_images]
}

module "metrics_server" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/observability-metrics-server/modules/metrics-server-chart"
  metrics_server_version = locals.metrics_server_version

  depends_on = [module.metrics_server_image]
}
```

### Parameters

| Name                   | Description                        | Type   | Default                  | Required   |
|------------------------|------------------------------------|--------|--------------------------|------------|
| debian_version         | Debian version for the image       | string | `"{{index .Versions "debian"}}"` | no         |
| metrics_server_version | Metrics Server version to deploy   | string | `"{{index .Versions "observability-metrics-server"}}"` | no         |

### License

Copyright 2025 Sumicare

By using this project for academic, advertising, enterprise, or any other purpose, <br/>
you grant your **Implicit Agreement** to the Sumicare OSS [Terms of Use](../../OSS_TERMS.md).

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
