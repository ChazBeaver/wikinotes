# Terraform Core Workflow (Associate 004)

The order of commands from an empty directory to destroyed infrastructure.

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
| 2 | **Providers** | `terraform { required_providers { ... } }` pins source + version; `provider "aws" { ... }` configures it. | Providers are plugins that talk to the platform's API. |
| 3 | **init** | Downloads providers and modules, sets up the backend, writes `.terraform/` and `.terraform.lock.hcl`. | **Run first, and again** whenever you add/change a provider, module, or backend. Safe to re-run. |
| 4 | **fmt** | Rewrites files to canonical HCL style (indentation, alignment). | Style only — no logic check. `-check` fails without changing files (CI); `-recursive` for subdirs. |
| 5 | **validate** | Checks syntax and internal consistency (types, required args, references). | Needs `init` first (needs provider schemas). Does **not** contact real infrastructure. |
| 6 | **plan** | Refreshes state, compares config to real infra, shows the diff. | Symbols: `+` create, `-` destroy, `~` update in place, `-/+` replace. `-out=tfplan` saves it. Changes nothing. |
| 7 | **apply** | Executes the changes and writes `terraform.tfstate`. | Runs a plan and asks `yes` unless given a saved plan file or `-auto-approve`. |
| 8 | **destroy** | Removes every resource tracked in state. | Same as `terraform apply -destroy`. Preview with `terraform plan -destroy`. |

## Your order: corrections

Your order was correct. Two nuances the exam likes:

- **`fmt` does not require `init`.** It only reads text, so it can run any
  time. `validate` *does* require `init`. Order `init → fmt → validate` is
  the conventional sequence.
- **`plan` is optional before `apply`.** `apply` plans on its own, but the
  best practice is to review a plan first (and apply a saved plan in CI).

## Quick self-test

1. Which command creates `.terraform.lock.hcl`? → `init`
2. Which command fails if you never ran `init`? → `validate` (and `plan`/`apply`)
3. Which command changes no infrastructure but contacts providers to read real state? → `plan`
4. You added a new module. What must you run before `plan`? → `init`
5. Which command is used in CI to fail on unformatted code? → `terraform fmt -check`
6. What's the equivalent of `terraform destroy`? → `terraform apply -destroy`
