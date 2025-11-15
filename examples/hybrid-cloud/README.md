## Sumicare Kubernetes Modules GKE Hybrid Cloud Setup 🚀

Deploys two GKE clusters with Moderate [EF](https://cloud.google.com/architecture/blueprints/security-foundations) configuration, 
for the most basic blue/green deployments in case of Immutable Infrastructure, and canary via [argo-rollouts](https://argoproj.github.io/argo-rollouts/) and [linkerd api gateway](https://linkerd.io/2.19/features/gateway-api/).

Data migration between clusters are facilitated via snapshot restores, [Velero](https://velero.io/) and [pg_rewind](https://www.postgresql.org/docs/current/app-pgrewind.html) based migrations in [CNPG](https://cloudnative-pg.io/documentation/current/backup/#wal-archive).

Added support for multi-region deployments, account sharing and more sophisticated organization management, with a backstage cluster.

### Usage

```bash
cd examples/hybrid-cloud
```

### Deploys

Backstage cluster with:

 - GCP Organization management stack, similar to [Project Factory](https://github.com/terraform-google-modules/terraform-google-project-factory)
 - [GCP SSO](https://cloud.google.com/architecture/identity/single-sign-on)
 - [Vultr Organization](https://docs.vultr.com/platform/other) management
 - [GKE](https://cloud.google.com/kubernetes-engine) backstage cluster with cluster-wide [ArgoCD](https://argo-cd.readthedocs.io/en/stable/), and an autoscaled backstage app
 - GCP [Atlantis](https://www.runatlantis.io/) for OpenTofu PR automation
 - GKE Observability with Cloud Logging and Cloud Monitoring
 - Terragrunt managed state buckets (a ton of state buckets)
 - Optional, TektonCD pipeline to automate image creation and pushing to self-hosted on-prem [Zot](https://zotregistry.dev/) registry

We're fine with 


### License 📜

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](LICENSE), because why not.
