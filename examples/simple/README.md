## Sumicare Kubernetes Modules GKE Simpl-er Setup 🚀

Deploys single GKE cluster with Simplified [EF](https://cloud.google.com/architecture/blueprints/security-foundations) configuration, 
for the most basic blue/green deployments in case of Immutable Infrastructure, and canary via [argo-rollouts](https://argoproj.github.io/argo-rollouts/) and [linkerd api gateway](https://linkerd.io/2.19/features/gateway-api/).

Simple does not mean inefficient. <br/>
It does lack certain features, but it is still enough for most use cases.

Added support for multi-region deployments, account sharing and more sophisticated organization management, with a backstage cluster.

### Usage

```bash
cd examples/gke-simple
```

### License 📜

Copyright 2025 Sumicare

Sumicare Kubernetes OpenTofu Modules Licensed under the terms of [Apache License, Version 2.0](LICENSE), because why not.
