# Iron Bank / STIG'd Container Gotchas
[CRITICAL] Iron Bank images run as non-root by default (usually UID 1001 or nobody). Apps that bind to ports <1024, write to /var/log, or assume /root is writable will crash. You set securityContext.runAsUser explicitly and bind to ports >1024.
[CRITICAL] Iron Bank images often ship with read-only root filesystems when used per the hardened spec. Apps that write temp files anywhere except mounted emptyDir volumes will silently fail. You add an emptyDir mount at /tmp and any other writable path the app needs.
[CRITICAL] Iron Bank images are distroless or minimal — no shell, no curl, no ps, no package manager. kubectl exec -it pod -- sh will fail. You use kubectl debug with an ephemeral debug container (--image=busybox with --target=<container>) to share the process namespace and troubleshoot.
[IMPORTANT] Iron Bank images lag upstream by weeks-to-months because of hardening review. When CVEs drop, you don't get same-day patches. You need a process for accepting risk on known CVEs in Iron Bank images while waiting for hardened versions, documented as POA&Ms.
[IMPORTANT] The VAT (Vulnerability Assessment Tracker) status of an Iron Bank image is critical. An image being in Iron Bank doesn't mean it's approved — it means it's available. Check VAT status before deploying to prod, and know how to interpret findings.
[STAFF] When you build custom apps, the Iron Bank submission process for your image takes 3–6 weeks minimum. Plan accordingly. Most teams use the public Iron Bank base images and layer their own app on top in a private registry rather than getting the final image into Iron Bank itself.

# Kubernetes Operations
[CRITICAL] Pod eviction order under node pressure matters. Pods are killed by QoS class: BestEffort first, then Burstable, then Guaranteed. If you don't set requests/limits, your pod is BestEffort and dies first when the node gets squeezed. Production workloads should be Guaranteed (requests = limits) or at least Burstable.
[CRITICAL] kubectl describe before kubectl logs, always. Describe shows events, exit codes, restart counts, image pull status, volume mount errors, scheduling failures — most CrashLoopBackOffs are diagnosed from describe alone, not logs.
[CRITICAL] PodDisruptionBudgets save you during node drains. Without a PDB, a node drain (for upgrades, scaling, or AWS maintenance) can take down all replicas of a service simultaneously. PDB with minAvailable: 1 (or percentage) ensures at least one stays up. You should have these on every production workload.
[IMPORTANT] Resource requests are scheduling, not limits. Requests determine where the pod gets scheduled (the scheduler reserves that capacity). Limits determine when it gets killed. CPU limits cause throttling (not killing). Memory limits cause OOMKill (137). Many teams set CPU limits and create artificial throttling — most production guidance now says set CPU requests, omit CPU limits.
[IMPORTANT] terminationGracePeriodSeconds defaults to 30s. If your app needs longer to drain (DB connections, in-flight requests), pods get SIGKILL'd mid-flight during rolling updates. Increase this for stateful or long-request workloads.
[IMPORTANT] The init container chain runs sequentially, app containers run in parallel. A slow init container blocks startup. A failing init container loops forever. You can use init containers to wait for dependencies (e.g., DB ready) — but if the dependency never comes up, the pod is stuck and won't trigger alerts that look at the main container.
[IMPORTANT] HPA reads metrics with a delay. Default scrape interval + smoothing window means HPA reacts to load 30–90 seconds after it actually arrives. For bursty workloads, you need either KEDA, custom metrics, or pre-warmed capacity. HPA is not a substitute for capacity planning.
[STAFF] etcd is the single point of failure for the control plane. EKS hides this from you, but the practical implication: large objects (configmaps/secrets >1MB, huge custom resources) bloat etcd and slow the entire API server. There's a hard 1.5MB limit per object. If your app stores config in a ConfigMap and it grows, you'll hit this and not understand why.
[STAFF] Watch vs. List API patterns matter at scale. Controllers that LIST every reconcile loop instead of using a WATCH cache hammer the API server. Many community operators have this bug. When the cluster gets slow, check apiserver_request_total by user agent.

# EKS / AWS Specifics
[CRITICAL] VPC CNI assigns real VPC IPs to every pod. Each EC2 instance type has a max ENI count and IPs-per-ENI limit. A t3.medium can only run ~17 pods, not because of CPU — because of IP exhaustion. Check --max-pods against your subnet CIDR size before scaling.
[CRITICAL] EKS subnet IP exhaustion is a silent killer. Pods stay Pending with "no IP available" errors. Subnets need to be sized for: nodes + pods + ENIs + headroom. A /24 subnet (256 IPs) holds way fewer pods than people think. Use prefix delegation if you're hitting this.
[CRITICAL] IMDSv2 should be enforced (hop limit 1, tokens required) on all nodes. IMDSv1 is a documented attack vector for SSRF → cloud creds. STIG requires this. Verify with aws ec2 describe-instances --query 'Reservations[].Instances[].MetadataOptions'.
[IMPORTANT] EKS node IAM role vs. IRSA. If pods can hit IMDS, they get the node's IAM role permissions, bypassing IRSA. You either block IMDS access from pods (hop limit 1) or use a network policy. Otherwise IRSA is theater.
[IMPORTANT] EBS volumes are AZ-locked. A pod with a PVC backed by EBS cannot be rescheduled to a different AZ. If the AZ goes down or the node goes down and no replacement spins up in the same AZ, the pod is stuck Pending forever. This is why stateful workloads often use EFS (multi-AZ) or topology-aware scheduling.
[IMPORTANT] EKS control plane upgrades are one minor version at a time, in order, and AWS deprecates old versions on a schedule (~14 months). Skipping versions isn't allowed. You need a documented quarterly upgrade cadence or you'll fall behind and be forced into an emergency upgrade.
[STAFF] Cross-account IRSA requires the trust policy to include the OIDC provider from the other account, plus the source account's STS endpoint must be enabled in that region. Common gotcha for federated/multi-account GovCloud setups.
[STAFF] GovCloud quirks: different ARN partition (aws-us-gov), separate account from commercial, certain services lag (or never arrive), no public AMIs from commercial AWS, separate IAM identities. SCPs and Control Tower behave differently. ITAR boundary means you cannot have non-US-person admin access — ever.

# ArgoCD / GitOps
[CRITICAL] ArgoCD's automated sync with prune: true will delete resources you didn't intend if you remove a manifest from Git. Always test with prune: false first. The number of "I deleted prod" stories from this is staggering.
[CRITICAL] syncPolicy.syncOptions: CreateNamespace=true is needed if your app creates its own namespace. Without it, ArgoCD will fail because the namespace doesn't exist yet but it's trying to create resources in it.
[IMPORTANT] App-of-apps vs. ApplicationSet. App-of-apps was the old pattern; ApplicationSet is now the recommended approach for managing many apps. ApplicationSet generators (list, cluster, git, matrix) let you template apps across environments without writing each one.
[IMPORTANT] ArgoCD's Helm support uses helm template, not helm install. This means Helm hooks (pre-install, post-install) don't run the way they would with Helm CLI. You either use ArgoCD sync waves to replicate the behavior or use argocd.argoproj.io/sync-wave annotations.
[IMPORTANT] OutOfSync != broken. A drifting resource doesn't mean an outage. Many resources legitimately change (replica counts from HPA, status fields, labels added by admission webhooks). Use ignoreDifferences to suppress noise, or your UI is permanently red and you stop trusting it.
[STAFF] ArgoCD itself needs to be GitOps'd (managed by another ArgoCD or by itself with bootstrapping). The bootstrap problem — "who watches the watcher" — is solved by either a separate management cluster or by ArgoCD managing its own manifests with a pinned initial state.

# Secrets & TLS
[CRITICAL] Kubernetes Secrets are base64-encoded, not encrypted, by default. They're stored in plaintext in etcd. EKS encryption at rest using KMS must be enabled at cluster creation — you can't add it later. Verify with aws eks describe-cluster --query 'cluster.encryptionConfig'.
[CRITICAL] Don't commit secrets to Git, even encrypted ones, without thinking carefully. SOPS + age/KMS is a viable pattern for GitOps secrets. Sealed Secrets is another. External Secrets Operator + AWS Secrets Manager / SSM Parameter Store is the cleanest pattern in AWS.
[IMPORTANT] TLS cert rotation is rarely automated for everything. cert-manager handles in-cluster certs. But ALB certs, custom CA-issued certs, mTLS certs between services, and external integrations all rotate on different schedules. A "TLS expired" outage at 3am is a rite of passage.
[IMPORTANT] Keycloak realm exports can leak secrets. When you export a realm for backup or migration, client secrets and SMTP credentials come with it. Treat exports as sensitive. STIG audit findings frequently flag this.

# Observability
[CRITICAL] Prometheus is not a long-term store. Default retention is 15 days. If you need historical data (compliance, capacity planning, post-mortems older than 2 weeks), you need Thanos, Mimir, or Cortex. You have Thanos on your resume — make sure you understand the sidecar vs. receiver patterns and object storage backends.
[CRITICAL] High-cardinality labels kill Prometheus. Putting user_id, request_id, pod_uid in labels creates a unique time series for each value. Memory blows up. Queries slow to a crawl. Cardinality should stay under ~10K series per metric ideally.
[IMPORTANT] Alert fatigue is the silent killer. Alerts that fire constantly get ignored. Every alert should be: actionable, specific, and tied to a runbook. "CPU > 80%" is not an alert; "API latency p99 > 500ms for 5min affecting checkout flow" is.
[IMPORTANT] Recording rules pre-compute expensive queries. If your dashboard is slow, the answer is usually a recording rule, not more Prometheus replicas.
[STAFF] Metrics, logs, and traces are different tools for different jobs. Metrics tell you something is wrong (low cardinality, cheap, fast). Logs tell you what is wrong (high cardinality, expensive, slow). Traces tell you where in a distributed system it's wrong (medium cost, requires instrumentation). Mature platforms have all three. Knowing when to reach for which is staff-level.

# Linux / Container Runtime
[CRITICAL] OOMKilled (exit 137) is a kernel-level kill. Your app gets no chance to clean up. If you see 137 in container exit codes, it's the cgroup memory limit. Either raise the limit or fix the leak — you can't catch it in code.
[CRITICAL] /etc/resolv.conf in pods is generated by kubelet based on dnsPolicy. ClusterFirst (default) routes through CoreDNS. Default uses the node's resolver. NDOTS:5 in the default config causes DNS amplification — a lookup for external.com tries external.com.namespace.svc.cluster.local first, then external.com.svc.cluster.local, etc. This is a documented Kubernetes performance issue.
[IMPORTANT] Containers share the host kernel. A kernel CVE on the host affects every container. Patching the kernel requires node replacement (in EKS, that's a node group rotation). Container scanning misses kernel-level vulns.
[IMPORTANT] SIGTERM then wait then SIGKILL is the pod termination flow. If your app ignores SIGTERM, it gets SIGKILL'd after terminationGracePeriodSeconds. Apps written without signal handling drop in-flight requests at shutdown.

# DoD / Compliance Specifics
[CRITICAL] STIG findings have severity (CAT I/II/III) and you're expected to remediate or document a POA&M with mitigations and a deadline. CAT I findings on production are audit failures — they have to be addressed before ATO.
[CRITICAL] cATO (continuous ATO) is the goal of Big Bang. Traditional ATO is point-in-time; cATO requires continuous monitoring, automated compliance evidence, and a documented control inheritance model. The platform inherits controls from underlying GovCloud; apps inherit from the platform.
[IMPORTANT] NIST 800-53 control families — know AC (access control), AU (audit), CM (config management), IA (identification/auth), SC (system/comm protection), SI (system/info integrity) at minimum. These map to specific Kubernetes/AWS configurations and STIG checks.
[IMPORTANT] Impact Levels (IL2/IL4/IL5/IL6) determine what data can run where. IL2 = public, IL4 = CUI, IL5 = controlled unclass + national security, IL6 = classified. GovCloud is IL4/IL5. C2S/SC2S is IL6. Knowing what your environment is rated for and what data is allowed is a basic compliance requirement.
[STAFF] The boundary is the unit of ATO. Everything inside the boundary inherits controls together. Crossing boundaries (e.g., calling a service in a different ATO'd system) requires documented interconnections (ICDs, MOUs). Architecture decisions about boundaries determine compliance scope for years.

# Career-level Knowledge
[IMPORTANT] The 4 Golden Signals (Latency, Traffic, Errors, Saturation) from the Google SRE book. If you can't articulate these for any service you operate, you don't understand its health.
[IMPORTANT] The CAP theorem (Consistency, Availability, Partition tolerance — pick 2). Comes up in every distributed systems design discussion. You need to know which your tools choose: etcd is CP, Cassandra is AP, etc.
[STAFF] Conway's Law: systems mirror the communication structure of the org that built them. Why your platform has 14 different ways to do logging — because 14 teams built it without talking. Mature platform engineering is as much organizational as technical.

# How to use this list
Don't try to learn it all at once. The way to internalize this:

Pick 3 [CRITICAL] items per week that are relevant to your current work
Try to break them in your home lab — you have one, use it. The lessons stick when you've debugged them yourself, not when you've read about them
Write a runbook for each as you learn it. Teaching forces understanding
Bring them up in conversation at work — "hey, are we handling X?" — this both reinforces it and signals competence to your team

The senior-to-staff transition is mostly about pattern recognition across domains. You start to see that "etcd object size limit" and "Prometheus cardinality" and "VPC IP exhaustion" are all the same shape of problem: bounded resource, unbounded input, silent failure mode. Once you see the shape, you start spotting it everywhere — in tools you've never used.
