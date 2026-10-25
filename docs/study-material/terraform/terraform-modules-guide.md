# Terraform Modules

**Associate 004 · Terraform 1.12 · Objectives 5a–5d**
| [Study map](terraform-associate-004-overview.md)

## A module is a directory of configuration

| Term | Meaning |
| --- | --- |
| Root module | The configuration directory where Terraform runs |
| Child module | A module called by another module |
| Input | A variable declared by the child and assigned by its caller |
| Output | A value that the child exposes to its caller |

Terraform combines `.tf` files in one directory into one module.
It does not automatically load `.tf` files from subdirectories.
File names such as `main.tf` and `variables.tf` are conventions.

Reference: [Modules](https://developer.hashicorp.com/terraform/language/v1.12.x/modules).

## Build and call a local module

**Local lab:** Create these two files in an empty lab directory.

```text
lab/
├── main.tf
└── modules/
    └── label/
        └── main.tf
```

Root `main.tf`:

```hcl
variable "environment" {
  type    = string
  default = "dev"
}

module "label" {
  source = "./modules/label"
  name   = var.environment
}

output "service_label" {
  value = module.label.label
}
```

Child `modules/label/main.tf`:

```hcl
variable "name" {
  type = string
}

resource "terraform_data" "label" {
  input = "api-${var.name}"
}

output "label" {
  value = terraform_data.label.output
}
```

Run these commands from the root directory:

```bash
terraform init
terraform apply -var='environment=test'
terraform output -raw service_label
terraform state list
```

**Expected:** Output `api-test`. State address `module.label.terraform_data.label`.

## Follow variable scope

```text
Root var.environment
       │ explicit name argument
       ▼
Child var.name → child resource → child output label
                                      │
                                      ▼
                             module.label.label
```

- The child does not automatically receive the root's variables or locals.
- A root `.tfvars` file supplies root inputs only.
- Pass values between sibling modules through their parent.
- Read child outputs, not child resource internals, in normal expressions.
- A missing required child input is a configuration error.

Reference: [Module composition](https://developer.hashicorp.com/terraform/language/v1.12.x/modules/develop/composition).

## Select and version a source

| Source | Example | Select a version with |
| --- | --- | --- |
| Local directory | `./modules/label` | The repository revision |
| Public registry | `terraform-aws-modules/vpc/aws` | `version = "~> 5.0"` |
| Private registry | `app.terraform.io/example/network/aws` | A `version` constraint |
| Git repository | `git::https://example.com/team/network.git?ref=v1.2.0` | Git `ref` |
| Git subdirectory | `git::https://example.com/team/modules.git//network?ref=v1.2.0` | Git `ref` after the subdirectory |
| Supported archive/object storage source | A module archive URL | The selected archive location |

`version` is for registry modules. Do not add it to local or Git module calls.
Use a literal source address in Terraform 1.12.
Run `terraform init` after adding or changing a module source.
Use `terraform init -upgrade` to update eligible installed modules and providers.
The dependency lock file records providers, not remote module versions.
Use an exact registry version or Git commit when you need a fixed module revision.

Reference: [Module sources](https://developer.hashicorp.com/terraform/language/v1.12.x/modules/sources).

## Pass provider configurations

**Excerpt:** The child uses its default `aws` name. The root supplies its `west` configuration.

```hcl
provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

module "network" {
  source = "./modules/network"

  providers = {
    aws = aws.west
  }
}
```

Default provider configurations can pass from parent to child automatically.
Aliased configurations need explicit mapping.
Each module declares its own provider requirements and compatible versions.

If a child refers to an alias such as `aws.replica`, declare it in the child's requirements:

```hcl
terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.replica]
    }
  }
}
```

The parent then maps `aws.replica` to an actual configured provider.
Keep provider connection blocks in the root for reusable modules.
Legacy children with their own provider blocks cannot use module `count`, `for_each`, or `depends_on`.

Reference: [Providers within modules](https://developer.hashicorp.com/terraform/language/v1.12.x/modules/develop/providers).

## Self-test

1. Does Terraform load a child directory without a `module` call?
2. Can a child automatically read `var.environment` from its parent?
3. Can `version` select a Git tag?
4. Do aliased providers pass to a child automatically?

**Answers:** 1. No. 2. No. 3. No. Use `ref`. 4. No.
