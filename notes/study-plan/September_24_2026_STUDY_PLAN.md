# Roadmap: Job Security on AWS + Kubernetes + Terraform (September 2026 revision)

**Date:** 2026-09-24
**Supersedes:** `August_02_2026_STUDY_PLAN.md`
**Priority:** Stay employable and secure at my level, on my stack. Get rehired fast if needed.
**Focus:** Close the two weak spots first (Terraform, AWS). Kubernetes is a strength and its certs go last.
**Pace:** 4 to 6 hours per week total, including the personal build project. One exam every 4 to 6 months. A life outside of studying is a requirement, not a nice-to-have.
**Companion document:** `notes/projects/agentic-remediation-platform-build-plan.md`. Every cert below has a matching build phase so the study and the project reinforce each other.

---

## What changed since the August plan

Facts verified on 2026-09-24. Each one changes the order or the method.

| Item | August plan said | Verified reality | Effect |
|---|---|---|---|
| CKA status | "lapsed" | Expired **June 27, 2026** (3-year validity for certs earned before April 1, 2024) | Must be retaken. Resume lists it as current and needs a date or removal now |
| PCA status | Not mentioned | Expired **July 27, 2026** (24-month validity) | Drop from resume. Not worth renewing |
| CKAD status | Not mentioned | Valid until **March 30, 2027** | Let it lapse. CKA plus CKS is the stronger pair |
| CKS and CKA | "CKS reinstates my lapsed CKA in one exam" | **Wrong.** CKS registration requires an active, unexpired CKA on exam day. CARE extends a still-valid CKA when you pass CKS; it does not revive an expired one | CKA retake must precede CKS |
| Security+ | "CEUs, no re-exam" | Expires **February 27, 2027**. CertMaster CE course renews it outright and includes the CE fee | Use CertMaster CE. Do not re-study for the exam |
| Terraform Associate | 003 | **004** is current since January 8, 2026, tests Terraform 1.12 | Study the 004 content list |
| AWS SysOps | "optional bridge" | Retired September 29, 2025, replaced by **CloudOps Engineer Associate** | Dropped. DevOps Pro has no prerequisite |
| Kubernetes cert order | CKS after DevOps Pro | Decision on 2026-09-24: **all Kubernetes certs last** | CKA and CKS move to 2028 |

---

## What Actually Protects My Career (non-cert, unchanged from August)

- **Clearance is my number one asset.** Stay in cleared work. Confirm the reactivation window with an FSO.
- **Keep Security+ active.** DoD 8140 requirement. Biggest self-inflicted risk if ignored. Hard date: February 27, 2027.
- **Keep EKS and AWS sharp** through the build project, not just courses.
- **Passive presence on LinkedIn and ClearanceJobs.**
- **Keep primes and former colleagues warm.**
- **A public GitHub with one serious repo.** The build project is that repo.
- **Reframe my compliance work as supply-chain security** on the resume. Iron Bank, image signing, SBOMs, policy-as-code. It is what I already do and it is what is in demand.

---

## The Ladder, Chronologically

| # | Cert | Study window | Exam target | Hours | Hrs/week | Build phase it pairs with |
|---|---|---|---|---|---|---|
| 1 | Terraform Associate 004 | Sep 23 to Nov 15, 2026 | Week of **Nov 16, 2026** | 45 to 55 | 6 | Phase 0: Terraform foundation |
| 2 | Security+ renewal (CertMaster CE) | Dec 2026 to Jan 2027 | Complete by **Jan 31, 2027** (deadline Feb 27) | 10 to 15 | 2 to 3 | Phase 1: cluster baseline |
| 3 | AWS Solutions Architect Associate | Feb to May 2027 | **May 2027** | 60 to 80 | 5 | Phase 2: tickets and first agent |
| break | No exam | Jun to Jul 2027 | none | 0 | project only | Phase 3: the loop closes |
| 4 | AWS DevOps Engineer Professional | Aug 2027 to Jan 2028 | **Jan or Feb 2028** | 70 to 90 | 4 to 5 | Phase 4: in-cluster agents and tenancy |
| 5 | CKA (retake, refreshed curriculum) | Mar to Apr 2028 | **Apr 2028** | 30 to 40 | 4 | Phase 5: hardening |
| 6 | CKS | Jun to Sep 2028 | **Sep 2028** | 60 to 80 | 5 | Phase 5: hardening |
| opt | Terraform Pro, or AWS Security Specialty | 2029, only if the role calls for it | | 80+ | | |

**Why this order:** the two weak spots come first while the strong skill coasts. Kubernetes is used daily at work and will not decay. CKA and CKS in 2028 are renewals and depth, not gap-closing. The June to July 2027 break is deliberate: two AWS exams back to back with no gap is how burnout happens.

**Why no SAA-to-DevOps-Pro bridge:** DevOps Pro has no prerequisite. Take a DevOps Pro practice exam cold at the start of the window. Above roughly 55 percent, go straight at it. Below that, use SAA course material as review without paying for another exam.

---

## 1. Terraform Associate 004

**Hours:** 45 to 55 · **Weeks:** 8 · **Pace:** 6 per week, three 2-hour sessions
**Exam:** 57 questions, 1 hour, online proctored, $70.50, tests Terraform 1.12. Valid 2 years.
**Gap being closed:** a year of passive Terraform use next to Terragrunt. The exam loves what work rarely touches: HCP Terraform, state surgery, newer language features, and knowing what Terragrunt does for me versus what Terraform does.

**Method:** every session has a terminal open for at least 30 minutes. Write the build project's Terraform modules by hand as each topic comes up. Do not let an AI assistant write them; use it to explain plan output and review.

| Week | Dates | Focus |
|---|---|---|
| 1 | Sep 23 to 27 | Read the official 004 exam content list. One practice exam cold to find gaps. Personal AWS account, billing alarm, free HCP Terraform org |
| 2 | Sep 28 to Oct 4 | IaC concepts and core basics: providers, `required_providers`, version constraints, aliases, resources, data sources, init/validate/plan/apply/destroy, fmt |
| 3 | Oct 5 to 11 | Language: variable types and validation, locals, outputs, functions, count vs for_each, dynamic blocks, depends_on, every lifecycle argument, preconditions and postconditions, check blocks |
| 4 | Oct 12 to 18 | State: backends, S3 with `use_lockfile`, every `terraform state` subcommand, import blocks vs CLI import, moved and removed blocks, `-replace`, sensitive values, ephemeral values and write-only arguments, CLI workspaces |
| 5 | Oct 19 to 25 | Modules: sources, versioning, composition, registry conventions, `terraform test`. List what Terragrunt does at work and confirm how plain Terraform handles each |
| 6 | Oct 26 to Nov 1 | HCP Terraform: projects vs workspaces, CLI-driven vs VCS-driven runs, variable sets, Sentinel and OPA, run tasks, private registry, agents, teams. Hands-on in the free org. Likely the largest gap |
| 7 | Nov 2 to 8 | Debugging and edge cases: TF_LOG, console, graph, CLI config, plugin cache and provider mirrors, variable precedence. Full practice exam, review every miss |
| 8 | Nov 9 to 15 | Three more full practice exams on fresh sets. Ready at 85 percent or higher consistently, able to explain why each wrong option is wrong |
| 9 | Nov 16 to 22 | Exam. Light review only. Buffer through Nov 30 for a retake |

**Resources:**
- HashiCorp official 004 learning path, exam content list, and sample questions (free, primary)
- Bryan Krausen practice exams updated for 004 (Udemy)
- HashiCorp HCP Terraform tutorials (free tier)
- No dumps

---

## 2. Security+ Renewal via CertMaster CE

**Hours:** 10 to 15 · **Window:** December 2026 to January 2027 · **Hard deadline:** February 27, 2027
**Method:** buy and complete the CompTIA CertMaster CE Security+ course. It renews the cert on completion and includes the CE fee. No exam.
**Before starting:** log in to the CompTIA account and check for unpaid annual CE fees. Confirm the cert shows as active.
**Do not:** re-study for the SY0 exam. It is the worst use of hours on this list.
**Note:** Linux Foundation is on CompTIA's approved non-CompTIA vendor list, so a future CKA or CKS might count as CEUs for the next cycle. Do not rely on it for this cycle.

---

## 3. AWS Solutions Architect Associate

**Hours:** 60 to 80 · **Weeks:** 13 · **Pace:** 5 per week
**Gap being closed:** breadth. Years inside EKS on GovCloud means I know the services the platform touches and not much beyond them. SAA is VPC design, IAM edge cases, storage classes, database choices, and the tradeoffs between them.
**Method:** Adrian Cantrill's course over a fast-track one. It is longer, hands-on, and the point is understanding, not the badge. Every SAA topic that maps to a Terraform resource gets written by hand in the build project repo.
**Resources:**
- Adrian Cantrill SAA course (primary)
- Tutorials Dojo (Jon Bonso) SAA practice exams
- Stephane Maarek SAA (Udemy) as a faster second pass if needed
**Book at:** 85 percent or higher on Tutorials Dojo sets.

---

## Break: June to July 2027

No exam study. Build project only, Phase 3. This is where the loop closes end to end. Treat it as the reward for two exams in a row.

---

## 4. AWS DevOps Engineer Professional

**Hours:** 70 to 90 · **Weeks:** 20, at a lighter pace · **Pace:** 4 to 5 per week
**Why it matters:** senior labor category that matches my actual work. Recognized in every sector. 3-year validity is the longest on this list.
**Method:** practice exam cold first to decide whether SAA review is needed. Then the course, then practice exams, with the build project's multi-environment promotion flow and PR preview namespaces as the hands-on lab.
**Resources:**
- Stephane Maarek DevOps Pro (Udemy)
- Tutorials Dojo DevOps Pro practice exams
- Hands-on: CodePipeline, CodeBuild, CodeDeploy, Organizations, multi-account patterns
**Book at:** 80 percent or higher on Tutorials Dojo sets. The 3-hour, 75-question format is the hard part; do at least two full-length timed sets.

---

## 5. CKA Retake

**Hours:** 30 to 40 · **Weeks:** 8 · **Pace:** 4 per week
**Why now and not earlier:** decision to put Kubernetes certs last. It is a renewal, not gap-closing. It is required before CKS and fixes the resume line.
**Curriculum note:** the exam was refreshed in early 2025. Gateway API, Helm, Kustomize, CRDs, and operators are in scope. Rebuild `kubectl` speed under the clock.
**Resources:**
- KodeKloud CKA (Mumshad Mannambeth) for the refreshed objectives
- killer.sh CKA simulator, two sessions included with registration, treated as real dry runs
**Valid:** 2 years, so until April 2030. Passing CKS in September 2028 extends it to match CKS.

---

## 6. CKS

**Hours:** 60 to 80 · **Weeks:** 14 · **Pace:** 5 per week
**Prerequisite:** active CKA on exam day. Enforced at registration.
**Why it matters most of the Kubernetes certs:** it is the closest cert to my actual job. Cluster hardening, supply chain, admission control, mTLS, network policy, runtime security. It is hands-on and rare. Phase 5 of the build project is CKS material applied.
**Resources:**
- KodeKloud CKS plus challenges
- Kim Wüstkamp CKS course (Udemy)
- killer.sh CKS simulator, two sessions with registration
**Renewal effect:** passing CKS extends CKA to the CKS expiry. One exam every 2 years keeps both alive.

---

## Optional, 2029 or later

- **Terraform Authoring and Operations Professional.** 4-hour lab exam, AWS-based, $295. Lowest job-security return of the set. Reconsider only if, after SAA and the build project, Terraform has become the thing I want to be known for. Then it is a legitimate capstone since it is my two former weak spots combined.
- **AWS Security Specialty.** Fits the cATO and DoD niche better than CloudOps Engineer Associate. Only if a fourth AWS cert is wanted.
- **CISSP.** Not on this path. Mentioned only because if I ever drift toward security-titled DoD roles, it opens more contract doors than everything above combined.

---

## Totals

| | |
|---|---|
| Core ladder (1 through 6) | 275 to 360 hours over about 24 months |
| Average pace | 3 to 4 hours per week of study, leaving room for the build project |
| Exams | 5, plus one course-based renewal |

---

## Renewal Cheat Sheet (corrected)

| Cert | Valid | Notes |
|---|---|---|
| Security+ | 3 yrs | Keep active, 8140 requirement. CertMaster CE every cycle, no exam |
| Terraform Associate | 2 yrs | $70 and 1 hour to renew. Renew once, then decide if it still earns its place |
| AWS SAA, DevOps Pro | 3 yrs | Longest validity on the list. Skill Builder "Maintain" can extend without an exam |
| CKA | 2 yrs | Extended automatically when CKS is passed while CKA is still active |
| CKS | 2 yrs | The one Kubernetes exam to retake on cycle. Keeps CKA alive with it |
| CKAD | expires Mar 30, 2027 | Let lapse |
| PCA | expired Jul 27, 2026 | Drop |
| AZ-900 | never expires | Leave on resume |

**Steady state after 2028:** CKS every 2 years, DevOps Pro every 3, CertMaster CE every 3, Terraform Associate every 2 or let it go. About one exam per year at roughly 40 hours of prep.

---

## Resume Actions (do now, not later)

1. Add dates to every certification.
2. Remove PCA. Mark CKA as "renewal scheduled 2028" or remove it until it is retaken. An expired cert listed as current can surface during a pre-award qualification check in cleared contracting.
3. Add "supply-chain security" language to the summary and skills: image signing, SBOMs, hardened base images, policy-as-code.
4. Once Phase 2 of the build project is public, add it to the projects section with the metrics it produces.

---

## Bottom Line

The order changed, the facts got corrected, and the pace got slower on purpose. A cleared senior platform engineer with AWS, EKS, and Terraform is already in a durable position. The two weak spots get closed in the first nine months, the strong skill gets its badges last when they cost the least, and the build project turns every course into something running in a cluster. The only two things that would actually threaten me remain the clearance going inactive and Security+ lapsing, and both have dates on this page.
