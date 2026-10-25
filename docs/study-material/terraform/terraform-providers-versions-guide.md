# Terraform Providers and Versions

**Associate 004 · Terraform 1.12 · Objectives 2a–2c, 3b**
| [Study map](terraform-associate-004-overview.md)

## Separate the three versions

| Setting | Controls |
| --- | --- |
| `required_version` | Terraform CLI version |
| `required_providers.aws.version` | AWS provider version |
| `module.version` | A registry module version |

**Excerpt:** Require two plugins. Configure the AWS connection separately.

```hcl
terraform {
  required_version = ">= 1.12.0, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

resource "random_pet" "name" {
  length = 2
}

resource "aws_s3_bucket" "lab" {
  bucket_prefix = "exam-${random_pet.name.id}-"
}
```

`random` does not need a configuration block for this example.
The AWS provider uses its supported credential sources. Do not place credentials in the code.

Reference: [Provider requirements](https://developer.hashicorp.com/terraform/language/v1.12.x/providers/requirements).

## Read a source address

```text
registry.terraform.io / hashicorp / aws
hostname               namespace   type
```

`hashicorp/aws` uses the default hostname, `registry.terraform.io`.
The local name `aws` connects resource types and provider configurations to that requirement.
Providers define resource schemas, data sources, and API operations.
Terraform Core evaluates configuration and builds the execution graph.

## Read version constraints

| Constraint | Accepted versions |
| --- | --- |
| `= 5.20.0` | Exactly 5.20.0 |
| `>= 5.20.0` | 5.20.0 and later |
| `>= 5.20.0, < 6.0.0` | 5.20.0 through the remaining 5.x versions |
| `~> 5.20` | At least 5.20.0, but below 6.0.0 |
| `~> 5.20.0` | At least 5.20.0, but below 5.21.0 |
| `!= 5.20.1` | Exclude 5.20.1 |

All applicable constraints must agree. Terraform selects one version of each provider source for the configuration.
Two AWS aliases do not install two AWS provider versions.

Reference: [Version constraints](https://developer.hashicorp.com/terraform/language/v1.12.x/expressions/version-constraints).

## Initialization and the dependency lock file

```bash
terraform init
terraform providers
terraform init -upgrade
```

| Situation | Result |
| --- | --- |
| No selection exists in the lock file | `init` selects a compatible provider version |
| A compatible selection exists | `init` reuses the locked version |
| You run `init -upgrade` | Terraform can select newer versions within the constraints |
| Constraints exclude the locked version | Update the selection with `init -upgrade` |

Commit `.terraform.lock.hcl`. It records selected provider versions and package checksums.
Do not commit `.terraform/`. It contains local initialization data and downloaded dependencies.
The dependency lock file does not lock remote module versions.
It does not prevent concurrent state writes.

Reference: [Dependency lock file](https://developer.hashicorp.com/terraform/language/v1.12.x/files/dependency-lock).

## Use two configurations of one provider

**Excerpt:** Add an alias for the second region.

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "west"
  region = "us-west-2"
}

resource "aws_s3_bucket" "archive" {
  provider      = aws.west
  bucket_prefix = "exam-archive-"
}
```

`provider = aws.west` selects a provider configuration. It is not a string.
Resources without this argument use the default configuration.
If every configuration has an alias, Terraform creates an implied empty default configuration.
That default can fail when required settings are missing.

Pass aliases into child modules explicitly. See the [modules guide](terraform-modules-guide.md).
Reference: [Provider block](https://developer.hashicorp.com/terraform/language/v1.12.x/providers/configuration).

## Self-test

1. Does `~> 5.20.0` allow 5.21.0?
2. Does `init -upgrade` ignore the configured version constraints?
3. Does `.terraform.lock.hcl` lock module versions?
4. Which block configures a region: `required_providers` or `provider`?

**Answers:** 1. No. 2. No. 3. No. 4. `provider`.
