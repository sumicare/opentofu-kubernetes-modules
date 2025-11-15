## Sumicare Kubernetes OpenTofu Modules 🚀

This is a collection of OpenTofu modules for the Reference Cloud Native Architecture (**[RCNA](RCNA.md)**), replacing widespread Helm Charts.

V1.0 aka [Dead Signal](https://open.spotify.com/track/7zp42HAfF8NBoYaP1U9uim?si=154fe773805f4af5) is in **Active Development**.

**tldr;** 
 - Helm Charts do not provide complete off-the-shelf experience
 - Bitnami Charts are [effectively unmaintained](https://github.com/bitnami/charts/issues/35164)
 - Helm itself is kinda [TARFU](https://en.wikipedia.org/wiki/Tarfu) because of all the Server-Side Apply and 3-way merge [issues](https://enix.io/en/blog/helm-4/)
 - [Infracost](https://github.com/infracost/infracost) lost traction and [DriftCtl](https://github.com/snyk/driftctl) is mostly dead, as well
 - There's no single source of truth for infrastructure state which leads to circular-dependency glorified clusterfudge
 - You can't get proper Drift Detection or True Stateless Infrastructure using common approaches, which makes DevOps applicability, as a convention, doubtful

We're not claiming Terraform/OpenTofu is perfect - it's just the only viable option available today.
Sumicare believes the real value of Platform Engineering lies in sustainable open source and shared responsibility.
This project shares our practical solutions for cloud-native infrastructure management, and cost-efficient operation.

### Usage 📦

We **are planning** to provide brain-dead but fairly complex setups aligned with reference architectures: <br/>
[AWS SRA](https://docs.aws.amazon.com/prescriptive-guidance/latest/security-reference-architecture/welcome.html) / 
[AWS PRA](https://docs.aws.amazon.com/prescriptive-guidance/latest/privacy-reference-architecture/welcome.html), 
[GCP Enterprise Foundations](https://docs.cloud.google.com/architecture/blueprints/security-foundations)

 - [AWS EKS Simple](./examples/eks-simple/) one cluster ☁️ (**WIP**)
 - [AWS EKS SRA](./examples/eks-aws-sra/) two clusters 🛰️ (**WIP**)
 - [GKE Simple](./examples/gke-simple/) one cluster ☁️ (**WIP**)
 - [GKE Hybrid Cloud](./examples/hybrid-cloud/) multi-cluster GCP Vultr Hetzner 🌐 (**WIP**)
 - [GKE Hybrid GPU Cloud](./examples/hybrid-gpu/) multi-cluster GCP Vultr Hetzner Cheepo GPU 🎮 (**WIP**)

**Don't use it** if you **Don't have a proficient team**, and at least at **[Competent level](https://link.springer.com/article/10.1007/s10270-025-01309-x#Sec2)** (Manageable level) of Organizational Maturity.

### Development 🛠️

Open [.code-workspace](sumicare-kubernetes.code-workspace) in [VSCode](https://code.visualstudio.com/), use the provided [Dev Container](https://code.visualstudio.com/docs/devcontainers/containers) for local development.

You can install all the dependencies and tools using [asdf](https://asdf-vm.com/), manually, as well.

See [DEVELOPMENT.md](DEVELOPMENT.md) for `a more detailed explanation`...

### Core Values 📏

 - Brutal honesty always wins over hypocritical politeness 🪓
 - We are not special, we are not unique, we are not irreplaceable 🫥
 - We are building a viable product, not a dream 🛠️
 - Everything must be validated, not just speculated 🔍
 - We are changing the rules, "good" is always not enough 📏

See [CONVENTIONS.md](CONVENTIONS.md) and [VALUES.md](VALUES.md) for `why it is the way it is`...

[Yuriy](https://yarosh.dev) does provide some paid consulting services, on "first-come first-served" basis.

### License 📜

Copyright 2025 Sumicare

By using this project for academic, advertising, enterprise, or any other purpose, <br/>
you grant your **Implicit Agreement** to the Sumicare OSS [Terms of Use](OSS_TERMS.md).

Sumicare Kubernetes OpenTofu Modules are licensed under the terms of [Apache License, Version 2.0](LICENSE), because why not.
