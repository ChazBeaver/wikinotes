1. How would you stand up EKS in GovCloud at IL5?

"At IL5 the constraints drive the architecture. I'd start with a private VPC in GovCloud — no public subnets, all egress through controlled NAT or VPC endpoints, and PrivateLink for AWS service access so traffic never leaves the AWS backbone. The EKS control plane goes private-endpoint only, with kubectl access gated through SSM Session Manager rather than bastions.
For the cluster itself: hardened node AMIs — STIG-compliant, ideally based on Iron Bank or a DISA-hardened RHEL image. IRSA for pod-level IAM so workloads get scoped permissions without static credentials. KMS for envelope encryption on EBS volumes, secrets, and the etcd backing store. Pod Security Standards or admission controllers like Kyverno or OPA Gatekeeper to enforce baseline policies — no privileged pods, no host networking, signed images only.
Networking-wise, I'd use VPC CNI with security groups for pods, plus Kubernetes NetworkPolicies for east-west segmentation. Ingress gets terminated at an internal ALB or Istio gateway with TLS enforced end-to-end and certificates managed through ACM or cert-manager.
For deployment, GitOps via ArgoCD or Flux pulling from a private GitLab or CodeCommit, with all container images coming from a hardened registry — Iron Bank or an internal Harbor with image signing and CVE scanning enforced at admission.
On compliance, you wire up CloudTrail, Config, GuardDuty, and Security Hub from day one because you'll need that evidence for the ATO package. STIG scans run continuously, results go to a SIEM, and you tie the whole thing to the SSP controls."

Why this works: It maps directly to what you do at PCI Federal, hits all the right IL5 buzzwords (Iron Bank, IRSA, KMS, PrivateLink, ATO/SSP), and demonstrates architectural thinking, not just tool name-dropping.

2. How would you handle secrets in an air-gapped environment?

"Air-gapped changes the playbook because you can't reach external secret managers, and you can't pull external dependencies. So you bring the secret backend inside the boundary.
My default would be HashiCorp Vault deployed inside the cluster or alongside it, with Vault's Kubernetes auth method so pods authenticate using their service account JWT — no static tokens. The External Secrets Operator or Vault Agent injector pulls secrets at runtime so they never sit in Git or container images.
For unseal, I'd use auto-unseal backed by a local KMS or an HSM — never manual unseal in production. Secrets get rotated on a defined cadence, and rotation is automated where possible (database creds, certs, API keys).
For TLS specifically, I'd run a private CA — either Vault's PKI engine or an internal step-ca — and use cert-manager with that issuer so certificates rotate automatically across the platform.
Bootstrap is the tricky part in air-gapped: the very first secrets — the seed credentials, root CA, Vault unseal keys — have to come in via a controlled side channel, usually a one-time encrypted bundle delivered through the approved transfer process. After that, everything is self-contained.
At PCI Federal I've worked with Keycloak for OIDC-based identity federation and IRSA for AWS-side credential elimination, so the principle of pulling identity from the platform rather than baking secrets into images is something I do daily."

Why this works: Vault + cert-manager + Keycloak/IRSA is exactly the toolset Govly and Ditto expect to hear. The bootstrap-via-side-channel detail signals that you've actually thought about air-gapped, not just read about it.

3. How does GitOps work when the cluster has no internet?

"The core principle still holds — declarative state in Git, continuous reconciliation by an in-cluster agent — but every external dependency has to be mirrored inside the boundary.
So practically: Git itself runs inside, usually a self-hosted GitLab or Gitea. Container images come from an internal registry — Harbor or ECR with replication, populated by a sync process that pulls Iron Bank or your hardened images from a connected staging environment, scans them, signs them with Cosign, and pushes them in. Helm charts get mirrored the same way, either to a ChartMuseum or as OCI artifacts in the same registry.
ArgoCD or Flux runs inside the cluster and only ever reaches into the internal Git and registry — never out. The reconciliation loop works exactly the same: commit a manifest change, the agent pulls, diffs against live state, and applies.
The interesting design problem is promotion across the air gap. You can't just merge a PR in the connected dev environment and have it appear on the high side. So you build a pipeline that produces a versioned, signed bundle — manifests, charts, images — that gets approved, scanned, and shipped through the cross-domain transfer process. Once it lands on the high side, an automated importer pushes it into the internal Git and registry, and ArgoCD picks up from there.
At PCI Federal I work with this pattern — Iron Bank images, internal Harbor, ArgoCD/Flux pulling from internal sources — so the model is familiar."

Why this works: This is sophisticated. It shows you understand that GitOps in air-gapped is about the promotion pipeline across the gap, not just the in-cluster reconciliation. That's the part most candidates miss.

4. A time you debugged a hard production issue under pressure
Use the STAR format (Situation, Task, Action, Result). Here's one drawn directly from your resume:

"At PCI Federal we were running a critical RHEL8-based container platform that hit a wall when several CVEs got published with no RHEL8 patches available — the upstream maintainers were prioritizing RHEL9. We had a hard compliance deadline because the unpatched vulnerabilities would have failed our next STIG scan and put our ATO at risk.
Situation: I was tasked with leading a full RHEL8 to RHEL9 container migration across the platform under a tight timeline, while keeping production stable.
Task: Validate every workload against RHEL9 base images, resolve dependency and library incompatibilities, and roll the migration through dev, staging, and production without downtime.
Action: I worked through the dependency tree image by image, identified the breakage points — mostly around glibc differences and a couple of Python library conflicts — and patched our Helm charts and Dockerfiles. I leaned heavily on our GitOps pipeline so I could promote each fix through environments and roll back instantly if something broke. I coordinated with the security team on parallel CVE validation as we went.
Result: We completed the migration ahead of the compliance deadline, closed all the CVEs, and the migration shipped without a customer-facing outage. It also became a documented playbook for future base-image upgrades, which the team still uses.
The lesson for me was that GitOps and immutable infrastructure aren't just nice-to-haves under pressure — they're what made it possible to move fast and roll back fast at the same time."

Why this works: Real, specific, measurable, and it demonstrates exactly the skills both Govly and Ditto need — operating under compliance pressure, owning the full migration, GitOps-driven rollouts.
Alternative answer if they want a faster-paced incident: Use a time you troubleshot Istio, ArgoCD, or Keycloak issues at PCI Federal under deadline — pick one, format it the same way.

5. Cross Domain Solutions — the honest answer

"I'll be straight with you — I haven't worked directly with CDS or data diodes in production. My current work at PCI Federal is single-classification, regulated DoD-adjacent, so the cross-domain piece would be a ramp for me.
What I do understand is the underlying problem: unidirectional data flow between classification levels, with the high side never able to reach back to the low side, and every transfer needing to be policy-validated, content-inspected, and auditable. I understand why you can't just open a network path — the threat model is exfiltration and data spillage, and the diode hardware enforces that physically.
Conceptually, I see CDS as another constraint on the architecture, similar to air-gapped GitOps — you build a controlled promotion pipeline, you make every transfer auditable, and you design your application to tolerate one-way data flow. The work I've done with Big Bang, Iron Bank, and air-gapped deployments at PCI Federal gives me the right mental model — I'd just need to learn the specific products in use, like Owl or Forcepoint, and the operational workflows.
I'm a fast ramp on this kind of thing. I picked up Iron Bank, IRSA, Keycloak, and Big Bang from cold starts in my current role, and the STIG ingestion pipeline I built integrated half a dozen new technologies I hadn't worked with before."

Why this works: Honesty plus signal. You acknowledge the gap, demonstrate you understand the concept and the why, and back up the "fast ramp" claim with specific evidence rather than just asserting it. Hiring managers respect this far more than someone bluffing.
