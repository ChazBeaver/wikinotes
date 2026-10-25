# Terraform Custom Conditions

**Associate 004 · Terraform 1.12 · Objective 4g**
| [Study map](terraform-associate-004-overview.md)

## Select the correct condition

| Construct | Location | Use | False result |
| --- | --- | --- | --- |
| `validation` | Inside `variable` | Reject an invalid input | Error |
| `precondition` | Resource/data `lifecycle`, or directly inside `output` | Check an assumption before the associated operation | Error |
| `postcondition` | Resource/data `lifecycle` | Check a resulting value | Error. Blocks dependent work. |
| `check` with `assert` | Top level | Report a health or configuration problem | Warning. The run continues. |

`terraform validate` checks configuration structure and internal consistency.
It does not replace conditions that need actual input values or provider results.
Conditions run when their required values are available.
Unknown values can defer a condition until apply.

Reference: [Custom validation](https://developer.hashicorp.com/terraform/language/v1.12.x/validate).

## Compare all four in one local lab

Save this complete example as `main.tf` in an empty directory.

```hcl
variable "environment" {
  type    = string
  default = "dev"
}

variable "replicas" {
  type    = number
  default = 1

  validation {
    condition     = var.replicas >= 1 && floor(var.replicas) == var.replicas
    error_message = "Set replicas to a positive integer."
  }
}

resource "terraform_data" "service" {
  input = {
    environment = var.environment
    replicas    = var.replicas
  }

  lifecycle {
    precondition {
      condition     = var.environment != "prod" || var.replicas >= 2
      error_message = "Production requires at least two replicas."
    }

    postcondition {
      condition     = self.output.replicas >= 1
      error_message = "The result must contain at least one replica."
    }
  }
}

output "service" {
  value = terraform_data.service.output

  precondition {
    condition     = length(var.environment) > 0
    error_message = "Set a non-empty environment name."
  }
}

check "redundancy" {
  assert {
    condition     = var.replicas >= 2
    error_message = "This service has no replica redundancy."
  }
}
```

```bash
terraform init
terraform validate
terraform plan
terraform plan -var='replicas=0'
terraform plan -var='environment=prod'
terraform plan -var='environment=prod' -var='replicas=2'
```

| Command | Expected |
| --- | --- |
| `validate` | Configuration is valid |
| Default `plan` | Warning from `check`. Planning continues. |
| `plan -var='replicas=0'` | Input-validation error |
| `plan -var='environment=prod'` | Precondition error because replicas defaults to 1 |
| Production with 2 replicas | The input checks pass |

## Check assumptions and results

| Need | Use |
| --- | --- |
| Permit only `dev` and `prod` input values | Variable validation with `contains` |
| Require an x86 image before creating a server | Resource precondition |
| Require an encrypted volume returned by a data source | Data-source postcondition |
| Report an unavailable application endpoint | A `check` block |

**Excerpt:** Check a data-source result.

```hcl
data "aws_ebs_volume" "existing" {
  filter {
    name   = "volume-id"
    values = [var.volume_id]
  }

  lifecycle {
    postcondition {
      condition     = self.encrypted
      error_message = "The selected volume must be encrypted."
    }
  }
}
```

`self` refers to the current object in a postcondition.
A failed postcondition does not roll back changes already made.
An output supports `precondition`, but not `postcondition`.

Reference: [Lifecycle condition rules](https://developer.hashicorp.com/terraform/language/v1.12.x/meta-arguments/lifecycle).

## Exam details

- A false `check` assertion warns. Invalid HCL can still make the configuration fail.
- A check runs during Terraform operations. It is not a continuous local monitoring service.
- HCP Terraform health assessments can run checks again between normal runs.
- `condition` is a boolean expression.
- `error_message` explains what the caller must correct.
- A condition that uses resource results can run later than one that uses known input values.

Reference: [Check blocks](https://developer.hashicorp.com/terraform/language/v1.12.x/validate#checks).

## Self-test

1. Which condition reports a problem without blocking a normal run?
2. Can an output contain a `postcondition`?
3. Does `validate` prove that a cloud API will accept every operation?
4. Does a failed postcondition undo an already-created resource?

**Answers:** 1. A `check` assertion. 2. No. 3. No. 4. No.
