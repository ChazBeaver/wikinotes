# HCP Terraform

**Associate 004 · Objectives 8a–8d · Reviewed 2026-10-14**
| [Study map](terraform-associate-004-overview.md)

## Know the service's purpose

HCP Terraform provides shared state, managed runs, and team controls.
Terraform Enterprise provides a self-hosted platform with related capabilities.
For this exam, focus on the HCP workflows and features in the objective list.

| Need | HCP capability |
| --- | --- |
| Share state | Workspace state storage and version history |
| Run Terraform consistently | Managed execution and workspace settings |
| Review changes | Plans, approvals, and run history |
| Restrict access | Teams and permissions |
| Enforce organization rules | Policy checks and governance features |

Reference: [HCP Terraform overview](https://developer.hashicorp.com/terraform/cloud-docs).

## Separate organization, project, and workspace

```text
Organization: example-team
  ├── Project: network
  │   ├── Workspace: network-dev
  │   └── Workspace: network-prod
  └── Project: application
      ├── Workspace: app-dev
      └── Workspace: app-prod
```

| Object | Contains or controls |
| --- | --- |
| Organization | Shared administration, teams, and settings |
| Project | A group of workspaces with related ownership and access |
| Workspace | A configuration context, state, variables, runs, and settings |

Putting two workspaces in a project does not merge their state.
Use separate workspaces for infrastructure with separate ownership or change schedules.

Reference: [Projects](https://developer.hashicorp.com/terraform/cloud-docs/projects).

## HCP and CLI workspaces are different

| CLI workspace | HCP workspace |
| --- | --- |
| Selects a separate state for one working configuration | Has its own configuration context, state, variables, and run history |
| Uses the local CLI's available credentials | Uses credentials available to its execution environment |
| Does not provide team authorization by itself | Supports team access controls |
| Does not create a run service | Can execute and coordinate runs |

Reference: [Workspace comparison](https://developer.hashicorp.com/terraform/cloud-docs/workspaces).

## Separate workflow from execution mode

| Workflow | What starts a run? |
| --- | --- |
| CLI-driven | A user runs `terraform plan` or `terraform apply` |
| VCS-driven | A connected version-control event starts the appropriate run |
| API-driven | Automation uploads configuration and creates a run through the API |

| Execution mode | Where Terraform executes |
| --- | --- |
| Remote | HCP-managed workers |
| Agent | An agent running in a network you control |
| Local | The local machine. HCP stores state. |

CLI-driven does not mean locally executed.
An agent can reach private infrastructure while HCP coordinates the run.
Local execution does not receive the same managed-run policy and execution features.
HCP does not evaluate workspace variables or variable sets in local execution mode.
Provide variables and credentials in the environment where Terraform actually executes.

References: [Run workflows](https://developer.hashicorp.com/terraform/cloud-docs/run)
and [execution settings](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings).

## Connect a local configuration

**Excerpt:** Use an existing organization and an appropriate workspace.

```hcl
terraform {
  cloud {
    organization = "example-team"

    workspaces {
      name = "exam-lab"
    }
  }
}
```

```bash
terraform login
terraform init
terraform plan
terraform apply
```

`login` authenticates the CLI to HCP Terraform. It does not authenticate the AWS provider.
The `cloud` block integrates with HCP state and operations.
It cannot coexist with a `backend` block.

To migrate existing local state:

1. Stop other runs and keep a protected state backup.
2. Configure the `cloud` block for the intended workspace.
3. Run `terraform init`.
4. Review and confirm the offered state migration.
5. Check the destination state and run a plan.

This initialization flow differs from ordinary backend migration flags.
Use the workspace settings to select its Terraform execution version.
Keep that version compatible with `required_version` in configuration.

Reference: [CLI integration](https://developer.hashicorp.com/terraform/cli/cloud).

## Understand a managed run

```text
Configuration received
        ↓
Initialization and plan
        ↓
Configured cost, policy, and external checks
        ↓
Approval when required
        ↓
Apply and save state
```

A speculative plan previews changes and cannot be applied directly.
Pull requests commonly produce speculative plans.
A normal run can proceed to apply after required checks and approval.
The configured workflow and auto-apply settings control approval behavior.
HCP coordinates workspace runs to avoid competing state changes.

Reference: [Remote operations](https://developer.hashicorp.com/terraform/cloud-docs/run/remote-operations).

## Set variables where the run can use them

| Variable kind | Example | Consumer |
| --- | --- | --- |
| Terraform variable | `region = "us-east-1"` | `var.region` in the configuration |
| Environment variable | `AWS_REGION` | Provider or process environment |
| Variable set | Common team settings | Selected workspaces or projects |
| Sensitive variable | A secret supplied through the UI/API | Run environment, with restricted display |

For a complex Terraform value, use the HCL option when the value must be parsed as an expression.
Shared variable sets reduce repeated configuration.
Priority variable sets can override values at a more specific scope.
Do not apply the local CLI precedence list to every HCP variable collision.
Use the documented HCP precedence rules for the relevant scopes.
Marking a workspace input sensitive does not guarantee its absence from Terraform state.

Reference: [HCP variable rules](https://developer.hashicorp.com/terraform/cloud-docs/variables).

## Connect workspaces with run triggers

```text
network-prod applies successfully
               ↓ run trigger
app-prod queues a new run
```

The downstream workspace declares the upstream source workspace.
A trigger starts work. It does not copy output values or grant state access.
Configure data access separately when the downstream configuration needs upstream outputs.
Trigger-created runs do not auto-apply unless the separate run-trigger auto-apply setting permits it.

`terraform_remote_state` exposes root outputs but requires access to the state snapshot.
For HCP outputs, `tfe_outputs` can avoid granting full state access.

Reference: [Run triggers and output sharing](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/settings/run-triggers).

## Select a collaboration or governance feature

| Scenario | Feature |
| --- | --- |
| Share approved modules and providers | Private registry |
| Let a team review plans without applying | Team permissions |
| Apply the same rules across workspaces | Policy sets |
| Check policy as code | Sentinel or Open Policy Agent (OPA) |
| Check a plan with an external service | Run tasks |
| Detect changes made outside Terraform | Drift detection through health assessments |
| Recheck infrastructure assertions | Continuous validation through health assessments |
| Find resources, providers, or versions across workspaces | Explorer |
| Offer controlled requests for infrastructure changes | Change requests |
| Avoid long-lived provider credentials | Dynamic provider credentials |

Policy failure behavior depends on enforcement settings.
A mandatory rule can block apply. An advisory rule can report a failure without blocking it.
Do not assume all failing policies can be overridden.
Health assessments detect problems. They do not automatically repair drift.

References: [Policies](https://developer.hashicorp.com/terraform/cloud-docs/policy-enforcement),
[health](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/health),
[Explorer](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/explorer),
and [change requests](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/change-requests).

## Recognize dynamic provider credentials

```text
HCP workload identity → cloud trust policy → short-lived cloud credentials
```

The cloud verifies the run's identity before it grants access.
Trust settings can restrict the organization, workspace, and run phase.
An HCP login token and a cloud-provider credential serve different purposes.

Reference: [Dynamic credentials](https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials).

## Self-test

1. Does a project combine its workspaces into one state file?
2. Must a CLI-driven HCP run execute on the user's laptop?
3. Does a run trigger automatically grant access to upstream outputs?
4. Can a speculative plan be applied directly?
5. Which feature groups workspaces by ownership?
6. Does drift detection automatically restore the declared configuration?

**Answers:** 1. No. 2. No. 3. No. 4. No. 5. Projects. 6. No.
