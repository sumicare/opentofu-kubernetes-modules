## Sumicare Kubernetes AWS EKS Simpl-er Setup 🚀

Deploys single EKS cluster with simplified [AWS SRA](https://docs.aws.amazon.com/prescriptive-guidance/latest/security-reference-architecture/welcome.html) configuration, 
preferred for canary deployments via [argo-rollouts](https://argoproj.github.io/argo-rollouts/) and [linkerd api gateway](https://linkerd.io/2.19/features/gateway-api/),
where infrastructure changes are infrequent.

Simple does not mean inefficient. <br/>
It does lack certain features, but it is still enough for most use cases.

If you want to cost-optimize, use the [GKE setup](../simple/), where worker nodes can reside in any cloud provider, while the control plane remains on GCP with [Kamaji](https://kamaji.clastix.io/).

This module provided as a reference, and is not recommended for production use, although some folks still do just fine with it. <br/>

### Usage

```bash
cd examples/eks-simple

```

### License 📜

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](LICENSE), because why not.
