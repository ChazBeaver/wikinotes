# Terraform Core Workflow (Associate 004)

**Associate 004 · Terraform 1.12 · Objectives 3a–3g**
| [Study map](terraform-associate-004-overview.md)

Use this sequence to create, inspect, change, and remove managed infrastructure.

## The order

```text
1. Write    →  create .tf files
2. Providers →  declare required_providers + provider blocks
3. init     →  terraform init
4. fmt      →  terraform fmt
5. validate →  terraform validate
6. plan     →  terraform plan
7. apply    →  terraform apply
8. destroy  →  terraform destroy
```

**Mnemonic:** **W**hy **P**eople **I**n **F**ield **V**isits **P**lan **A**head **D**aily
(Write, Providers, Init, Fmt, Validate, Plan, Apply, Destroy)

HashiCorp's official short form is **Write → Plan → Apply**; everything else
fits inside or around those three.

## Each phase

| # | Phase | What it does | Remember |
| --- | --- | --- | --- |
| 1 | **Write** | Create `.tf` files (`main.tf`, `variables.tf`, `outputs.tf`) in HCL. | Terraform loads every `.tf` file in the directory; file names don't matter to it. |
| 2 | **Providers** | `required_providers` declares sources and version constraints. A `provider` block configures a connection. | Providers are plugins that communicate with APIs. |
| 3 | **init** | Downloads providers and modules, sets up the backend, writes `.terraform/` and `.terraform.lock.hcl`. | **Run first, and again** whenever you add/change a provider, module, or backend. Safe to re-run. |
| 4 | **fmt** | Rewrites files to canonical HCL style (indentation, alignment). | Style only — no logic check. `-check` fails without changing files (CI); `-recursive` for subdirs. |
| 5 | **validate** | Checks syntax and internal consistency (types, required args, references). | Needs `init` first (needs provider schemas). Does **not** contact real infrastructure. |
| 6 | **plan** | Normally reads real objects and compares them with configuration and recorded state. | Does not apply infrastructure changes. `-out=tfplan` saves the plan. |
| 7 | **apply** | Executes changes and writes state to the configured backend. | Without a saved plan, it creates a new plan and normally asks for approval. |
| 8 | **destroy** | Plans and applies removal of managed resources in the selected state. | Same as `terraform apply -destroy`. Data sources do not cause object deletion. |

Reference: [Core workflow](https://developer.hashicorp.com/terraform/intro/core-workflow).

## Command-order details

- **`fmt` does not require `init`.** It only reads text, so it can run any
  time. `validate` *does* require `init`. Order `init → fmt → validate` is
  the conventional sequence.
- **`plan` is optional before `apply`.** Plain `apply` creates its own plan.
  Review the plan before approval. Use a saved plan for an automated apply.

## Complete local lab

Save this as `main.tf` in an empty directory. It uses no external provider or cloud account.

```hcl
variable "message" {
  type    = string
  default = "first version"
}

resource "terraform_data" "example" {
  input = var.message
}

output "message" {
  value = terraform_data.example.output
}
```

```bash
terraform init
terraform fmt -check
terraform validate
terraform plan -out=tfplan
terraform show tfplan
terraform apply tfplan
terraform output -raw message
terraform plan
```

**Expected:** Create one resource. Output `first version`. The final plan proposes no changes.
Applying `tfplan` executes the saved plan without another approval prompt.
Treat saved plans as sensitive files. They can contain secret input values.

Change the input and review the proposed update:

```bash
terraform plan -var='message=second version' -out=update.tfplan
terraform apply update.tfplan
terraform plan -destroy
terraform destroy
```

The final command asks for confirmation before it removes the lab resource.

## Read plan symbols and options

| Symbol or option | Meaning |
| --- | --- |
| `+` | Create |
| `~` | Update in place |
| `-` | Destroy |
| `-/+` | Destroy the old object, then create its replacement |
| `+/-` | Create the replacement, then destroy the old object |
| `<=` | Read a data source |
| `(known after apply)` | The final value is not yet available |
| `-replace=ADDRESS` | Request replacement of a managed resource |
| `-refresh-only` | Plan state and output updates without infrastructure changes |
| `-detailed-exitcode` | Return 0 for no changes, 1 for an error, or 2 for changes |

Saved-plan apply uses the plan's recorded decisions and input values.
Do not supply new normal `-var` values when applying that file.
Ephemeral inputs are not saved and may need to be supplied again.

`validate` does not check cloud permissions, quotas, or real-object existence.
During apply, API errors can leave a partially completed deployment.
Correct the cause and make a new plan. Terraform does not automatically roll back completed work.

References: [Plan](https://developer.hashicorp.com/terraform/cli/commands/plan)
and [apply](https://developer.hashicorp.com/terraform/cli/commands/apply).

## Quick self-test

1. Which command creates `.terraform.lock.hcl`? → `init`
2. Which command fails if you never ran `init`? → `validate` (and `plan`/`apply`)
3. Which command changes no infrastructure but contacts providers to read real state? → `plan`
4. You added a new module. What must you run before `plan`? → `init`
5. Which command is used in CI to fail on unformatted code? → `terraform fmt -check`
6. What's the equivalent of `terraform destroy`? → `terraform apply -destroy`
