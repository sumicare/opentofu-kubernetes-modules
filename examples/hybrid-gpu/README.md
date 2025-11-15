## Sumicare Kubernetes Modules GKE Hybrid GPU Cloud Setup 🚀

Deploys two GKE clusters with Moderate [EF](https://cloud.google.com/architecture/blueprints/security-foundations) configuration, 
for the most basic blue/green deployments in case of Immutable Infrastructure, and canary via [argo-rollouts](https://argoproj.github.io/argo-rollouts/) and [linkerd api gateway](https://linkerd.io/2.19/features/gateway-api/).

Data migration between clusters are facilitated via snapshot restores, [Velero](https://velero.io/) and [pg_rewind](https://www.postgresql.org/docs/current/app-pgrewind.html) based migrations in [CNPG](https://cloudnative-pg.io/documentation/current/backup/#wal-archive).

Same as [hybrid-cloud](../terragrunt-hybrid-cloud), but with GPU support via custom [virtual kubelets](https://virtual-kubelet.io/).

Added support for multi-region deployments, account sharing and more sophisticated organization management, with a backstage cluster.

### Usage

```bash
cd examples/hybrid-gpu
```

### License 📜

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](LICENSE), because why not.
