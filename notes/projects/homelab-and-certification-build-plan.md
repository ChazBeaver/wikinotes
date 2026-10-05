# Homelab and certification build plan

Created: 2026-10-04

Status: Deferred until all planned core certifications are complete; no
infrastructure has been provisioned by this plan.

Purpose: Keep certification completion first, then use this reference to choose
tools, build a homelab, and deepen practical platform engineering skills.

## Contents

- [Direction and priorities](#direction-and-priorities)
- [How the certifications fit](#how-the-certifications-fit)
- [Recommended tools and ownership](#recommended-tools-and-ownership)
- [Build milestones](#build-milestones)
- [Ubuntu and kubeadm or Talos](#ubuntu-and-kubeadm-or-talos)
- [Exercise backlog](#exercise-backlog)
- [AWS and EKS later](#aws-and-eks-later)
- [When to host personal services](#when-to-host-personal-services)
- [Keeping the project manageable](#keeping-the-project-manageable)
- [Session record](#session-record)
- [Next actions](#next-actions)

## Direction and priorities

Complete the entire planned core certification path before pursuing the homelab
build. Finishing Terraform Associate 004 or AWS Solutions Architect Associate
alone does not unlock this project. Homelab implementation begins only after
all planned core certifications, renewals, and retakes are complete.

During certification preparation, use course-provided labs, exam simulators,
and narrowly scoped practice on existing resources. Hands-on study remains
important, but it does not require starting this homelab project. Defer homelab
hardware purchases, Proxmox installation, provisioning automation, and cluster
deployment until the certification completion gate is met.

Two existing computers already run the personal configuration repositories and
provide a way to test desktop changes. Another workstation recovery project is
therefore a lower priority. The useful addition is an environment for practicing
networking, storage, cluster operations, security, troubleshooting, and recovery.

The proposed starting point is one Proxmox server, Terraform-managed Linux VMs,
and a small kubeadm cluster. The eventual hardware assumption is three or more
servers with approximately 32 GB RAM each; CPU, disks, NICs, power use, and actual
availability still need to be checked. There is no hardware purchase commitment.

A successful first version, after certification completion, is a working
practice environment and a few completed exercises. Tools learned during
certification study need not all become permanent personal infrastructure. AWS joins the
homelab when an AWS-specific objective or a useful service calls for it.

The existing [dated study plan](../study-plan/September_24_2026_STUDY_PLAN.md)
remains the reference for certification order and target dates. For this
homelab, the decision recorded on 2026-10-04 takes precedence over suggestions
to build alongside certification study. This note does not edit that historical
plan or require implementation of another, larger project.

### Certification completion gate

Complete the current core roadmap before starting build milestone 0:

- [ ] Terraform Associate 004.
- [ ] Security+ renewal listed in the dated study plan.
- [ ] AWS Solutions Architect Associate.
- [ ] AWS DevOps Engineer Professional.
- [ ] CKA retake listed in the dated study plan.
- [ ] CKS.

The gate covers the currently planned core path. Optional future certifications
are separate decisions; ongoing renewal cycles do not postpone the homelab
indefinitely. After completing the core path, reassess whether the build is
still useful before committing time or money.

## How the certifications fit

| Goal | Practice that matters most during certification study | Later homelab application |
| --- | --- | --- |
| Terraform Associate 004 | Providers, plans, variables, modules, state, imports, drift, lifecycle, and the current HCP Terraform objectives | Apply those skills to VM provisioning after all certifications are complete |
| AWS Solutions Architect Associate | Architecture choices across IAM, networking, compute, storage, databases, resilience, and cost | Apply architecture tradeoffs and add AWS services only when useful |
| AWS DevOps Engineer Professional | Delivery, infrastructure automation, monitoring, incident response, governance, and recovery on AWS | Apply operational habits to delivery and recovery exercises |
| CKS | Host and cluster hardening, workload isolation, supply-chain security, and investigation through course labs and simulators | Retain and deepen security skills on conventional Linux VMs |

Use the official guides to identify gaps and confirm the current exam version
before booking. The lab backlog below is for practice after certification
completion; it is not an exam-preparation requirement or a complete syllabus:

- [Terraform Associate 004 objectives](https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004)
- [AWS SAA exam guide](https://docs.aws.amazon.com/aws-certification/latest/solutions-architect-associate-03/solutions-architect-associate-03.html)
- [AWS DevOps Professional exam guide](https://docs.aws.amazon.com/aws-certification/latest/devops-engineer-professional-02/devops-engineer-professional-02.html)
- [AWS DevOps Professional IaC objectives](https://docs.aws.amazon.com/aws-certification/latest/devops-engineer-professional-02/devops-engineer-professional-02-domain2.html)
- [CKS certification and curriculum entry point](https://training.linuxfoundation.org/certification/certified-kubernetes-security-specialist/)

SAA and DevOps Professional cover considerably more than EKS. Terraform is useful
experience, but DevOps Professional also includes AWS-native tools such as
CloudFormation, CDK, and Systems Manager. Follow the certification order in the
dated study plan and complete the full core path before beginning this build.

## Recommended tools and ownership

These are deferred design recommendations. Recheck them after completing all
planned core certifications, when the homelab becomes an active project.

| Layer | Starting choice | Owns |
| --- | --- | --- |
| Physical infrastructure | Proxmox VE | Hypervisor, VM consoles, host networking, VM disks |
| VM provisioning | Terraform and the community `bpg/proxmox` provider | VM definitions, CPU, RAM, disks, and supported network settings |
| VM initialization | Ubuntu LTS cloud image and cloud-init | Initial accounts, SSH public keys, hostname, and initial configuration |
| Kubernetes bootstrap | kubeadm | Cluster initialization, node enrollment, and supported cluster lifecycle operations |
| Repeated Linux configuration | Small Ansible playbooks when repetition warrants them | Packages, services, runtime configuration, and host settings |
| Application delivery | Flux or Argo CD, once useful | Reconciliation of Kubernetes application configuration from Git |
| Personal desktop configuration | Existing appdots, hyprdots, agentdots, and related repositories | Their existing concerns; the lab does not replace them |

Terraform creates and manages infrastructure resources. Ansible configures an
existing conventional Linux system. Cloud-init handles initialization; it is
not a general replacement for ongoing configuration management.

Begin with cloud-init and a manual kubeadm installation. Capture the procedure,
then automate steps that recur. Ansible need not become another major study
track. Avoid making Terraform a wrapper around a large collection of SSH commands.
Give each setting one owner so cloud-init, Ansible, and GitOps do not fight over it.

Keep Terraform state, kubeconfigs, join credentials, private keys, and backups
outside Git. Protect and back up state separately from the VMs it manages.
Persist intended configuration, provider lockfiles, and procedures in Git. A
future homelab code repository should own infrastructure; wikinotes owns this plan.

References:

- [Proxmox administration guide](https://pve.proxmox.com/pve-docs/pve-admin-guide.html)
- [Community Proxmox Terraform provider and compatibility guidance](https://github.com/bpg/terraform-provider-proxmox)
- [cloud-init overview](https://cloud-init.io/)
- [Ansible getting started](https://docs.ansible.com/projects/ansible/latest/getting_started/index.html)
- [Create a cluster with kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)
- [Flux getting started](https://fluxcd.io/flux/get-started/)
- [Argo CD getting started](https://argo-cd.readthedocs.io/en/stable/getting_started/)

The Proxmox Terraform provider is community maintained. Check compatibility,
pin the provider version, and review upgrades. Use current instructions matching
the selected OS, Kubernetes, runtime, and network-plugin versions.

## Build milestones

All milestones below begin after the certification completion gate is met.
Until then, retain them as a future build reference.

### 0. Decide what the first version must accomplish

- [ ] Confirm that every item in the certification completion gate is complete.
- [ ] Reassess whether a homelab is still useful and review the deferred design.
- [ ] Choose a setup timebox, such as two focused weekend sessions, then reassess.
- [ ] Inventory available CPU, RAM, SSD capacity, NICs, and virtualization support.
- [ ] Pick one operational question the lab should answer first.
- [ ] Choose a location outside the server for configuration and backup recovery.
- [ ] Decide how much ongoing maintenance and electricity are acceptable.

Exit criterion: all planned core certifications are complete, and the first
version is scoped to one host, a small cluster, and a specific learning objective.
Extra hardware can remain powered off.

### 1. Bootstrap one Proxmox host

Installing Proxmox and configuring its initial management network can be a
documented manual bootstrap. Automating that first installation does not need
to be the first project.

Record the installation media version, intended installation disk, management
address or DHCP reservation, hostname, bridge/NIC mapping, DNS, and time source.
Keep credentials in the existing secret-management system. Use local VM storage
initially and arrange a backup destination outside this host.

Choose VM, Pod, and Service address ranges that do not overlap the home LAN or
VPN ranges. Ensure there is console access if a networking experiment breaks SSH.
Keep essential home networking independent of the study cluster.

- [ ] Access the management interface from a trusted local machine.
- [ ] Verify host networking, name resolution, and time synchronization.
- [ ] Create and boot one throwaway VM to check networking and storage.
- [ ] Reboot the host and verify that management access returns as documented.
- [ ] Save a short reinstall procedure without embedding secrets.

Exit criterion: the host reliably runs a VM and can be administered after reboot.

### 2. Provision the first VMs with Terraform

Use an Ubuntu LTS cloud image and cloud-init. A reasonable starting allocation
for a 32 GB host is below; these are planning estimates, not workload guarantees.

| VM | vCPU | RAM | Initial system disk |
| --- | --- | --- | --- |
| Control plane | 2 | 4 GB | 32–40 GB |
| Worker 1 | 2 | 4–8 GB | 40–60 GB |
| Worker 2 | 2 | 4–8 GB | 40–60 GB |

Leave RAM, CPU, and disk headroom for Proxmox, filesystem cache, image downloads,
and experiments. Additional application data requires additional capacity.

- [ ] Record the image source and verify its published checksum.
- [ ] Pin Terraform/provider requirements and commit the dependency lockfile.
- [ ] Declare VM resources with clear names and explicit resource ownership.
- [ ] Keep state protected on the administration machine for the initial solo lab,
      with a separate backup; add a remote backend when it solves a real need.
- [ ] Apply, verify VM connectivity, and confirm that a second plan is unchanged.
- [ ] Recreate a throwaway worker VM without touching the other VMs.

Exit criterion: VM provisioning is repeatable, with no secrets in Git and no
unexpected changes in a subsequent Terraform plan.

### 3. Create a study cluster

Follow the version-matched kubeadm documentation. Configure the container runtime
and node prerequisites, initialize the control plane, and join the workers.
Install one CNI that enforces Kubernetes NetworkPolicy; creating policy objects
alone does not prove traffic is filtered.

If eventual control-plane expansion is intended, configure a stable
`controlPlaneEndpoint` during initial bootstrap and include it in the API server
certificate configuration. Initially it can resolve to the single control-plane
address. Later it needs a suitable load balancer or virtual IP. Adding a stable
endpoint retrospectively is not always a simple node-join operation.

- [ ] All nodes report Ready and cluster DNS works.
- [ ] A small HTTP application is reachable through its Service.
- [ ] An allowed and a denied connection prove NetworkPolicy enforcement.
- [ ] Save the version choices, installation order, and diagnostic commands.
- [ ] Keep normal application workloads on workers.
- [ ] Complete T1, N1, N2, W1, and S1 from the backlog before expanding.

Exit criterion: the cluster supports repeatable exercises. A full monitoring
stack, service mesh, GitOps installation, or distributed storage is not required
to reach this milestone.

### 4. Expand only when the exercise requires it

For physical-host failure practice, install Proxmox on the additional servers.
Central Proxmox cluster management is optional; Terraform can manage hosts
without requiring Proxmox automatic VM failover. If clustering Proxmox, follow
its quorum and networking requirements before testing host outages.

One later topology is:

| Physical host | Control-plane VM | Worker VM |
| --- | --- | --- |
| Server A, approximately 32 GB RAM | CP1, approximately 4 GB | Worker 1, approximately 8 GB |
| Server B, approximately 32 GB RAM | CP2, approximately 4 GB | Worker 2, approximately 8 GB |
| Server C, approximately 32 GB RAM | CP3, approximately 4 GB | Worker 3, approximately 8 GB |

Reserve the remaining capacity for hosts, storage overhead, and later exercises.
Maintain physical-host placement as VMs move. Kubernetes sees VM nodes, so
spreading pods across VM hostnames does not by itself guarantee spreading across
physical servers. Use accurate topology labels and placement constraints when
that distinction matters.

For the initial HA design, kubeadm's stacked-etcd topology avoids adding a
separate etcd tier. Three healthy etcd members can retain quorum after losing
one member. The API endpoint must also survive that failure; DNS pointing only
at CP1 does not provide endpoint failover.

Control-plane availability, Proxmox VM availability, application availability,
and storage availability are separate properties. Three control planes do not
make a local data volume accessible on a different host.

Reference: [kubeadm high availability guide](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/high-availability/).

### 5. Add storage and services deliberately

Start with local VM disks and application-aware backups to a separate location.
Use explicit local persistent volumes or a chosen local provisioner when needed;
kubeadm alone does not install a general-purpose dynamic storage system.

Learn the failure behavior of local storage before adopting distributed storage.
A single NAS can make storage accessible to multiple nodes while still being a
single point of failure. Replication and snapshots are not substitutes for a
recoverable backup, and a VM snapshot of a running database may not be
application-consistent.

Add distributed storage only when a workload or a storage-learning objective
justifies the disks, networking, monitoring, and recovery work. Perform a restore
exercise before moving irreplaceable personal data into the lab.

Reference: [Kubernetes persistent volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/).

## Ubuntu and kubeadm or Talos

After certification completion, Ubuntu and kubeadm are the starting
recommendation for a cluster used to retain and deepen security skills.
They expose the Linux services, runtime configuration, static pod manifests,
certificates, logs, and host controls that are useful to inspect and change.
This is a continuing-practice recommendation; building this cluster is not part
of the certification preparation plan.

Talos is worth revisiting when the main objective becomes maintaining personal
services with a declarative operating system. It uses an API rather than SSH,
a shell, or a conventional package manager. Its operating model changes many
host-administration exercises. Kubernetes workload-level lessons still transfer.

Proxmox leaves room to use either as a VM guest. A separate Talos service cluster
can be considered later; operating both is not a first-version requirement.

References: [Talos overview](https://www.siderolabs.com/talos-linux) and
[Talos Terraform provider](https://github.com/siderolabs/terraform-provider-talos).

## Exercise backlog

After all planned core certifications are complete and the homelab is running,
choose one exercise per session. Check it off after demonstrating its success
criterion and writing a short explanation of what happened. These are optional
experiments for continued practice, not certification prerequisites or thirty
requirements for calling the lab useful.

Use synthetic data and intentionally limited test workloads. Before a disruptive
exercise, record the target cluster and recovery method. Control-plane restore,
host outage, and security experiments belong in the study environment. Start
with benign test events; malware is unnecessary.

### Terraform and provisioning

- [ ] **T1 — Resource lifecycle.** Create a worker VM, change its resources, and
  replace only that disposable VM. Read the plan before each action.
  **Success:** explain which changes update in place and which replace resources;
  the remaining infrastructure stays intact and the final plan is unchanged.
- [ ] **T2 — Drift detection.** Change a supported VM property in Proxmox, inspect
  the next Terraform plan, then either restore the declared intent or deliberately
  adopt the change in configuration. **Success:** explain why refreshing state
  alone does not update configuration or settle the intended value.
- [ ] **T3 — Import and refactoring.** Import a manually created throwaway VM,
  then move its resource into a small module using an explicit moved block.
  **Success:** the VM is managed under the new address without recreation and
  the subsequent plan is unchanged. Work only with the lab's resources/state.
- [ ] **T4 — State recovery.** Back up state and rehearse restoring it for an
  isolated test configuration. Add locking if experimenting with a backend that
  supports it. **Success:** recover the resource mapping without duplicating
  infrastructure; explain why `sensitive` output redaction is not encryption.

Reference: [Terraform state documentation](https://developer.hashicorp.com/terraform/language/state).

### Networking and service access

- [ ] **N1 — Broken dependency.** Deploy a frontend and backend; introduce a wrong
  Service selector or target port. Check DNS, EndpointSlices, readiness, and
  connectivity in sequence. **Success:** find the actual broken layer and fix it
  without deleting and reinstalling the application.
- [ ] **N2 — Namespace isolation.** Apply default-deny ingress and egress policies,
  then allow the intended frontend-to-backend flow and required DNS traffic.
  **Success:** a small source/destination matrix proves both allowed and denied
  paths using a CNI that actually enforces the policies.
- [ ] **N3 — DNS and egress.** Break DNS permissions or upstream access for a test
  workload. Distinguish a name-resolution failure from a TCP connection failure.
  **Success:** restore only the required paths and explain the policy difference
  between allowing DNS queries and allowing connections to the resolved address.
- [ ] **N4 — HTTP routing and TLS.** Add one maintained Gateway API implementation
  when ready, route two sample services, and use a locally trusted test certificate.
  **Success:** hostname, route, certificate trust, and backend selection are
  correct; a deliberately wrong hostname or untrusted certificate fails as expected.
- [ ] **N5 — Host versus pod networking.** On disposable nodes, reproduce a
  controlled firewall or MTU mismatch. Compare node-to-node and pod-to-pod paths.
  **Success:** identify the failing boundary with bounded probes or packet capture,
  restore it, and avoid capturing unrelated household traffic.

References: [debug Services](https://kubernetes.io/docs/tasks/debug/debug-application/debug-service/),
[NetworkPolicy](https://kubernetes.io/docs/concepts/services-networking/network-policies/),
and [Gateway API](https://gateway-api.sigs.k8s.io/).

### Workload operations and upgrades

- [ ] **W1 — Probes and failure behavior.** Make an application start slowly and
  temporarily reject requests. Compare startup, readiness, and liveness probes.
  **Success:** readiness removes an unavailable backend from normal Service
  traffic, while liveness restarts only the failure condition it is meant to detect.
- [ ] **W2 — Resource pressure.** Give a bounded test workload insufficient memory
  or CPU and observe OOM termination, throttling, or Pending scheduling states.
  **Success:** distinguish those causes and set requests/limits from evidence
  without exhausting the host or starving control-plane components.
- [ ] **W3 — Failed rollout and recovery.** Deploy two versions, make the second
  fail readiness, and recover using the chosen delivery mechanism. **Success:**
  explain rollout status and measured request failures, and leave Git and the
  live deployment aligned. Application rollback does not undo database migrations.
- [ ] **W4 — Drain and disruption budgets.** Run multiple replicas with suitable
  placement, add a PodDisruptionBudget, and drain a worker. **Success:** explain
  a blocked drain, complete planned maintenance with spare capacity, and show
  why the budget does not prevent an involuntary hardware outage.
- [ ] **W5 — Kubernetes upgrade.** Follow a supported minor-version upgrade path,
  checking version skew, CNI compatibility, backups, and kubeadm's sequence.
  **Success:** measure API and application availability through the upgrade,
  verify nodes and workloads afterward, and document a recovery plan rather than
  assuming an unsupported Kubernetes downgrade will work.

References: [container probes](https://kubernetes.io/docs/concepts/workloads/pods/probes/),
[disruption budgets](https://kubernetes.io/docs/tasks/run-application/configure-pdb/),
and [kubeadm upgrades](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/).

### Storage, backup, and recovery

- [ ] **D1 — What actually persists.** Write test data to `emptyDir` and to a PVC,
  then recreate the pods. Test the PVC's real node constraints. **Success:**
  distinguish container restart, pod replacement, node loss, and disk loss;
  identify which events the chosen storage survives.
- [ ] **D2 — Reclaim policy.** Compare Retain and Delete using disposable data and
  a storage implementation that supports the intended behavior. **Success:**
  predict what happens to the PVC, PV, and underlying data, then verify it instead
  of assuming PVC deletion always removes or always preserves data.
- [ ] **D3 — Application restore.** Back up a test database using an appropriate
  application-consistent method and restore it into a fresh namespace or cluster.
  **Success:** the application reads known records/checksums; record recovery
  duration and the gap between the newest restored data and the last write.
- [ ] **D4 — Control-plane recovery.** Take an etcd snapshot and follow the
  version-matched recovery procedure in an isolated practice environment. Preserve
  the other required configuration, certificates, and encryption keys securely.
  **Success:** recover known Kubernetes objects and explain why an etcd snapshot
  does not back up application data stored on persistent volumes.

Reference: [operating and recovering etcd for Kubernetes](https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/).

### Security practice after CKS

- [ ] **S1 — Least-privilege RBAC.** Create a service account that can inspect
  selected resources in one namespace. **Success:** positive and negative
  `kubectl auth can-i` checks and actual API requests agree; access to Secrets
  and unrelated namespaces is denied unless intentionally granted.
- [ ] **S2 — Pod Security Admission.** Move a test namespace from audit/warn to
  enforcement of an appropriate Pod Security level. **Success:** an intentionally
  noncompliant new workload is rejected and its corrected version runs; existing
  pods are checked separately rather than assumed to be retroactively evicted.
- [ ] **S3 — Host and container controls.** Apply non-root execution, dropped
  capabilities, a read-only root filesystem, and supported seccomp/AppArmor
  controls to a test app. **Success:** the app still performs its intended work,
  a chosen forbidden operation fails, and the denial can be explained from evidence.
- [ ] **S4 — Secret handling.** Practice delivery and rotation of dummy secrets,
  then separately configure API-server encryption at rest using the official
  procedure. **Success:** consumers use the rotated value, no plaintext secret
  enters Git, and previously stored data is rewritten and verified as needed.
  Explain the different roles of base64, RBAC, transport encryption, and at-rest encryption.
- [ ] **S5 — Image supply chain.** Build a small image, produce an SBOM, scan it,
  pin its digest, and optionally sign/verify it with Cosign. **Success:** explain
  the findings, update a vulnerable dependency, and reject an unexpected digest
  or signing identity in an explicit verification step. Signing alone is not admission enforcement.
- [ ] **S6 — Audit and runtime investigation.** Enable scoped Kubernetes audit
  logging and optionally a runtime detector; generate a benign test action such
  as a shell in a disposable container. **Success:** attribute the API action to
  its identity, correlate available runtime evidence, and write a short incident
  timeline. Configure logging to avoid recording secret request bodies.

References: [RBAC](https://kubernetes.io/docs/reference/access-authn-authz/rbac/),
[Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/),
[security contexts](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/),
[encryption at rest](https://kubernetes.io/docs/tasks/administer-cluster/encrypt-data/),
[Cosign](https://github.com/sigstore/cosign),
[Kubernetes auditing](https://kubernetes.io/docs/tasks/debug/debug-cluster/audit/),
and [Falco documentation](https://falco.org/docs/).

### Delivery and observability

- [ ] **G1 — GitOps reconciliation.** Install Flux or Argo CD and manage one test
  application. Introduce a live configuration change. **Success:** observe drift,
  demonstrate the configured reconciliation behavior, and revert a bad Git change
  through Git. Terraform and GitOps do not own the same Kubernetes objects.
- [ ] **G2 — Useful pipeline gates.** Add formatting, validation, manifest checks,
  and a relevant image or configuration scan to a lab repository. **Success:**
  a known bad change fails for the intended reason and a corrected change passes;
  untrusted pull requests cannot obtain deployment credentials.
- [ ] **G3 — Alert with an action.** Add a small monitoring setup and one alert for
  a user-visible failure. Cause that failure in a test app. **Success:** the alert
  fires, identifies an actionable symptom, links to a short runbook, and resolves
  after recovery. Measure the signal rather than collecting dashboards by default.

### Physical-host failures and expansion

These exercises need multiple physical hosts, spare capacity, and recoverable
test data. They are not first-host acceptance criteria.

- [ ] **H1 — Lose one host.** With three healthy control-plane/etcd members on
  separate hosts, stop one physical host and watch recovery. **Success:** quorum
  and API access remain available through the configured endpoint; record actual
  application interruption and any local-volume workloads that cannot recover.
- [ ] **H2 — Lose the API endpoint owner.** Stop the active endpoint/load-balancer
  instance in the practice setup. **Success:** clients keep using the same address
  after failover, without editing kubeconfigs. Identify shared switch, power, or
  routing dependencies that remain outside this test's protection.
- [ ] **H3 — Replace a worker.** Drain and remove a disposable worker, provision
  its replacement, join it, and restore required labels/taints. **Success:** normal
  scheduling resumes and old node membership is cleaned up. Explicitly account
  for local data before replacement; worker replacement is not an etcd-member
  replacement procedure.

## AWS and EKS later

The exercises in this section are deferred homelab extensions, to consider
after all planned core certifications are complete. AWS course labs and focused
exam practice can still be used during certification study without starting
this homelab project.

AWS is not needed to run this local lab. Add it for an AWS-specific learning
objective or a useful service such as off-site object storage. DNS does not
require Route 53, though Route 53 may become a deliberate learning choice.

The purpose of an AWS session is to answer an operational question. Provisioning
and cleanup support that session; building an elaborate teardown framework is
not the main project. Use synthetic data, estimate the complete configuration,
and verify cleanup at the end. Budget alerts are delayed notifications, not a
guaranteed spending cap. Recheck pricing before each new design.

- [ ] **A1 — Pod identity and S3.** Give one EKS workload access to one test S3
  prefix through Pod Identity, then remove a required permission. **Success:**
  explain identity association, trust, and permissions; intended requests succeed
  and unrelated requests fail without embedding static credentials in the image.
- [ ] **A2 — EKS networking.** Trace pod access to another workload and to an AWS
  dependency. Examine the VPC CNI, routing, security groups, DNS, and address
  availability. **Success:** diagnose a controlled failure and explain which
  parts a local cluster could not reproduce faithfully.
- [ ] **A3 — AWS delivery and incident response.** Use an AWS-native deployment
  or CloudFormation exercise from the study material, add an actionable alarm,
  and trigger a controlled failure. **Success:** follow events and logs to the
  cause, recover the service, and explain the IAM boundaries and rollback behavior.
- [ ] **A4 — EKS persistent storage.** Provision disposable EBS-backed storage
  through the supported CSI setup and test scheduling, backup, and restoration.
  **Success:** explain volume Availability Zone constraints, restore known data,
  and identify disks or snapshots retained after workload deletion.

References: [EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/what-is-eks.html),
[EKS Pod Identity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html),
[EKS pricing](https://aws.amazon.com/eks/pricing/),
[AWS Budgets behavior](https://docs.aws.amazon.com/cost-management/latest/userguide/budgets-best-practices.html),
and [EKS deletion procedure](https://docs.aws.amazon.com/eks/latest/userguide/delete-cluster.html).

## When to host personal services

Consider hosting services as part of the homelab only after completing the
certification path and deciding to pursue the build.

Choose a service because it solves an inconvenience already experienced. Possible
categories include document search, photo backup, shared files, media, or home
automation. Trying the application and deciding whether it is useful comes
before committing to its storage and availability architecture.

Before making a service part of daily life:

- [ ] Use it often enough to justify its maintenance.
- [ ] Prove an application-data restore and document its required credentials.
- [ ] Choose a tolerable outage and data-loss window.
- [ ] Provide reliable local access; add remote access only when needed.
- [ ] Separate routine service operation from destructive study exercises.
- [ ] Keep backup recovery possible while the cluster is unavailable.

Kubernetes is a reasonable deliberate learning choice for services, even when
some applications could run more simply. It does not need to host the hypervisor,
home router, recovery credentials, or the only copy of its own backups.

## Keeping the project manageable

Keep the project deferred throughout the current core certification path. Once
that path is complete and the build begins, finish the first cluster before
adding more platforms. Start with basic diagnostic tools; add GitOps, monitoring,
policy tools, and storage components when a chosen exercise needs them. One
implementation of each is enough.

Measure the lab's value in problems understood and tasks made easier. If setup
or maintenance exceeds the time budget after the build begins, stop expanding
and use the working environment as it stands. A lab that is powered off between
practice sessions can still be successful.

Keep the system replaceable: record versions, separate infrastructure from
application configuration, retain ordinary data exports/backups, and test
upgrades before adopting them. Expect some compatibility work over time. The
goal is to limit the cost of change, not to eliminate all future maintenance.

This is a dated plan. Recheck current product support, exam objectives, provider
compatibility, and version-specific instructions before implementation. Links
were checked when the note was prepared; upstream documentation can move.

## Session record

Copy this template into a private exercise note. Keep reusable, sanitized lessons
as separate wiki references when ready; this project plan stays in `notes/`.

```text
Date: YYYY-MM-DD
Exercise ID and question:
Cluster/context and versions:
Starting state and recovery method:
Expected behavior:
Change or fault introduced:
Evidence collected:
Actual behavior and explanation:
Fix and verification:
Cleanup completed:
What I can now explain or do at work:
Next question:
```

Record evidence rather than credentials or raw sensitive logs. Keep the session
small enough that documenting and cleaning it up is part of finishing it.

## Next actions

1. Complete Terraform Associate 004 preparation and the exam.
2. Complete the planned Security+ renewal, AWS Solutions Architect Associate,
   AWS DevOps Engineer Professional, CKA retake, and CKS in the order and windows
   maintained in the dated study plan. Use course labs and exam simulators as
   needed; keep the homelab build deferred.
3. Confirm that all items in the certification completion gate are complete.
4. Only then revisit this document, recheck the tool recommendations, and decide
   whether the homelab still merits the time and cost.
5. If proceeding, complete milestones 0–3 with one host and assess value before
   expanding. Work through T1, N1, N2, W1, and S1 as initial exercises.
6. Add physical hosts, personal services, Talos, or AWS integrations only when a
   concrete need or further learning objective justifies them.
