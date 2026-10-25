# Terraform State Operations and Imports

**Associate 004 · Terraform 1.12 · Objectives 6d, 7a–7b**
| [Study map](terraform-associate-004-overview.md)

## Inspect before you change

| Command | Shows |
| --- | --- |
| `terraform state list` | Resource and data-source addresses in state |
| `terraform state show 'aws_instance.app["api"]'` | Attributes for one state object |
| `terraform show` | A readable view of the latest state |
| `terraform show tfplan` | A saved plan |
| `terraform show -json tfplan` | A machine-readable plan |
| `terraform output` | Root-module outputs |
| `terraform state pull` | The raw current state snapshot |

State inspection does not refresh the remote objects.
State and JSON output can expose sensitive data.
Use Terraform commands for changes. Do not edit state JSON by hand.

Reference: [State commands](https://developer.hashicorp.com/terraform/cli/commands/state).

## Decide what to do with drift

Drift is a change to a managed object outside Terraform.

```text
Configuration: instance size = small
Stored state:  instance size = small
Real object:   instance size = large    ← someone changed it
```

| Operation | Result |
| --- | --- |
| Normal `plan` | Read the real object and propose changes to match configuration |
| Normal `apply` | Reconcile the object with configuration |
| `plan -refresh-only` | Preview updates to state and root outputs |
| `apply -refresh-only` | Save refreshed state and outputs without changing infrastructure |

Refresh-only does not edit `.tf` files.
To keep an intentional external change, update configuration to match it too.
Otherwise, a later normal apply can reverse that change.

```bash
terraform plan -refresh-only -out=refresh.tfplan
terraform show refresh.tfplan
terraform apply refresh.tfplan
```

The old `terraform refresh` command writes refreshed state without a separate approval step.
Prefer the refresh-only plan/apply workflow.
`-refresh=false` can hide external changes. It is not a normal drift-management solution.

Reference: [Refresh-only operations](https://developer.hashicorp.com/terraform/tutorials/state/refresh).

## Rename a resource without replacement

**Local lab, step 1:** Save this as `main.tf` in an empty directory.

```hcl
resource "terraform_data" "old" {
  input = "keep-this-object"
}
```

```bash
terraform init
terraform apply
terraform state show terraform_data.old
```

**Step 2:** Replace the file contents with this configuration.

```hcl
resource "terraform_data" "new" {
  input = "keep-this-object"
}

moved {
  from = terraform_data.old
  to   = terraform_data.new
}
```

```bash
terraform plan
terraform apply
terraform state list
```

**Expected:** The address changes to `terraform_data.new`. Terraform retains the object ID.
There are no resource additions or destructions.
A move can also change a resource's module address.
Keep useful `moved` history so older module users can upgrade safely.

The command alternative changes state immediately:

```bash
terraform state mv terraform_data.old terraform_data.new
```

Do not run the alternative after you already applied the move.
Reference: [Refactoring](https://developer.hashicorp.com/terraform/language/v1.12.x/modules/develop/refactoring).

## Stop management without destruction

**Excerpt:** Remove the corresponding resource block. Add this block instead.

```hcl
removed {
  from = aws_s3_bucket.legacy

  lifecycle {
    destroy = false
  }
}
```

Review and apply the plan. Terraform removes the state binding and leaves the bucket intact.
The command alternative is `terraform state rm aws_s3_bucket.legacy`.
If its resource configuration remains, the next plan proposes creating a replacement object.
Simply deleting a resource block normally proposes destruction.

Reference: [Remove resources from state](https://developer.hashicorp.com/terraform/language/v1.12.x/state/remove).

## Import an existing object

Import creates a state binding for an object that already exists.
It does not duplicate the object.
Use one Terraform resource address for each imported object.

**Excerpt:** The named bucket must already exist. Configure the provider first.

```hcl
resource "aws_s3_bucket" "legacy" {
  bucket = "example-existing-bucket"
}

import {
  to = aws_s3_bucket.legacy
  id = "example-existing-bucket"
}
```

```bash
terraform init
terraform plan -out=import.tfplan
terraform show import.tfplan
terraform apply import.tfplan
```

The plan can contain both import actions and changes needed to match your configuration.
Check every proposed action before applying.
Import IDs and import support depend on the provider resource type.

Reference: [Configuration-driven import](https://developer.hashicorp.com/terraform/language/v1.12.x/import).

## Compare the two import methods

| Method | Configuration required | When state changes |
| --- | --- | --- |
| `import` block | Resource configuration, or supported generated configuration | On apply |
| `terraform import ADDRESS ID` | Write the resource configuration first | During the import command |

**Alternative:** Use the CLI after initialization and after writing the resource block.

```bash
terraform import aws_s3_bucket.legacy example-existing-bucket
terraform plan
```

The CLI command does not generate a resource block.
For supported configuration generation, start with an `import` block and no matching resource block:

```bash
terraform plan -generate-config-out=generated.tf
```

Use a new output path. Review the generated code, then plan again before applying.
The `moved`, `removed`, and `import` blocks are declarative alternatives.
Their CLI counterparts still exist.

Reference: [CLI import](https://developer.hashicorp.com/terraform/cli/commands/import).

## Self-test

1. Does refresh-only update the desired configuration?
2. Which block records a rename without destroying the object?
3. Which `removed` setting leaves the real object intact?
4. Does CLI import write a complete resource configuration?

**Answers:** 1. No. 2. `moved`. 3. `destroy = false`. 4. No.
