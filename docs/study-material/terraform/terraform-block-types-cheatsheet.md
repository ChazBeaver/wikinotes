# Terraform Block Types (Associate 004)

**Target:** Terraform 1.12. | [Study map](terraform-associate-004-overview.md)
Examples are excerpts unless stated otherwise. Configure required providers and omitted inputs before use.

Every Terraform file is built from **blocks**: `type "label" "label" { ... }`.
This sheet lists each top-level block, then the blocks that only live inside
other blocks.

## At a glance

| Group | Block | One-line purpose |
| --- | --- | --- |
| Settings | `terraform` | Terraform version, providers, and where state lives |
| | `provider` | Configure a plugin (region, credentials, default tags) |
| Infrastructure | `resource` | Create and manage something |
| | `data` | Read something that already exists |
| | `ephemeral` | Obtain or generate temporary values that Terraform omits from state and plans |
| | `module` | Reuse a group of blocks as one unit |
| Inputs / values / outputs | `variable` | Input from outside the configuration |
| | `locals` | Named internal values |
| | `output` | Expose values to the CLI or a parent module |
| State refactoring | `moved` | Rename or move a resource without destroying it |
| | `import` | Bring an existing resource under Terraform |
| | `removed` | Stop managing a resource, optionally without destroying it |
| Validation | `check` | Assertions evaluated during operations. False assertions warn. |

**Memory aid:** a configuration has **settings** (how Terraform runs),
**things** (what it builds or reads), **values** (what flows in and out),
**refactoring** (how state changes safely), and **checks**.

---

## Settings

### `terraform`

```hcl
terraform {
  required_version = ">= 1.12.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    bucket       = "my-tf-state"
    key          = "lab/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
```

**Best used:** declare CLI/provider constraints and optional remote-state settings.
Child modules also declare their provider requirements.
These settings do not accept ordinary variable or resource references.

### `provider`

```hcl
provider "aws" {
  region = var.region
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}
```

**Best used:** to configure how a plugin connects. Use `alias` when you need
the same provider twice, such as two regions or two accounts. A resource
selects it with `provider = aws.west`.

---

## Infrastructure

### `resource`

```hcl
resource "aws_s3_bucket" "logs" {
  bucket = "wikinotes-lab-logs"
}
```

**Best used:** for anything Terraform should **create, update, and destroy**.
Reference it as `<type>.<name>.<attribute>`, for example
`aws_s3_bucket.logs.arn`.

### `data`

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
}
```

**Best used:** read information, such as an AMI, an existing VPC, or the current account ID.
A data source can also read an object managed elsewhere in the configuration.
It does not manage that object's lifecycle. Reference it with a `data.` prefix.

### `ephemeral` (Terraform 1.10+)

The write-only database argument below also requires Terraform 1.11+ and a supporting provider version.

```hcl
ephemeral "aws_secretsmanager_secret_version" "db" {
  secret_id = "prod/db-password"
}

resource "aws_db_instance" "main" {
  # ...
  password_wo         = ephemeral.aws_secretsmanager_secret_version.db.secret_string
  password_wo_version = 1
}
```

**Best used:** for **secrets** you need during a run but never want written
to the plan or state file. Ephemeral values can only go into places that are
also ephemeral, such as provider settings or write-only (`_wo`) arguments.

### `module`

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "lab-vpc"
  cidr = "10.0.0.0/16"
}
```

**Best used:** when the same group of resources is needed more than once
(per environment, per team) or to use a tested public module. Run
`terraform init` after adding or changing one. Reference outputs with
`module.vpc.vpc_id`.

---

## Inputs, values, and outputs

### `variable`

```hcl
variable "environment" {
  type        = string
  description = "Deployment environment"
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}
```

**Best used:** for anything that **changes between deployments**: region,
environment, instance size. Reference with `var.environment`. Add
`sensitive = true` to hide a value from CLI output (it is still stored in
state).

### `locals`

```hcl
locals {
  name_prefix = "${var.project}-${var.environment}"
  common_tags = { Project = var.project, Environment = var.environment }
}
```

**Best used:** to **name a value you'd otherwise repeat** or to compute one
from other values. Callers can't set locals. Note that the block is `locals`
(plural) but references use `local.name_prefix` (singular).

### `output`

```hcl
output "bucket_arn" {
  value       = aws_s3_bucket.logs.arn
  description = "ARN of the logs bucket"
}
```

**Best used:** to **print a value after `apply`**, to pass data from a child
module to its parent, or to share values with another configuration
(through `terraform_remote_state`). Read them with `terraform output`.

---

## State refactoring

### `moved` (Terraform 1.1+)

```hcl
moved {
  from = aws_instance.web
  to   = aws_instance.frontend
}
```

**Best used:** when you **rename a resource or move it into a module**.
Without a state move, Terraform normally proposes destroying the old address and creating the new one.
This is a declarative alternative to `terraform state mv`.

### `import` (Terraform 1.5+)

```hcl
import {
  to = aws_s3_bucket.legacy
  id = "legacy-bucket-name"
}
```

**Best used:** when a resource was **created by hand** (console, CLI) and you
want Terraform to manage it. `terraform plan -generate-config-out=generated.tf`
writes a starting `resource` block when the target configuration is missing.
This is a declarative alternative to `terraform import`.

### `removed` (Terraform 1.7+)

```hcl
removed {
  from = aws_s3_bucket.legacy

  lifecycle {
    destroy = false
  }
}
```

**Best used:** to **stop managing a resource while leaving it running** in
AWS, for example when another team takes it over. With `destroy = false`, it
is dropped from state only. This is a declarative alternative to `terraform state rm`.

---

## Validation

### `check` (Terraform 1.5+)

```hcl
check "website_up" {
  data "http" "site" {
    url = "https://example.com"
  }

  assert {
    condition     = data.http.site.status_code == 200
    error_message = "Website did not return 200."
  }
}
```

**Best used:** for **health checks that shouldn't block a deployment**. A
failed `check` prints a **warning**; `plan` and `apply` still continue. To
block a run instead, use `precondition`/`postcondition` (below).

---

## Nested blocks

These only appear inside another block.

| Block | Lives inside | Best used for |
| --- | --- | --- |
| `required_providers` | `terraform` | Declaring provider sources and version constraints |
| `backend` | `terraform` | Storing state remotely (S3, azurerm, gcs, ...) |
| `cloud` | `terraform` | Connecting to HCP Terraform instead of a `backend` |
| `default_tags` | `provider "aws"` | Tags on every resource from that provider |
| `validation` | `variable` | Rejecting bad input when required values become available |
| `lifecycle` | `resource`, `data`, `ephemeral`, `removed` | Behavior depends on the parent. Not every parent accepts every rule. |
| `precondition` | `lifecycle`, or directly in `output` | Check assumptions. False conditions produce errors. |
| `postcondition` | Resource/data/ephemeral `lifecycle` | Check results. False conditions block dependent work. |
| `dynamic` | any block that accepts repeated nested blocks | Generating repeated nested blocks from a list or map |
| `provisioner` | `resource` | Running a script on create/destroy. Last resort; prefer `user_data` or config tools |
| `connection` | `resource`, `provisioner` | SSH/WinRM details for a `remote-exec` or `file` provisioner |

### `lifecycle` options

```hcl
resource "aws_instance" "web" {
  # ...
  lifecycle {
    create_before_destroy = true                 # build the new one first, then delete the old one
    prevent_destroy       = true                 # error if a plan would destroy this
    ignore_changes        = [tags["LastScan"]]   # don't undo changes made outside Terraform
    replace_triggered_by  = [aws_launch_template.web.latest_version]

    precondition {
      condition     = var.environment != "prod" || var.instance_type != "t3.micro"
      error_message = "prod needs something bigger than t3.micro."
    }
  }
}
```

### `dynamic`

```hcl
resource "aws_security_group" "web" {
  name = "web"

  dynamic "ingress" {
    for_each = [80, 443]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
```

**Best used:** when the number of nested blocks comes from data. Don't use
it to hide a fixed, readable list; HashiCorp advises against overusing it.

---

## Exam traps

- **`count`, `for_each`, `depends_on`, and `provider` are meta-arguments, not
  blocks.** `lifecycle` is the only meta-argument written as a block.
- **`data` reads; `resource` manages.** Deleting a `data` block never deletes
  anything in AWS.
- **`check` warns; `precondition`/`postcondition` and `validation` fail.**
- **`sensitive = true` hides a value from output but still stores it in
  state.** `ephemeral` keeps it out of state entirely.
- **Block names vs reference names:** `locals` → `local.x`; `variable` →
  `var.x`; `data` → `data.type.name`; `module` → `module.name.output`.
- **Declarative blocks have CLI alternatives:** `moved` → `state mv`,
  `import` → `terraform import`, `removed` → `state rm`. The commands still exist.

See [custom conditions](terraform-custom-conditions-guide.md) for evaluation timing.
See [state operations](terraform-state-operations-guide.md) for complete workflows.

## Quick self-test

1. Which block looks up an existing VPC without managing it? → `data`
2. You renamed `aws_instance.web` to `aws_instance.app`. Which block stops a destroy/create? → `moved`
3. Which block declares the AWS provider version constraint? → `required_providers` inside `terraform`
4. A health assertion should warn but never block `apply`. Which block? → `check`
5. How do you reference a local named `prefix`? → `local.prefix`
6. Which block keeps a secret out of the state file entirely? → `ephemeral`
7. Stop managing a bucket but leave it in AWS? → `removed` with `lifecycle { destroy = false }`
8. Generate one `ingress` block per port in a list? → `dynamic "ingress"`
9. Is `for_each` a block? → No, it's a meta-argument
