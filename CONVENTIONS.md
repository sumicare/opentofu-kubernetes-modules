## Conventions 📏

### Monorepo

This project is a [Turborepo](https://turbo.build/) monorepo optimized for remote caching. 
CI pipelines are auto-generated and profiled: instead of blindly creating 1:N fan-out jobs for each package, we batch jobs by median duration to reduce provisioning and teardown overhead ⚙️

### Documentation

We provide commented examples and a [README](README.md) with a high-level overview. That should be enough to get started.

### Tests

Most tests are table-driven suites in [Terratest](https://terratest.gruntwork.io/) 🧪, around 98% auto-generated and then refactored with Claude Sonnet 4.5 and GPT-5.1 / GPT-5-Codex 🤖. It's fine, as long as it is thoroughly tested ✅

We use table-driven tests to minimize boilerplate, increase parallelism, and keep suites maintainable. 
Even 100% coverage does not provide viable guarantees. We validate coverage with mutation testing via [gremlins](https://gremlins.dev/latest/) for Go and [stryker](https://stryker-mutator.io/) for Node.js.

Ideally, Node.js mutation testing would integrate directly with the V8 runtime to apply mutations on the fly without reparsing the entire codebase. We may contribute to the Node.js test runtime in this direction when we'll get sufficient capacity.

 We avoid DI/AOP and instead inject timers and clock sources as function arguments and direct dependencies, so they are easy to mock in tests.

### Scripting

Terraform modules have no direct scripting dependencies, except for dedicated CLI tool for versioning, CRD downloading, and templating 🧰

You can replace Turborepo with any task runner or build tool you prefer (for example, Bazel/Starlark). We intentionally keep scripts minimal: there is only a custom [cspell](https://cspell.org/) [spellcheck](./scripts/spellcheck.sh).

### Versioning

Node.js tooling gives us best-in-class git hooks, [conventional-commits](https://www.conventionalcommits.org), [conventional changelogs](https://github.com/conventional-changelog/conventional-changelog), and [semantic-release](https://semantic-release.gitbook.io/semantic-release/) workflows, so we rely on it instead of reinventing similar tools in Go.

We run automated update jobs every 6 hours, so automatic version bumps are essential. Image versions are usually bumped as patch releases, while chart features, chores, and fixes are mostly minor releases.
Major versions are bumped manually when there is a significant change (for example, cluster autoscaling or a new backstage app).

### Linters

We use Anton's tried-and-true [pre-commit-terraform](https://github.com/antonbabenko/pre-commit-terraform) hooks 🧹:
  - [checkov](https://github.com/bridgecrewio/checkov)
  - [tflint](https://github.com/terraform-linters/tflint)
  - [terrascan](https://github.com/tenable/terrascan)
  - [tfupdate](https://github.com/minamijoyo/tfupdate)

We also run Kubernetes-specific checks 🔐:
  - [kubescape](https://github.com/kubescape/kubescape)
  - [kyverno test](https://kyverno.io/docs/kyverno-cli/usage/test/)
  - [kube-bench](https://github.com/aquasec/kube-bench)

### Docker images

[Chainguard](https://www.chainguard.dev/pricing#chainguard-containers) moved most images behind a paywall (`latest` only), so we maintain our own container set instead ♟️🎎

We generate [syft](https://github.com/anchore/syft) SBOMs and scan them with [Trivy](https://github.com/aquasecurity/trivy) and [Grype](https://github.com/anchore/grype) for vulnerabilities 🧬

Our base images are Debian for security reasons (no FIPS, but acceptable for our use). They can be customized to [Oracle Linux](https://docs.oracle.com/en/operating-systems/oracle-linux/), Red Hat [Universal Base Image](https://catalog.redhat.com/en/software/base-images), or other distributions as needed. 

We implement custom distroless extraction for our images instead of using Bazel-based Google's distroless builds 🐳

### Cloud Providers Usage

We rarely use AWS EKS hybrid clouds because [EKS Anywhere pricing](https://aws.amazon.com/eks/eks-anywhere/pricing/) effectively acts as a Kubernetes paywall 💸

Paying 50k+ USD yearly for a couple of medium clusters is not worth it; we would rather fund pizza-sized teams instead 🍕

We avoid Azure for risk-management reasons, although we respect offerings such as [MS Sentinel](https://www.microsoft.com/en-us/security/business/siem-and-xdr/microsoft-sentinel) 🛰️

### Contributions and Community Management

Expect most feature requests to be declined; we primarily process bug reports and security issues 🐛🔐

**We will not** add MySQL or "yet another vector store for embeddings". <br/>
We **own** only what we **need** and **can support** ourselves 📦

Fork the repo and extend it as you like, ideally following similar patterns (possibly with the help of your own agents) 🤖 <br/>

We do not expect strict adherence to the Apache License, but both honorable and dishonorable mentions are appreciated 🙏

We may adopt a CNCF-style governance model later, but it is not realistic right now given resources,
business needs, and legal constraints 🌱

Our focus is on keeping the existing modules production-ready and well-supported, because **we use them** in our own systems 🔧
