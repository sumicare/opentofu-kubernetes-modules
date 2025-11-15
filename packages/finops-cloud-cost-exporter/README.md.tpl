## Sumicare [Cloud Cost Exporter](https://github.com/grafana/cloudcost-exporter) OpenTofu Modules

Deploys [Cloud Cost Exporter](https://github.com/grafana/cloudcost-exporter) for cloud spend visibility in Prometheus.

Cloud Cost Exporter scrapes billing data from AWS, GCP, and Azure APIs, exposing cost metrics that can be correlated with resource utilization in Grafana dashboards for comprehensive FinOps analysis and chargeback reporting.

### Usage

```terraform

locals {
  debian_version = "{{index .Versions "debian"}}"
  cloud_cost_exporter_version = "{{index .Versions "finops-cloud-cost-exporter"}}"
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
| debian_version              | Debian version for the image           | string | `"{{index .Versions "debian"}}"` | no         |
| cloud_cost_exporter_version | Cloud Cost Exporter version to deploy  | string | `"{{index .Versions "finops-cloud-cost-exporter"}}"` | no         |

### License

Copyright 2025 Sumicare

By using this project for academic, advertising, enterprise, or any other purpose, <br/>
you grant your **Implicit Agreement** to the Sumicare OSS [Terms of Use](../../OSS_TERMS.md).

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](../../LICENSE).
