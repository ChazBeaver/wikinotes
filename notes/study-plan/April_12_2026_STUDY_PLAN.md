# 2–3 Week Focused Study Plan (Kubernetes Platform + Terraform + AWS)

## Goal
Build confidence and real-world capability in Terraform, AWS (EKS/IAM), and Kubernetes platform thinking without burnout.



## Structure
- Duration: ~2–3 weeks
- Time: 1–2 hours/day
- Approach: Build → Break → Fix → Repeat



---



## Week 1: Terraform Foundations (HIGH PRIORITY)

### Day 1–2: Core Terraform Workflow
- Install/setup Terraform locally
- Write a simple config (EC2 or S3)
- Run: init, plan, apply, destroy
- Understand state files



### Day 3–4: Variables + Outputs
- Add variables.tf and outputs.tf
- Parameterize your config
- Practice passing variables via CLI and tfvars



### Day 5–6: Modules
- Break your config into a reusable module
- Call the module from a root config
- Pass variables into the module



### Day 7: Remote State
- Configure S3 backend
- Add DynamoDB for locking
- Run apply again and verify state is remote



🎯 Outcome:
You can confidently write, structure, and apply Terraform for real infra



---



## Week 2: AWS + Kubernetes (Platform Thinking)

### Day 8–9: AWS Core (Focused)
- IAM basics (roles, policies)
- Understand IRSA at a high level
- Review VPC basics (subnets, routing)



### Day 10–11: EKS Understanding
- How EKS cluster is structured
- Node groups vs Fargate
- How kubectl connects to cluster



### Day 12–13: Kubernetes Platform Concepts
- Ingress basics (NGINX or ALB)
- Services (ClusterIP, NodePort, LoadBalancer)
- Persistent Volumes (EBS basics)



### Day 14: Observability Basics
- What metrics/logs/traces mean
- High-level Prometheus + Grafana understanding
- How you'd debug a failing pod



🎯 Outcome:
You understand how Kubernetes runs as a platform—not just how to use it



---



## Week 3 (Optional / Bonus): Integration + Confidence

### Day 15–16: Terraform + AWS Together
- Use Terraform to provision AWS resources
- (Optional) Look at EKS Terraform module (read, not master)



### Day 17–18: Deploy Something Simple
- Deploy a basic app to Kubernetes
- Expose it via a service
- Modify and redeploy



### Day 19–20: Break/Fix Practice
- Intentionally break configs
- Fix Terraform errors
- Debug Kubernetes issues



🎯 Outcome:
You feel comfortable solving real problems instead of just following steps



---



## Daily Rule (MOST IMPORTANT)
- Do NOT overextend
- Stop after 1–2 hours
- Consistency > intensity



## Final Result After 2–3 Weeks
- Terraform: Confident
- AWS: Structured understanding
- Kubernetes: Platform-level thinking
- You feel READY instead of unsure



---



## Optional Add-On (Only If You Want)
- AWS Solutions Architect Associate (light prep)
- CKA (only if you enjoy hands-on Kubernetes)



---



👉 This plan is designed to make you FEEL more confident quickly—not overwhelm you
