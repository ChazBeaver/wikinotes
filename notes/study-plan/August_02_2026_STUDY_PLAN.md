# Roadmap: Job Security on AWS + Kubernetes + Terraform

**Priority:** Stay employable and secure at my level (~$175K), on my stack. Get rehired fast if needed.
**Focus:** AWS, EKS, K8s, Terraform. Harden depth — don't stretch thin.
**My weak spots to fix:** Terraform and AWS. Certs + daily reps target exactly these.
**Good news:** Work is migrating Rancher → EKS, which sharpens my target stack on the job.

---

## What Actually Protects My Career (non-cert — keep these alive)

- **Clearance is my #1 security asset.** Stay in cleared work; never let it go inactive. Confirm reactivation window with an FSO. This is what makes rehiring fast.
- **Keep Security+ active** — DoD 8140 job requirement. Maintain via CEUs; do not let it lapse. Biggest self-inflicted risk if ignored.
- **Keep EKS/AWS sharp** with a home lab on **EKS specifically** (until the work migration lands). Don't let Rancher erode my target stack.
- **Passive presence on LinkedIn + ClearanceJobs**, even when happy. Cleared recruiters hunt this exact profile — this is the "rehired fast" lever.
- **Keep primes and former colleagues warm.** GovCon rehires happen through people, not applications.
- **Small public GitHub** — a couple of clean automation repos. Proof of work.
- **Python/AI = relevance insurance only.** Light, secondary, don't let it compete with the core.

---

## What's Actually in Demand (deepen these AT WORK, alongside AWS + K8s + Terraform)

My core stack (AWS, EKS, K8s, Terraform) is the foundation — keep it deep and current on the job. The field's real shift is from *operating* infrastructure to *building the secure, self-service platform* others operate on (golden paths, paved roads, guardrails baked in). That's the platform-builder premium, and it's mostly a reframing of what I already do. Focus areas, in order of leverage for me:

- **Supply-chain security is now a hard requirement, not a bonus** — SBOMs, image signing and provenance, policy-as-code. I already live this through Iron Bank and Big Bang. One of the hottest areas in the field, and I'm already inside it — I just don't name it as a headline strength. **Fix that: make it a headline.**
- **GitOps** (ArgoCD/Flux) — no longer hype because it *won*; it's now table-stakes for platform/DevSecOps, and not having it reads as a gap. Declarative, Git-as-source-of-truth delivery with a full audit trail is exactly what regulated/DoD/cATO work wants, and it's the backbone of paved-road platform building. I already run it — another strength I under-name.
- **Policy-as-code** (OPA/Gatekeeper, Kyverno) — the engine behind "secure by default," and close to my compliance work.
- **Observability** has standardized on OpenTelemetry; the rising edge is **eBPF** (Cilium, Falco). Worth literacy, not obsession.
- **AI workloads on infrastructure** (GPU scheduling, inference on K8s) — the fastest-growing *new* demand. My relevance insurance, kept light.
- **FinOps / cost awareness** — increasingly expected at senior level, cheap to pick up.

**My three highest-ROI moves:** (1) deepen AWS + Terraform to real fluency, (2) reframe my security/compliance work as *supply-chain-security* expertise (exactly what's hot), (3) reach real fluency in one language (Python). Deepen and rename — don't chase new tools.

---

## Certifications — Priority Order

Pace: ~5–6 hrs/week. Method for all: course once → grind practice exams → review every miss → book at 85%+.

### 1. Terraform Associate (004)
**Hours:** 15–20 · **Weeks:** 3–4
Fixes a weak spot, validates daily work, common contract requirement. Fastest win.
- HashiCorp official **Terraform Associate 004 Learning Path + Sample Questions** (free anchor)
- **Bryan Krausen** — Terraform Associate course (Udemy)
- **Bryan Krausen** — Terraform Associate practice exams (Udemy)

### 2. AWS Solutions Architect Associate (SAA)
**Hours:** 60–80 · **Weeks:** 10–13
My broad, liquid AWS anchor — passes the most screens and directly attacks my AWS weak spot.
- **Stephane Maarek** — Ultimate AWS Certified Solutions Architect Associate (Udemy)
- **Tutorials Dojo (Jon Bonso)** — SAA practice exams
- **Adrian Cantrill** — SAA course (deeper understanding, project-based)

### 3. AWS SysOps Administrator Associate — *optional bridge*
**Hours:** 50–70 · **Weeks:** 9–12
Adds an operations labor category and de-risks DevOps Pro. Skip if I want to move faster.
- **Stephane Maarek** — SysOps Administrator Associate (Udemy)
- **Tutorials Dojo** — SysOps practice exams
- **Adrian Cantrill** — SysOps course

### 4. AWS DevOps Engineer Professional
**Hours:** 70–90 · **Weeks:** 12–15
Senior labor category that matches my actual work; strongest AWS credential for staffing/security.
- **Stephane Maarek** — AWS Certified DevOps Engineer Professional (Udemy)
- **Tutorials Dojo** — DevOps Pro practice exams
- **Hands-on labs**: CodePipeline / CodeBuild / CodeDeploy + multi-account (Organizations, Control Tower)

### 5. CKS (Certified Kubernetes Security Specialist)
**Hours:** 60–90 · **Weeks:** 10–15
K8s security maps to security labor categories; reinstates my lapsed CKA in one exam (CARE — confirm at registration). Rebuild `kubectl` speed first; the 2-hr live-cluster clock is the hard part.
- **KodeKloud CKS** (Mumshad Mannambeth) + CKS challenges
- **Kim Wüstkamp** — Kubernetes CKS course (Udemy)
- **killer.sh** CKS simulator (2 free sessions with exam registration — treat as real dry runs)

### Optional later — Terraform Pro (Authoring & Operations)
Lowest job-security ROI of the set. Only if I want recognition as a Terraform authority.
- HashiCorp official **Pro Learning Path + Practice Labs** (free, AWS-provider based)
- **Bryan Krausen** — Terraform Pro material
- Author real modules; drill `import`, drift, `moved` blocks

---

## Totals

| | |
|---|---|
| Core ladder (1,2,4,5) | ~205–280 hrs · ~9–12 months |
| With SysOps bridge (3) | ~255–350 hrs · ~11–15 months |

---

## Renewal Cheat Sheet

| Cert | Valid | Notes |
|---|---|---|
| Security+ | 3 yrs | Keep active — 8140 requirement. CEUs, no re-exam needed. |
| Terraform (Assoc/Pro) | 2 yrs | No cascade — renew each independently. |
| AWS (SAA/SysOps/DevOps Pro) | 3 yrs | Passing a Pro renews **still-active** associates on the same path. DevOps Pro covers SysOps, not SAA. Skill Builder "Maintain" extends 1 yr, no exam. |
| CKS | 2 yrs | Cascades — renews CKA/KCSA/KCNA via CARE. |

**Minimum maintenance:** keep Security+ active; retake DevOps Pro and CKS on cycle. Let SAA / Terraform Associate lapse only if I've moved past them.

---

## Bottom Line

A cleared senior platform engineer with AWS + EKS + K8s + Terraform at my pay band is in one of the most durable positions in tech. My risk is low. This roadmap hardens an already-strong position — it doesn't patch a weakness. The only two things that would actually threaten me (letting the clearance go inactive, or letting Security+ lapse) are fully in my control.
