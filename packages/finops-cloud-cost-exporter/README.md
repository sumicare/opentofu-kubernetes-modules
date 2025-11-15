## Sumicare [Cloud Cost Exporter](https://github.com/grafana/cloudcost-exporter) OpenTofu Modules

This module deploys [Cloud Cost Exporter](https://github.com/grafana/cloudcost-exporter) to the cluster.

Cloud Cost Exporter is a Prometheus exporter that collects cloud cost data from various cloud providers.

### Usage

```terraform

locals {
  debian_version = "trixie-20251117-slim"
  cloud_cost_exporter_version = "0.19.1"
}

module "debian_images" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/debian/modules/debian-images"
  debian_version = locals.debian_version
}

module "cloud_cost_exporter_image" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/finops-cloud-cost-exporter/modules/grafana-cloud-cost-exporter-image"
  debian_version = locals.debian_version
  cloud_cost_exporter_version = locals.cloud_cost_exporter_version

  depends_on = [module.debian_images]
}

module "cloud_cost_exporter" {
  source = "github.com/sumicare/terraform-kubernetes-modules//packages/finops-cloud-cost-exporter/modules/grafana-cloud-cost-exporter-chart"
  cloud_cost_exporter_version = locals.cloud_cost_exporter_version

  depends_on = [module.cloud_cost_exporter_image]
}
```

### Parameters

| Name                        | Description                            | Type   | Default                  | Required   |
|-----------------------------|----------------------------------------|--------|--------------------------|------------|
| debian_version              | Debian version for the image           | string | `"trixie-20251117-slim"` | no         |
| cloud_cost_exporter_version | Cloud Cost Exporter version to deploy  | string | `"0.19.1"` | no         |

### License

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
