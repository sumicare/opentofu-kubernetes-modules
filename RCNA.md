## Reference Cloud Native Architecture

The Reference Cloud Native Architecture (RCNA) is a curated set of mature CNCF projects designed to provide a reliable, 
cost-effective, and secure foundation for running modern cloud-native applications.

It emphasizes:
- Well-defined best practices
- Complete observability
- Elimination of circular dependencies in continuous deployments and continuous provisioning
- Stateless infrastructure
- Cost-aware provisioning and predictive autoscaling
- Predictable Cost of Ownership
- Vendor neutrality

## RCNA consists of 

- **Base Images** — secure container foundations

  [Debian](https://www.debian.org/) provides minimal, secure base images for all Sumicare modules.
  - **Strengths**: Stable, well-audited, small attack surface, distroless variants available.
  - **Weaknesses**: Slower security updates than rolling releases; package version lag.
  - **Opportunities**: Consistent base layer across stack; automated CVE scanning.
  - **Threats**: Base image vulnerabilities affect entire fleet; supply chain attacks.
  - **Mitigations**: 
    [Tekton Chains](https://github.com/tektoncd/chains) signs all images with SLSA provenance; <br/> 
    [Kyverno](https://github.com/kyverno/kyverno) policies enforce image signatures and block unsigned deployments; <br/> 
    [Falco](https://github.com/falcosecurity/falco) detects runtime anomalies from compromised images.

- **Compute Plane** — scheduling and scalability

  [Descheduler](https://github.com/kubernetes-sigs/descheduler) evicts pods to rebalance workloads across nodes.
  - **S**: Native k8s-sigs project, policy-driven, no external dependencies.
  - **W**: Reactive only—cannot prevent bad scheduling, just correct it.
  - **O**: Integrates with Kamaji for cross-cluster optimization.
  - **T**: Aggressive policies cause unnecessary pod churn during traffic spikes.
  - **M**: 
    [Prometheus](https://github.com/prometheus/prometheus) alerts on high eviction rates; <br/> 
    [Linkerd](https://linkerd.io/) golden metrics detect latency impact from churn; <br/> 
    [Grafana](https://github.com/grafana/grafana) dashboards correlate evictions with service degradation for policy tuning.

  [Kamaji](https://github.com/clastix/kamaji) hosts Kubernetes control planes as pods for multi-tenant clusters.
  - **S**: 10x cost reduction vs dedicated clusters, strong tenant isolation via separate API servers.
  - **W**: Immature compared to managed Kubernetes, limited cloud provider integrations.
  - **O**: Enables hybrid cloud with consistent control plane management.
  - **T**: etcd shared storage becomes single point of failure without proper HA setup.
  - **M**: 
    [Velero](https://github.com/vmware-tanzu/velero) backs up etcd and tenant control planes; <br/> 
    [CloudNativePG](https://github.com/cloudnative-pg/cloudnative-pg) provides HA PostgreSQL as etcd alternative; <br/> 
    [Prometheus](https://github.com/prometheus/prometheus) monitors etcd health with alerts on leader elections and latency.

  [Virtual Kubelet](https://github.com/virtual-kubelet/virtual-kubelet) presents external compute as virtual nodes.
  - **S**: Transparent bursting to serverless/GPU providers without application changes.
  - **W**: Provider implementations vary in quality; no persistent storage support.
  - **O**: Cost arbitrage across GPU providers ([vast.ai](https://vast.ai/), [runpod](https://runpod.io/)).
  - **T**: Provider API changes break workloads; latency for cold starts.
  - **M**: 
    [Kyverno](https://github.com/kyverno/kyverno) policies restrict which workloads can burst to external providers; <br/> 
    [Prometheus](https://github.com/prometheus/prometheus) tracks cold start latency; <br/> 
    [OpenCost](https://github.com/opencost/opencost) monitors burst costs; <br/> 
    [Argo Rollouts](https://github.com/argoproj/argo-rollouts) enables gradual traffic shift to validate provider stability.

  [Grafana Rollout Operator](https://github.com/grafana/rollout-operator/) orchestrates StatefulSet rollouts.
  - **S**: Topology-aware updates, configurable parallelism, health-gated progression.
  - **W**: Grafana-specific design patterns; limited adoption outside LGTM stack.
  - **O**: Essential for Mimir/Loki/Tempo zone-aware deployments.
  - **T**: Misconfigured parallelism causes cascading failures in distributed systems.
  - **M**: 
    [Prometheus](https://github.com/prometheus/prometheus) alerts on rollout failures; <br/> 
    [Linkerd](https://linkerd.io/) tracks request success rates during rollouts; <br/> 
    [Grafana](https://github.com/grafana/grafana) dashboards visualize zone-by-zone progression; <br/> 
    [Argo CD](https://github.com/argoproj/argo-cd) provides rollback if health checks fail.

  [KEDA](https://keda.sh/) extends HPA with 60+ event-driven scalers.
  - **S**: Scale-to-zero, external metrics (Kafka lag, queue depth), cloud-agnostic.
  - **W**: Additional control plane component; scaler quality varies.
  - **O**: Replaces custom autoscaling logic; enables true serverless patterns.
  - **T**: Scaler bugs cause runaway scaling; metrics lag causes oscillation.
  - **M**: 
    [Kyverno](https://github.com/kyverno/kyverno) policies enforce max replica limits; <br/> 
    [Prometheus](https://github.com/prometheus/prometheus) alerts on rapid scaling events; <br/> 
    [OpenCost](https://github.com/opencost/opencost) tracks scaling cost impact; <br/> 
    [VPA](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler) in recommendation mode validates KEDA's resource assumptions.

  [VPA](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler) auto-tunes resource requests.
  - **S**: Eliminates manual resource tuning, reduces over-provisioning 30-50%.
  - **W**: Requires pod restarts to apply; conflicts with HPA.
  - **O**: Combined with Goldilocks for org-wide resource optimization.
  - **T**: Recommendations exceeding node capacity cause scheduling failures.
  - **M**: 
    [Kamaji](https://github.com/clastix/kamaji) scales node pools when VPA recommendations exceed capacity; <br/> 
    [Kyverno](https://github.com/kyverno/kyverno) policies cap maximum resource requests; <br/> 
    [Prometheus](https://github.com/prometheus/prometheus) alerts when recommendations approach node limits; <br/> 
    [Goldilocks](https://github.com/FairwindsOps/goldilocks) dashboards flag outliers.

  [Goldilocks](https://github.com/FairwindsOps/goldilocks) visualizes VPA recommendations.
  - **S**: Dashboard for right-sizing decisions, namespace-level automation.
  - **W**: Read-only insights; requires manual or VPA action to apply.
  - **O**: FinOps integration for cost attribution and optimization tracking.
  - **T**: Stale recommendations if VPA updater is disabled or lagging.
  - **M**: 
    [Prometheus](https://github.com/prometheus/prometheus) alerts on VPA updater pod health; <br/> 
    [Kube State Metrics](https://github.com/kubernetes/kube-state-metrics) tracks VPA CR status; <br/> 
    [Argo CD](https://github.com/argoproj/argo-cd) ensures VPA components stay deployed; <br/> 
    [Grafana](https://github.com/grafana/grafana) dashboards show recommendation freshness.

- **Development Plane** — CI/CD, artifact management, and identity

  [Tekton Pipeline](https://github.com/tektoncd/pipeline) provides Kubernetes-native CI/CD building blocks.
  - **S**: CNCF graduated, reusable Tasks/Pipelines, runs as pods with full k8s integration.
  - **W**: Steeper learning curve than GitHub Actions; verbose YAML.
  - **O**: Portable across clouds; integrates with Chains for SLSA compliance.
  - **T**: Pipeline sprawl without catalog governance; etcd pressure from TaskRun CRs.
  - **M**: 
    [Tekton Results](https://github.com/tektoncd/results) offloads history to PostgreSQL reducing etcd pressure; <br/> 
    [Kyverno](https://github.com/kyverno/kyverno) policies enforce pipeline naming conventions; <br/> 
    [Argo CD](https://github.com/argoproj/argo-cd) manages pipeline catalog as GitOps; <br/> 
    [Prometheus](https://github.com/prometheus/prometheus) alerts on TaskRun accumulation.

  [Tekton Triggers](https://github.com/tektoncd/triggers) enables webhook-driven pipeline execution.
  - **S**: Native GitHub/GitLab/Bitbucket support, CEL-based filtering, template interpolation.
  - **W**: Limited retry logic; webhook secrets management complexity.
  - **O**: Enables true GitOps CI without external CI services.
  - **T**: Webhook floods can overwhelm the cluster; no built-in rate limiting.
  - **M**: 
    [Gateway API](https://github.com/kubernetes-sigs/gateway-api) rate limiting at ingress; <br/> 
    [Kyverno](https://github.com/kyverno/kyverno) policies limit concurrent PipelineRuns per namespace; <br/> 
    [Bank-Vaults](https://github.com/bank-vaults/vault-operator) manages webhook secrets with rotation; <br/> 
    [Prometheus](https://github.com/prometheus/prometheus) alerts on webhook queue depth.

  [Tekton Chains](https://github.com/tektoncd/chains) signs artifacts and generates SLSA provenance.
  - **S**: Automatic attestation, Sigstore/cosign integration, supply chain security.
  - **W**: Requires key management infrastructure; adds signing latency.
  - **O**: SLSA Level 3 compliance for enterprise/government requirements.
  - **T**: Key compromise invalidates all attestations; rotation is complex.
  - **M**: 
    [Bank-Vaults Operator](https://github.com/bank-vaults/vault-operator) manages signing keys with automated rotation; <br/> 
    [Falco](https://github.com/falcosecurity/falco) detects unauthorized key access; <br/> 
    [Kyverno](https://github.com/kyverno/kyverno) enforces attestation verification before deployment; <br/> 
    [Velero](https://github.com/vmware-tanzu/velero) backs up key material.

  [Tekton Results](https://github.com/tektoncd/results) stores pipeline history in external backends.
  - **S**: Reduces etcd load, enables long-term retention, gRPC/REST API for analytics.
  - **W**: Additional PostgreSQL/GCS dependency; migration complexity.
  - **O**: Build analytics, compliance auditing, cost attribution per pipeline.
  - **T**: Backend failures cause data loss; no built-in replication.
  - **M**: 
    [CloudNativePG](https://github.com/cloudnative-pg/cloudnative-pg) provides HA PostgreSQL with streaming replication; <br/> 
    [Velero](https://github.com/vmware-tanzu/velero) backs up Results database; <br/> 
    [MinIO](https://min.io/) offers S3 backend alternative; <br/> 
    [Prometheus](https://github.com/prometheus/prometheus) monitors backend health with alerts.

  [Tekton Dashboard](https://github.com/tektoncd/dashboard) provides pipeline visualization.
  - **S**: Real-time logs, RBAC-aware, multi-tenant namespace isolation.
  - **W**: Limited compared to commercial CI UIs; no built-in notifications.
  - **O**: Custom dashboards via embedding; Grafana integration for metrics.
  - **T**: Exposed dashboard without auth becomes security risk.
  - **M**:
    [Dex](https://github.com/dexidp/dex) provides SSO authentication; <br/>
    [Linkerd](https://linkerd.io/) mTLS encrypts dashboard traffic; <br/>
    [Kyverno](https://github.com/kyverno/kyverno) policies enforce network policies; <br/>
    [Falco](https://github.com/falcosecurity/falco) detects unauthorized access attempts; <br/>
    [Gateway API](https://github.com/kubernetes-sigs/gateway-api) manages ingress with TLS.

  [Atlas Operator](https://github.com/ariga/atlas-operator) manages declarative database migrations.
  - **S**: GitOps-native schema management, drift detection, rollback support.
  - **W**: Limited to schema migrations; no data migration support.
  - **O**: Integrates with Argo Workflows for complex migration pipelines.
  - **T**: Schema changes on large tables cause extended locks; will likely be replaced.
  - **M**:
    [Argo Workflows](https://github.com/argoproj/argo-workflows) orchestrates pre-migration backups via [Velero](https://github.com/vmware-tanzu/velero); <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on long-running migrations; <br/>
    [CloudNativePG](https://github.com/cloudnative-pg/cloudnative-pg) read replicas allow testing migrations; <br/>
    [Grafana](https://github.com/grafana/grafana) tracks migration duration trends.

  [Dex](https://github.com/dexidp/dex) federates identity providers into unified OIDC.
  - **S**: Supports LDAP, SAML, GitHub, Google, OIDC; single SSO interface.
  - **W**: Stateless design requires external storage; limited session management.
  - **O**: Central identity for all cluster services (Argo, Grafana, Tekton).
  - **T**: IdP outages cascade to all dependent services; token refresh failures.
  - **M**:
    Multiple [Dex](https://github.com/dexidp/dex) replicas behind [Gateway API](https://github.com/kubernetes-sigs/gateway-api) for HA; <br/>
    [Valkey](https://github.com/valkey-io/valkey) caches tokens reducing IdP load; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on IdP connectivity; <br/>
    [Linkerd](https://linkerd.io/) provides automatic retries for token refresh.

  [Zot](https://github.com/project-zot/zot) provides lightweight OCI artifact registry.
  - **S**: Single binary, S3 backend, deduplication, air-gap friendly.
  - **W**: Fewer features than Harbor; no built-in vulnerability scanning.
  - **O**: Edge deployments, CI cache, internal artifact distribution.
  - **T**: Storage backend failures cause registry unavailability.
  - **M**:
    [MinIO](https://min.io/) provides resilient S3 backend with erasure coding; <br/>
    [Velero](https://github.com/vmware-tanzu/velero) backs up registry metadata; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) monitors storage health; <br/>
    [Tekton Chains](https://github.com/tektoncd/chains) signs artifacts before push for integrity verification.

  [Eclipse Theia](https://github.com/eclipse-theia/theia) runs VS Code in browser.
  - **S**: Full LSP support, extension compatibility, source stays in cluster.
  - **W**: Resource-intensive; browser limitations vs native IDE.
  - **O**: Secure development for sensitive codebases; standardized environments.
  - **T**: Browser crashes lose unsaved work; latency impacts developer experience.
  - **M**:
    [PVC Autoresizer](https://github.com/topolvm/pvc-autoresizer) ensures workspace storage doesn't fill; <br/>
    [Linkerd](https://linkerd.io/) reduces network latency; <br/>
    [Velero](https://github.com/vmware-tanzu/velero) backs up workspace PVCs; <br/>
    [Dex](https://github.com/dexidp/dex) provides SSO; <br/>
    [Calico](https://github.com/projectcalico/calico) network policies isolate developer workspaces.

- **GitOps Plane** — declarative delivery and workflow automation

  [Argo CD](https://github.com/argoproj/argo-cd) reconciles cluster state with Git repositories.
  - **S**: CNCF graduated, multi-cluster, SSO/RBAC, drift detection, rollback.
  - **W**: Application CRD proliferation; sync waves complexity for dependencies.
  - **O**: Single pane of glass for fleet management; ApplicationSets for templating.
  - **T**: Git repository compromise = cluster compromise; reconciliation loops with operators.
  - **M**:
    [Tekton Chains](https://github.com/tektoncd/chains) signs commits with GPG; <br/>
    [Kyverno](https://github.com/kyverno/kyverno) policies verify commit signatures before sync; <br/>
    [Falco](https://github.com/falcosecurity/falco) detects unauthorized Git credential access; <br/>
    `ignoreDifferences` prevents operator conflicts.

  [Argo Rollouts](https://github.com/argoproj/argo-rollouts) enables progressive delivery.
  - **S**: Blue-green, canary, traffic shifting, metrics-based rollback.
  - **W**: Requires service mesh or ingress controller integration.
  - **O**: A/B testing, feature flags integration, experiment-driven deployments.
  - **T**: Misconfigured analysis templates cause stuck rollouts; traffic split bugs.
  - **M**:
    [Linkerd](https://linkerd.io/) provides traffic splitting and golden metrics for analysis; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) supplies rollout metrics; <br/>
    [Grafana](https://github.com/grafana/grafana) dashboards visualize canary progression; <br/>
    [Gateway API](https://github.com/kubernetes-sigs/gateway-api) handles traffic routing.

  [Argo Workflows](https://github.com/argoproj/argo-workflows) orchestrates complex job DAGs.
  - **S**: Parallel execution, artifact passing, retries, timeouts, resource limits.
  - **W**: Workflow CRs consume etcd; no built-in scheduling (use cron or Events).
  - **O**: ML pipelines, data processing, CI/CD, batch jobs with dependencies.
  - **T**: Runaway workflows exhaust cluster resources; artifact storage costs.
  - **M**:
    [Kyverno](https://github.com/kyverno/kyverno) policies enforce resource limits and max parallelism; <br/>
    [KEDA](https://keda.sh/) scales workflow controllers; <br/>
    [MinIO](https://min.io/) provides cost-effective artifact storage; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on workflow queue depth.

  [Argo Events](https://github.com/argoproj/argo-events) connects event sources to triggers.
  - **S**: 20+ sources (webhooks, S3, Kafka, NATS, cron), CEL filtering.
  - **W**: EventSource CRs require careful resource management.
  - **O**: Event-driven architecture, reactive automation, cross-system integration.
  - **T**: Event storms trigger workflow floods; no built-in backpressure.
  - **M**:
    [Strimzi](https://github.com/strimzi/strimzi-kafka-operator) Kafka provides durable event buffering with backpressure; <br/>
    [Kyverno](https://github.com/kyverno/kyverno) limits workflows per event; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on event queue growth; <br/>
    [KEDA](https://keda.sh/) scales event processors based on queue depth.

- **MLOps Plane** — distributed computing and model serving

  [Volcano](https://github.com/volcano-sh/volcano) provides gang scheduling for ML workloads.
  - **S**: Fair-share queuing, preemption, MPI/Spark/PyTorch native support.
  - **W**: Additional scheduler complexity; learning curve for queue configuration.
  - **O**: Multi-tenant GPU clusters with resource guarantees.
  - **T**: Misconfigured queues cause job starvation; preemption disrupts long-running training.
  - **M**:
    [Prometheus](https://github.com/prometheus/prometheus) alerts on queue wait times and starvation; <br/>
    [Grafana](https://github.com/grafana/grafana) dashboards visualize queue fairness; <br/>
    [OpenCost](https://github.com/opencost/opencost) tracks GPU costs per queue; <br/>
    [Kyverno](https://github.com/kyverno/kyverno) policies enforce queue quotas.

  [KubeRay](https://github.com/ray-project/kuberay) manages Ray clusters on Kubernetes.
  - **S**: Autoscaling, fault tolerance, GPU scheduling, Ray Serve for inference.
  - **W**: Ray's memory model differs from k8s expectations; debugging distributed failures.
  - **O**: Unified platform for training, tuning, and serving.
  - **T**: Head node failure loses cluster state; GPU fragmentation wastes resources.
  - **M**:
    [Velero](https://github.com/vmware-tanzu/velero) backs up Ray head node state; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) monitors head node health; <br/>
    [Descheduler](https://github.com/kubernetes-sigs/descheduler) optimizes GPU node utilization; <br/>
    [KEDA](https://keda.sh/) scales Ray workers based on queue depth.

  [DataFusion Ballista](https://github.com/apache/datafusion-ballista) provides distributed SQL.
  - **S**: Apache Arrow columnar format, Rust performance, Spark-compatible SQL.
  - **W**: Smaller ecosystem than Spark; fewer connectors and UDFs.
  - **O**: Cost-effective alternative to Spark for analytical queries.
  - **T**: Memory pressure on executors causes query failures; no built-in shuffle service.
  - **M**:
    [VPA](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler) right-sizes executor memory; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on memory pressure; <br/>
    [MinIO](https://min.io/) provides shuffle storage; <br/>
    [Grafana](https://github.com/grafana/grafana) tracks query performance and failures.

  [OME](https://github.com/sgl-project/ome) serves LLMs with optimized inference.
  - **S**: Continuous batching, PagedAttention, tensor parallelism, OpenAI-compatible API.
  - **W**: Model-specific optimizations; requires tuning per architecture.
  - **O**: Production LLM serving at scale; cost reduction vs cloud APIs.
  - **T**: GPU memory exhaustion causes OOM; model updates require careful rollout.
  - **M**:
    [Prometheus](https://github.com/prometheus/prometheus) alerts on GPU memory utilization; <br/>
    [Argo Rollouts](https://github.com/argoproj/argo-rollouts) enables canary model deployments; <br/>
    [KEDA](https://keda.sh/) scales replicas based on request queue; <br/>
    [Linkerd](https://linkerd.io/) provides request-level load balancing.

- **Networking Plane** — CNI, service mesh, and traffic management

  [Calico](https://github.com/projectcalico/calico) provides CNI with network policy enforcement.
  - **S**: BGP routing, eBPF dataplane, microsegmentation, WireGuard encryption.
  - **W**: Complex configuration for advanced features; eBPF requires kernel 5.3+.
  - **O**: Hybrid cloud networking with consistent policy across clusters.
  - **T**: Policy misconfiguration causes network partitions; eBPF bugs are kernel-level.
  - **M**:
    [Kyverno](https://github.com/kyverno/kyverno) validates network policies before apply; <br/>
    [Linkerd Viz](https://github.com/linkerd/linkerd-viz) visualizes traffic flows to detect partitions; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on pod connectivity failures; <br/>
    [Falco](https://github.com/falcosecurity/falco) detects policy bypass attempts.

  [Gateway API](https://github.com/kubernetes-sigs/gateway-api) supersedes Ingress with expressive routing.
  - **S**: Role-oriented design, HTTPRoute/GRPCRoute/TCPRoute, traffic splitting.
  - **W**: Implementation quality varies by controller; still maturing.
  - **O**: Portable routing config across cloud providers and controllers.
  - **T**: Controller bugs cause routing failures; CRD version mismatches.
  - **M**:
    [Linkerd](https://linkerd.io/) provides fallback routing and retries; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on 5xx rates; <br/>
    [Argo CD](https://github.com/argoproj/argo-cd) manages CRD versions consistently; <br/>
    [Grafana](https://github.com/grafana/grafana) dashboards track route health.

  [Linkerd](https://linkerd.io/) provides lightweight service mesh with automatic mTLS.
  - **S**: Minimal overhead (<10ms p99), zero-config mTLS, golden metrics.
  - **W**: Rust proxy less extensible than Envoy; limited protocol support.
  - **O**: Zero-trust networking without application changes.
  - **T**: mTLS breaks plaintext inspection tools; proxy injection failures.
  - **M**:
    [Falco](https://github.com/falcosecurity/falco) provides syscall-level detection regardless of encryption; <br/>
    Linkerd policy CRDs enforce identity-based authz; <br/>
    [Kyverno](https://github.com/kyverno/kyverno) ensures proxy injection annotations; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on proxy errors.

  [Linkerd Viz](https://github.com/linkerd/linkerd-viz) adds observability to Linkerd.
  - **S**: Dashboard, Prometheus metrics, tap/top for live traffic inspection.
  - **W**: Additional resource overhead; requires Prometheus.
  - **O**: Service topology visualization, latency debugging.
  - **T**: Tap access exposes sensitive traffic; metrics cardinality explosion.
  - **M**:
    [OpenFGA](https://github.com/openfga/openfga) controls tap access with fine-grained authorization; <br/>
    [Mimir](https://github.com/grafana/mimir) handles high-cardinality metrics; <br/>
    [Kyverno](https://github.com/kyverno/kyverno) policies restrict tap RBAC; <br/>
    [Falco](https://github.com/falcosecurity/falco) audits tap command usage.

  [External DNS](https://github.com/kubernetes-sigs/external-dns) automates DNS record management.
  - **S**: Supports Route53, CloudFlare, Google DNS; watches Services/Ingress/Gateway.
  - **W**: Provider-specific quirks; eventual consistency delays.
  - **O**: Eliminates manual DNS management; enables dynamic service discovery.
  - **T**: Misconfigured ownership causes record conflicts; DNS propagation delays.
  - **M**:
    [Kyverno](https://github.com/kyverno/kyverno) policies enforce DNS annotation standards; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on DNS sync failures; <br/>
    [Grafana](https://github.com/grafana/grafana) tracks DNS propagation latency; <br/>
    txt-owner-id prevents cross-cluster conflicts.

- **Observability Plane** — metrics, logs, traces, and profiles

  [Prometheus](https://github.com/prometheus/prometheus) provides pull-based metrics collection.
  - **S**: CNCF graduated, PromQL, Alertmanager, massive ecosystem.
  - **W**: Single-node storage limits; no native HA or long-term retention.
  - **O**: Foundation for all Kubernetes monitoring; Mimir for scale.
  - **T**: Cardinality explosion causes OOM; scrape failures create gaps.
  - **M**:
    [Mimir](https://github.com/grafana/mimir) provides HA and unlimited cardinality; <br/>
    [Kyverno](https://github.com/kyverno/kyverno) policies enforce label standards; <br/>
    recording rules pre-aggregate high-cardinality metrics; <br/>
    [Grafana](https://github.com/grafana/grafana) dashboards track scrape health.

  [Mimir](https://github.com/grafana/mimir) scales Prometheus to unlimited cardinality.
  - **S**: Multi-tenant, object storage backend, global query view, HA.
  - **W**: Operational complexity; requires tuning for cost optimization.
  - **O**: Years of retention at low cost; replaces Thanos/Cortex.
  - **T**: Compactor failures cause query degradation; ingester loss risks data.
  - **M**:
    [Grafana Rollout Operator](https://github.com/grafana/rollout-operator/) manages zone-aware deployments; <br/>
    [MinIO](https://min.io/) provides resilient object storage; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on compactor lag; <br/>
    [Velero](https://github.com/vmware-tanzu/velero) backs up Mimir configuration.

  [Loki](https://github.com/grafana/loki) provides cost-effective log aggregation.
  - **S**: Label-only indexing, LogQL, object storage, Grafana native.
  - **W**: Full-text search requires grep-style queries; no field indexing.
  - **O**: 10x cost reduction vs Elasticsearch for most use cases.
  - **T**: High-cardinality labels explode costs; ingester memory pressure.
  - **M**:
    [Kyverno](https://github.com/kyverno/kyverno) policies enforce log label standards; <br/>
    [Alloy](https://github.com/grafana/alloy) filters high-cardinality fields to log lines; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on ingester memory; <br/>
    [OpenCost](https://github.com/opencost/opencost) tracks log storage costs.

  [Tempo](https://github.com/grafana/tempo) stores traces without indexing.
  - **S**: Object storage only, OpenTelemetry/Jaeger/Zipkin support, trace-to-logs.
  - **W**: Requires trace ID for lookup; no tag-based search without metrics.
  - **O**: Dramatic cost reduction vs indexed trace stores.
  - **T**: Lost trace IDs mean lost traces; sampling decisions affect debugging.
  - **M**:
    [Alloy](https://github.com/grafana/alloy) tail-based sampling retains error traces; <br/>
    [Loki](https://github.com/grafana/loki) stores trace IDs in logs for correlation; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) exemplars link metrics to traces; <br/>
    [MinIO](https://min.io/) provides durable trace storage.

  [Pyroscope](https://github.com/grafana/pyroscope) enables continuous profiling.
  - **S**: CPU/memory/goroutine profiles, flame graphs, minimal overhead.
  - **W**: Language-specific agents; profiling overhead in hot paths.
  - **O**: Production performance debugging without reproducing locally.
  - **T**: Profile data is sensitive; storage costs for high-frequency sampling.
  - **M**:
    [OpenFGA](https://github.com/openfga/openfga) controls profile access; <br/>
    [Kyverno](https://github.com/kyverno/kyverno) policies limit profiling to non-prod by default; <br/>
    [MinIO](https://min.io/) provides cost-effective storage; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on profiling agent health.

  [Grafana](https://github.com/grafana/grafana) unifies observability visualization.
  - **S**: 100+ data sources, alerting, RBAC, team collaboration.
  - **W**: Dashboard sprawl; alert fatigue without proper hygiene.
  - **O**: Single pane of glass for metrics/logs/traces/profiles.
  - **T**: Exposed instance becomes attack vector; plugin vulnerabilities.
  - **M**:
    [Dex](https://github.com/dexidp/dex) provides SSO with MFA; <br/>
    [Linkerd](https://linkerd.io/) mTLS encrypts traffic; <br/>
    [Kyverno](https://github.com/kyverno/kyverno) policies restrict plugin installation; <br/>
    [Falco](https://github.com/falcosecurity/falco) detects unauthorized access; <br/>
    [Gateway API](https://github.com/kubernetes-sigs/gateway-api) manages ingress with TLS.

  [Grafana Alloy](https://github.com/grafana/alloy) collects all telemetry signals.
  - **S**: Single agent for metrics/logs/traces/profiles, HCL config, OTel native.
  - **W**: Replaces multiple agents; migration complexity.
  - **O**: Unified collection pipeline; reduces agent sprawl.
  - **T**: Agent failure loses all signals; config errors affect all telemetry.
  - **M**:
    DaemonSet ensures agent runs on all nodes; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on agent health; <br/>
    [Argo CD](https://github.com/argoproj/argo-cd) manages config as GitOps; <br/>
    [Kyverno](https://github.com/kyverno/kyverno) validates Alloy config syntax before deploy.

  [Grafana MCP](https://github.com/grafana/mcp-grafana) enables AI-assisted observability.
  - **S**: LLM integration via Model Context Protocol, natural language queries.
  - **W**: Early stage; LLM hallucinations in metric interpretation.
  - **O**: Democratizes observability for non-experts; incident acceleration.
  - **T**: LLM access to metrics is sensitive; prompt injection risks.
  - **M**:
    [OpenFGA](https://github.com/openfga/openfga) controls MCP access with fine-grained permissions; <br/>
    [Falco](https://github.com/falcosecurity/falco) audits LLM queries; <br/>
    [Kyverno](https://github.com/kyverno/kyverno) policies restrict MCP to specific namespaces; <br/>
    [Linkerd](https://linkerd.io/) encrypts MCP traffic.

  [Metrics Server](https://github.com/kubernetes-sigs/metrics-server) provides core resource metrics.
  - **S**: Required for HPA/VPA/kubectl top, lightweight, built-in.
  - **W**: No historical data; single point of failure.
  - **O**: Foundation for all Kubernetes autoscaling.
  - **T**: Metrics Server failure breaks HPA/VPA; kubelet scrape failures.
  - **M**:
    Multiple replicas with PodDisruptionBudget; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on Metrics Server health; <br/>
    [Kube State Metrics](https://github.com/kubernetes/kube-state-metrics) provides backup state visibility; <br/>
    [Argo CD](https://github.com/argoproj/argo-cd) ensures deployment consistency.

  [Kube State Metrics](https://github.com/kubernetes/kube-state-metrics) exposes object state.
  - **S**: Deployment/Pod/Node state as Prometheus metrics, desired vs actual.
  - **W**: High cardinality with many objects; memory scales with cluster size.
  - **O**: Alerting on Kubernetes state (pending pods, failed deployments).
  - **T**: API server load from watch connections; metric explosion in large clusters.
  - **M**:
    sharding across multiple instances for large clusters; <br/>
    [VPA](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler) right-sizes memory; <br/>
    [Mimir](https://github.com/grafana/mimir) handles cardinality; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) recording rules pre-aggregate common queries.

  [Node Exporter](https://github.com/prometheus/node_exporter) collects host metrics.
  - **S**: CPU/memory/disk/network, filesystem, hardware sensors.
  - **W**: Linux-focused; Windows support limited.
  - **O**: Infrastructure capacity planning, hardware failure detection.
  - **T**: Collector failures create monitoring gaps; textfile collector abuse.
  - **M**:
    [Prometheus](https://github.com/prometheus/prometheus) alerts on exporter down; <br/>
    [Kyverno](https://github.com/kyverno/kyverno) policies restrict textfile collector paths; <br/>
    [Falco](https://github.com/falcosecurity/falco) detects unauthorized textfile writes.

- **FinOps Plane** — cost visibility and optimization

  [OpenCost](https://github.com/opencost/opencost) provides Kubernetes cost allocation.
  - **S**: CNCF sandbox, namespace/deployment/label granularity, cloud billing integration.
  - **W**: Requires accurate cloud pricing data; shared resource attribution is approximate.
  - **O**: Showback/chargeback automation; budget alerts and optimization recommendations.
  - **T**: Stale pricing data causes inaccurate reports; label hygiene affects attribution.
  - **M**:
    [Kyverno](https://github.com/kyverno/kyverno) policies enforce cost-allocation labels on all workloads; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on pricing data staleness; <br/>
    [Cloud Cost Exporter](https://github.com/grafana/cloudcost-exporter) provides real-time cloud pricing; <br/>
    [Grafana](https://github.com/grafana/grafana) dashboards highlight unlabeled resources.

  [Cloud Cost Exporter](https://github.com/grafana/cloudcost-exporter) exposes cloud billing as metrics.
  - **S**: AWS/GCP/Azure support, Prometheus metrics, Grafana dashboards.
  - **W**: API rate limits; billing data delay (up to 24h).
  - **O**: Correlate cloud spend with resource utilization in single dashboard.
  - **T**: Cloud API changes break exporter; credential management complexity.
  - **M**:
    [Bank-Vaults](https://github.com/bank-vaults/vault-operator) manages cloud credentials with rotation; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on exporter failures; <br/>
    [Argo CD](https://github.com/argoproj/argo-cd) manages exporter config as GitOps; <br/>
    [Grafana](https://github.com/grafana/grafana) tracks billing data freshness.

- **Security Plane** — secrets, certificates, policies, and runtime protection

  [cert-manager](https://github.com/cert-manager/cert-manager) automates TLS certificate lifecycle.
  - **S**: CNCF graduated, Let's Encrypt/Vault/private CA, Gateway API integration.
  - **W**: Certificate rotation can cause transient failures; ACME rate limits.
  - **O**: Zero-trust with short-lived certificates; mTLS automation.
  - **T**: CA compromise invalidates all certificates; renewal failures cause outages.
  - **M**:
    [Velero](https://github.com/vmware-tanzu/velero) backs up CA keys; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on certificate expiry; <br/>
    [Linkerd](https://linkerd.io/) handles cert rotation via SDS; <br/>
    [Falco](https://github.com/falcosecurity/falco) detects unauthorized CA access; <br/>
    multiple issuers provide redundancy.

  [Bank-Vaults Operator](https://github.com/bank-vaults/vault-operator) manages Vault/[OpenBao](https://github.com/openbao/openbao) clusters.
  - **S**: Automated unsealing, config-as-code, backup/restore, HA setup.
  - **W**: Vault complexity inherited; requires understanding of Vault internals.
  - **O**: GitOps secrets management; dynamic secrets for databases.
  - **T**: Unseal key compromise = full secret exposure; etcd backend failures.
  - **M**:
    [CloudNativePG](https://github.com/cloudnative-pg/cloudnative-pg) provides HA PostgreSQL backend instead of etcd; <br/>
    [Velero](https://github.com/vmware-tanzu/velero) backs up Vault data; <br/>
    [Falco](https://github.com/falcosecurity/falco) detects unseal key access; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) monitors Vault health and seal status.

  [Bank-Vaults Webhook](https://github.com/bank-vaults/secrets-webhook) injects Vault secrets.
  - **S**: Transparent injection, no app changes, env vars or files.
  - **W**: Webhook failures block pod creation; init container overhead.
  - **O**: Seamless Vault/[OpenBao](https://github.com/openbao/openbao) adoption for existing workloads.
  - **T**: Vault/[OpenBao](https://github.com/openbao/openbao) unavailability blocks deployments; secret caching risks.
  - **M**:
    Multiple Vault/[OpenBao](https://github.com/openbao/openbao) replicas for HA; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on webhook latency; <br/>
    [Kyverno](https://github.com/kyverno/kyverno) policies allow fallback to Kubernetes secrets; <br/>
    [Argo Rollouts](https://github.com/argoproj/argo-rollouts) enables gradual secret rotation.

  [OpenBao](https://github.com/openbao/openbao) provides open-source secrets management (Vault fork).
  - **S**: Community fork of Vault, no license restrictions, API compatible.
  - **W**: Smaller community; diverging features from upstream Vault.
  - **O**: Vendor-neutral alternative to HashiCorp Vault post-BSL.
  - **T**: Fork maintenance burden; ecosystem tool compatibility gaps.
  - **M**:
    [Bank-Vaults Webhook](https://github.com/bank-vaults/secrets-webhook) works with OpenBao; <br/>
    [Velero](https://github.com/vmware-tanzu/velero) backs up OpenBao data; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) monitors OpenBao health; <br/>
    [Argo CD](https://github.com/argoproj/argo-cd) manages OpenBao config as GitOps.

  [OpenFGA](https://github.com/openfga/openfga) provides fine-grained authorization.
  - **S**: Zanzibar-inspired, relationship-based access control, high performance.
  - **W**: Requires modeling authorization as relationships; learning curve.
  - **O**: Consistent authz across microservices; replaces scattered RBAC logic.
  - **T**: Model errors cause access failures; storage backend dependency.
  - **M**:
    [CloudNativePG](https://github.com/cloudnative-pg/cloudnative-pg) provides HA PostgreSQL backend; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on authz latency; <br/>
    [Argo CD](https://github.com/argoproj/argo-cd) manages authorization models as GitOps; <br/>
    [Grafana](https://github.com/grafana/grafana) tracks authorization decision rates.

  [Reloader](https://github.com/stakater/Reloader) triggers rollouts on ConfigMap/Secret changes.
  - **S**: Automatic pod restart on config changes, annotation-based opt-in.
  - **W**: Restarts entire deployment; no graceful config reload.
  - **O**: GitOps config management without manual restarts.
  - **T**: Frequent config changes cause deployment churn; cascading restarts.
  - **M**:
    [Argo Rollouts](https://github.com/argoproj/argo-rollouts) provides gradual rollout on config changes; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on high restart rates; <br/>
    [Kyverno](https://github.com/kyverno/kyverno) policies limit Reloader scope; <br/>
    [Linkerd](https://linkerd.io/) maintains connections during rolling restarts.

  [Kyverno](https://github.com/kyverno/kyverno) enforces policies as Kubernetes CRDs.
  - **S**: No new language (YAML policies), validate/mutate/generate, background scans.
  - **W**: Policy complexity grows; webhook latency affects API server.
  - **O**: Compliance automation, security guardrails, best practice enforcement.
  - **T**: Overly strict policies block legitimate workloads; policy bypass via direct etcd.
  - **M**:
    Policy exceptions via Kyverno PolicyException CRD; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on policy violations; <br/>
    [Argo CD](https://github.com/argoproj/argo-cd) manages policies as GitOps with review; <br/>
    [Falco](https://github.com/falcosecurity/falco) detects direct etcd access attempts.

  [Falco](https://github.com/falcosecurity/falco) detects runtime threats via syscall analysis.
  - **S**: eBPF/kernel module, real-time detection, SIEM integration.
  - **W**: eBPF requires kernel 5.8+; rule tuning for false positives.
  - **O**: Container escape detection, compliance monitoring, incident response.
  - **T**: eBPF bugs are kernel-level; high-volume alerts cause fatigue.
  - **M**:
    [Prometheus](https://github.com/prometheus/prometheus) aggregates Falco metrics for trend analysis; <br/>
    [Loki](https://github.com/grafana/loki) stores Falco events for investigation; <br/>
    [Grafana](https://github.com/grafana/grafana) dashboards prioritize high-severity alerts; <br/>
    [Argo Workflows](https://github.com/argoproj/argo-workflows) automates incident response.

- **Storage Plane** — persistent storage, object storage, and data systems

  [MinIO](https://min.io/) provides S3-compatible object storage.
  - **S**: High performance, erasure coding, encryption, multi-cloud.
  - **W**: Operational complexity at scale; no native Kubernetes operator.
  - **O**: On-prem S3 for Loki/Tempo/Mimir backends; data sovereignty.
  - **T**: Disk failures without proper erasure coding cause data loss.
  - **M**:
    [Prometheus](https://github.com/prometheus/prometheus) alerts on disk health and erasure coding status; <br/>
    [Velero](https://github.com/vmware-tanzu/velero) backs up MinIO configuration; <br/>
    [TopoLVM](https://github.com/topolvm/topolvm) provides reliable local storage for MinIO; <br/>
    [Grafana](https://github.com/grafana/grafana) dashboards track storage utilization.

  [Local Path Provisioner](https://github.com/rancher/local-path-provisioner) enables node-local PVCs.
  - **S**: Simple, fast, no external dependencies, dev-friendly.
  - **W**: No replication; data tied to node; not for production stateful workloads.
  - **O**: Development clusters, CI caches, edge deployments.
  - **T**: Node failure = data loss; no migration path to distributed storage.
  - **M**:
    [Kyverno](https://github.com/kyverno/kyverno) policies restrict Local Path to non-production namespaces; <br/>
    [Velero](https://github.com/vmware-tanzu/velero) backs up critical local data; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on node health; <br/>
    [TopoLVM](https://github.com/topolvm/topolvm) provides production alternative with same simplicity.

  [TopoLVM](https://github.com/topolvm/topolvm) provides LVM-based local storage with scheduling.
  - **S**: Capacity-aware scheduling, thin provisioning, snapshot support.
  - **W**: Requires LVM setup on nodes; Linux-only.
  - **O**: Production-grade local storage with proper scheduling.
  - **T**: LVM misconfiguration causes data corruption; resize failures.
  - **M**:
    [Kyverno](https://github.com/kyverno/kyverno) validates storage class configurations; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on LVM health; <br/>
    [PVC Autoresizer](https://github.com/topolvm/pvc-autoresizer) prevents capacity exhaustion; <br/>
    [Velero](https://github.com/vmware-tanzu/velero) backs up critical volumes.

  [PVC Autoresizer](https://github.com/topolvm/pvc-autoresizer) expands volumes automatically.
  - **S**: Prevents disk-full outages, threshold-based expansion.
  - **W**: Requires CSI driver support for expansion; can't shrink.
  - **O**: Cost optimization by starting small; SRE toil reduction.
  - **T**: Expansion failures during critical workloads; runaway growth.
  - **M**:
    [Kyverno](https://github.com/kyverno/kyverno) policies set maximum volume sizes; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on expansion failures; <br/>
    [OpenCost](https://github.com/opencost/opencost) tracks storage cost growth; <br/>
    [Grafana](https://github.com/grafana/grafana) dashboards visualize expansion trends.

  [Velero](https://github.com/vmware-tanzu/velero) provides backup and disaster recovery.
  - **S**: Cluster backup/restore, migration, scheduled backups, S3 storage.
  - **W**: Large cluster backups are slow; restore testing often neglected.
  - **O**: DR compliance, cluster migration, namespace-level recovery.
  - **T**: Untested restores fail in emergencies; backup storage compromise.
  - **M**:
    [Argo Workflows](https://github.com/argoproj/argo-workflows) automates restore testing; <br/>
    [MinIO](https://min.io/) provides resilient backup storage; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on backup failures; <br/>
    [Falco](https://github.com/falcosecurity/falco) detects unauthorized backup access.

  [CloudNativePG](https://github.com/cloudnative-pg/cloudnative-pg) operates PostgreSQL clusters.
  - **S**: HA with Patroni, streaming replication, backup to S3, connection pooling.
  - **W**: PostgreSQL-specific; complex failure scenarios.
  - **O**: Production-grade PostgreSQL without managed service costs.
  - **T**: Split-brain scenarios; backup corruption; replication lag.
  - **M**:
    [Prometheus](https://github.com/prometheus/prometheus) alerts on replication lag and failover events; <br/>
    [MinIO](https://min.io/) stores WAL archives; <br/>
    [Linkerd](https://linkerd.io/) provides connection retry during failover; <br/>
    [Grafana](https://github.com/grafana/grafana) tracks query performance.

  [MongoDB Community Operator](https://github.com/mongodb/mongodb-kubernetes-operator) manages MongoDB.
  - **S**: ReplicaSet management, automated failover, TLS, authentication.
  - **W**: Community edition limitations; no sharding support.
  - **O**: Document database for microservices; schema flexibility.
  - **T**: Replication lag causes stale reads; oplog overflow.
  - **M**:
    [Prometheus](https://github.com/prometheus/prometheus) alerts on replication lag and oplog size; <br/>
    [Velero](https://github.com/vmware-tanzu/velero) backs up MongoDB data; <br/>
    [Linkerd](https://linkerd.io/) retries during primary election; <br/>
    [cert-manager](https://github.com/cert-manager/cert-manager) automates TLS certificate rotation.

  [Valkey](https://github.com/valkey-io/valkey) provides Redis-compatible in-memory store (Redis fork).
  - **S**: Community fork post-Redis license change, API compatible, high performance.
  - **W**: Smaller ecosystem; diverging features from Redis.
  - **O**: Vendor-neutral caching/messaging; session storage.
  - **T**: Memory exhaustion causes eviction; persistence trade-offs.
  - **M**:
    [VPA](https://github.com/kubernetes/autoscaler/tree/master/vertical-pod-autoscaler) right-sizes memory; <br/>
    [Prometheus](https://github.com/prometheus/prometheus) alerts on memory pressure and eviction rates; <br/>
    [Kyverno](https://github.com/kyverno/kyverno) policies enforce memory limits; <br/>
    [Velero](https://github.com/vmware-tanzu/velero) backs up RDB snapshots.

  [Strimzi](https://github.com/strimzi/strimzi-kafka-operator) operates Apache Kafka clusters.
  - **S**: Full Kafka lifecycle via CRDs, rolling updates, TLS, authentication.
  - **W**: Kafka complexity inherited; resource-intensive.
  - **O**: Event streaming backbone; decoupled microservices.
  - **T**: Partition rebalancing storms; broker failures cascade.
  - **M**:
    [Prometheus](https://github.com/prometheus/prometheus) alerts on consumer lag and broker health; <br/>
    [Grafana Rollout Operator](https://github.com/grafana/rollout-operator/) serializes broker updates; <br/>
    [KEDA](https://keda.sh/) scales consumers based on lag; <br/>
    [cert-manager](https://github.com/cert-manager/cert-manager) automates Kafka TLS rotation.

  [K8ssandra](https://github.com/k8ssandra/k8ssandra-operator) manages Apache Cassandra.
  - **S**: Multi-DC replication, Medusa backup, Reaper repairs, Stargate APIs.
  - **W**: Cassandra operational complexity; tuning expertise required.
  - **O**: Global-scale distributed database; write-heavy workloads.
  - **T**: Compaction storms; tombstone accumulation; repair failures.
  - **M**:
    [Prometheus](https://github.com/prometheus/prometheus) alerts on compaction pending and tombstone ratios; <br/>
    [MinIO](https://min.io/) stores Medusa backups; <br/>
    [Grafana](https://github.com/grafana/grafana) dashboards track repair progress; <br/>
    [Argo Workflows](https://github.com/argoproj/argo-workflows) automates repair scheduling.

### Design Caveats

1. **VPA recommendations can exceed cluster capacity.**
   Kamaji scales node pools when VPA requests exceed limits. Kyverno caps max resource requests. Goldilocks flags outliers.

2. **Cluster autoscaling must be infrastructure-aware.**
   Kamaji integrates with Terraform modules to manage node pools atomically. Prometheus forecasts demand for predictive scaling.

3. **eBPF is expensive and risky.**
   Use Calico without eBPF dataplane in sensitive environments. Linkerd provides mTLS without kernel-level hooks. 
   Falco detects eBPF-based attacks at syscall level.

4. **Schema vs data migrations need different tools.**
   Atlas Operator handles schema; Argo Workflows orchestrates data migrations with Velero backups before execution.

5. **Prometheus cardinality explosion causes OOM.**
   Kyverno enforces label standards. Mimir handles cardinality at scale. Recording rules pre-aggregate expensive queries.

6. **GitOps and operators fight over resource ownership.**
   Use Argo CD `ignoreDifferences` for operator-managed fields. Kyverno validates ownership annotations.

7. **Secret rotation doesn't restart consumers.**
   Reloader triggers rollouts on Secret changes. Argo Rollouts coordinates zero-downtime rotation. Bank-Vaults caches secrets.

8. **Namespaces don't isolate noisy neighbors.**
   Kyverno enforces ResourceQuotas and LimitRanges. Calico NetworkPolicies segment traffic. Kamaji provides hard isolation.

9. **Head-based trace sampling drops error traces.**
   Alloy tail-based sampling retains errors. Loki correlates trace IDs. Prometheus exemplars link metrics to traces.

10. **Certificate rotation causes TLS failures.**
    Set cert-manager `renewBefore` to 33% of lifetime. Linkerd SDS handles rotation automatically. Prometheus alerts on expiry.

11. **Kafka rebalancing causes stop-the-world pauses.**
    Use cooperative-sticky assignor. Grafana Rollout Operator serializes broker updates. KEDA scales consumers on lag.

12. **VPA and HPA conflict on same workload.**
    Use VPA in recommendation mode with KEDA for scaling. Goldilocks identifies which pattern fits each workload.

13. **Loki costs explode with high-cardinality labels.**
    Alloy filters cardinality to log lines. Kyverno enforces label standards. OpenCost tracks log storage costs.

14. **mTLS breaks network inspection tools.**
    Falco detects threats at syscall level. Linkerd policy CRDs enforce identity-based authz. Tap provides authorized decryption.

15. **Webhook failures block pod creation.**
    Bank-Vaults Webhook runs with multiple replicas. Kyverno failurePolicy allows fallback. Prometheus alerts on latency.

16. **etcd pressure from CRD accumulation.**
    Tekton Results offloads history to PostgreSQL. Argo CD prunes old Applications. Kyverno enforces TTL on ephemeral CRs.

17. **Single agent failure loses all telemetry.**
    Alloy DaemonSet ensures node coverage. Prometheus alerts on agent health. Loki/Mimir buffer during brief outages.

18. **Runaway workflows exhaust cluster resources.**
    Kyverno limits parallelism and resource requests. KEDA scales workflow controllers. Prometheus alerts on queue depth.

19. **Event storms trigger workflow floods.**
    Strimzi Kafka buffers events with backpressure. Kyverno limits workflows per trigger. KEDA scales event processors.

20. **GPU fragmentation wastes expensive resources.**
    Volcano gang scheduling ensures coordinated allocation. Descheduler rebalances underutilized nodes. OpenCost tracks GPU costs.

21. **Database failover causes connection errors.**
    CloudNativePG with Patroni handles automatic failover. Linkerd retries failed connections. Prometheus alerts on lag.

22. **Backup restores fail when untested.**
    Argo Workflows automates restore testing. Velero schedules regular backups to MinIO. Prometheus alerts on backup age.

23. **Policy bypass via direct etcd access.**
    Falco detects etcd access attempts. Calico restricts etcd network access. Kyverno audit mode logs violations.

24. **LLM access to metrics exposes sensitive data.**
    OpenFGA controls Grafana MCP permissions. Falco audits LLM queries. Kyverno restricts MCP to specific namespaces.

25. **Supply chain attacks via unsigned images.**
    Tekton Chains signs all builds. Kyverno blocks unsigned images. Falco detects runtime anomalies from compromised images.

26. **IdP outages cascade to all services.**
    Dex runs multiple replicas behind Gateway API. Valkey caches tokens. Prometheus alerts on IdP connectivity.

27. **Canary rollouts stuck on misconfigured analysis.**
    Linkerd golden metrics feed Argo Rollouts analysis. Prometheus provides rollout metrics. Grafana visualizes progression.

28. **Storage backend failures break registries and observability.**
    MinIO erasure coding survives disk failures. Velero backs up configuration. Prometheus alerts on storage health.

29. **Compaction storms degrade Cassandra performance.**
    Prometheus alerts on pending compactions. K8ssandra Reaper schedules repairs. Argo Workflows automates maintenance windows.

30. **Memory exhaustion evicts cache data.**
    VPA right-sizes Valkey memory. Prometheus alerts on eviction rates. Kyverno enforces memory limits.
