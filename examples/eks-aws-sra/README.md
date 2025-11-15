## Sumicare Kubernetes Modules [AWS SRA](https://docs.aws.amazon.com/prescriptive-guidance/latest/security-reference-architecture/welcome.html) 🚀

Deploys two EKS clusters with [AWS SRA](https://docs.aws.amazon.com/prescriptive-guidance/latest/security-reference-architecture/welcome.html) configuration, 
for the most basic blue/green deployments in case of Immutable Infrastructure, and canary via [argo-rollouts](https://argoproj.github.io/argo-rollouts/) and [linkerd api gateway](https://linkerd.io/2.19/features/gateway-api/).

Data migration between clusters are facilitated via snapshot restores, [Velero](https://velero.io/) and [pg_rewind](https://www.postgresql.org/docs/current/app-pgrewind.html) based migrations in [CNPG](https://cloudnative-pg.io/documentation/current/backup/#wal-archive).

If you want to cost-optimize, use the [GKE setup](../hybrid-cloud/), where worker nodes can reside in any cloud provider, while the control plane remains on GCP with [Kamaji](https://kamaji.clastix.io/).

This module provided as a reference for the most basic AWS SRA, and is not recommended for production use, although some folks still do just fine with it. <br/>

### Usage

```bash
cd examples/eks-aws-sra
```


### License 📜

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](LICENSE), because why not.
