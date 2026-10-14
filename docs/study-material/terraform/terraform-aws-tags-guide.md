# Terraform Tags on AWS

Tags are key/value labels attached to AWS resources. They answer **who owns
this, what is it for, and what does it cost**.

## Why tag

| Use | Example |
| --- | --- |
| Cost tracking | Filter the AWS bill by `Project` or `CostCenter` |
| Ownership | Find who to ask before deleting something (`Owner`) |
| Environment separation | Tell `dev` from `prod` at a glance |
| Automation | Scripts that stop every instance tagged `Schedule = office-hours` |
| Access control (ABAC) | IAM policies that allow actions only on resources with a matching tag |
| Identification | `ManagedBy = terraform` marks what not to edit by hand |

## Where you can apply tags

There are three places, from broadest to most specific.

### 1. Provider `default_tags`: every resource from this provider

```hcl
provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = "dev"
      Project     = "wikinotes-lab"
      Owner       = "chaz"
      ManagedBy   = "terraform"
    }
  }
}
```

- Applied automatically to **every taggable resource** this provider creates.
- Each provider block has its own `default_tags`, so a second provider with an
  `alias` (for example, another region) needs its own block too.
- **Use for:** tags that must be on everything in the configuration.

### 2. `locals` + `merge()`: a shared set, reused selectively

```hcl
locals {
  common_tags = {
    Project   = "wikinotes-lab"
    ManagedBy = "terraform"
  }
}

resource "aws_s3_bucket" "logs" {
  bucket = "wikinotes-lab-logs"
  tags   = merge(local.common_tags, { Name = "logs", DataClass = "internal" })
}
```

- `merge()` combines maps; when the same key appears twice, the **later map
  wins**.
- This was the standard pattern before `default_tags` existed (AWS provider
  3.38). You'll still see it in modules and older code.
- **Use for:** a group of tags shared by some resources but not all.

### 3. Resource `tags`: one resource only

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0123456789abcdef0"
  instance_type = "t3.micro"

  tags = {
    Name = "web-01"
    Role = "frontend"
  }
}
```

- **Use for:** tags that are unique to a resource, especially `Name` (the
  label AWS shows in the console).

## How the layers combine

```text
default_tags  (provider)       Environment=dev   Owner=chaz
      +
tags          (resource)       Name=web-01       Environment=staging
      =
tags_all      (what AWS gets)  Name=web-01  Owner=chaz  Environment=staging
```

- **The resource wins** when both set the same key.
- `tags_all` is a read-only attribute that shows the final merged set. It's
  what you see in `plan` output, and you can reference it:
  `aws_instance.web.tags_all`.

## Passing tags into modules

Give the module a `tags` variable and merge it with the module's own tags:

```hcl
# modules/network/variables.tf
variable "tags" {
  type    = map(string)
  default = {}
}

# modules/network/main.tf
resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
  tags       = merge(var.tags, { Name = "main-vpc" })
}

# root main.tf
module "network" {
  source = "./modules/network"
  tags   = { CostCenter = "1234" }
}
```

The module's resources still get the provider's `default_tags`, because a
module uses the provider passed down from the root.

## Where tags *don't* reach automatically

`default_tags` only covers resources Terraform creates directly. Resources AWS
creates for you need their own tag settings:

| Case | What to do |
| --- | --- |
| EC2 instances launched by an Auto Scaling group | `tag { key, value, propagate_at_launch = true }` blocks on `aws_autoscaling_group` (it does not receive `default_tags`) |
| Instances and volumes from a launch template | `tag_specifications { resource_type = "instance" tags = {...} }` (repeat for `"volume"`) |
| EBS volumes created by `aws_instance` | `root_block_device { tags = {...} }` or `volume_tags` |

Check `plan` and the AWS console after the first `apply` to confirm tags
landed where you expect.

## Best practices

1. **Define a standard tag set** and use it everywhere. A typical minimum:
   `Environment`, `Project`, `Owner`, `CostCenter`, `ManagedBy`.
2. **Put the standard set in `default_tags`.** No resource can forget it.
3. **Pick one casing style and keep it.** AWS tag keys are case-sensitive:
   `Environment` and `environment` are different tags.
4. **Use resource `tags` for `Name`** and anything else unique to that
   resource.
5. **Drive values from variables** (`Environment = var.environment`) so the
   same code tags dev and prod correctly.
6. **Enforce required tags** with variable validation:

   ```hcl
   variable "tags" {
     type = map(string)
     validation {
       condition     = alltrue([for k in ["Owner", "Project"] : contains(keys(var.tags), k)])
       error_message = "tags must include Owner and Project."
     }
   }
   ```

   Across a whole AWS organization, also use **AWS Organizations tag
   policies**.
7. **Activate cost allocation tags** in AWS Billing; otherwise tags don't show
   up in Cost Explorer.
8. **Never put secrets or personal data in tags.** Anyone with read access to
   the resource, the billing data, or the Terraform state can see them.
9. **If an outside tool adds tags**, stop Terraform from removing them on the
   next apply:

   ```hcl
   lifecycle {
     ignore_changes = [tags["LastScannedBy"]]
   }
   ```

## AWS limits

- Up to **50 tags** per resource.
- Key up to **128** characters, value up to **256**.
- The `aws:` prefix is reserved for AWS and can't be used.

## Quick self-test

1. Which block puts tags on every resource from a provider? → `default_tags` inside `provider "aws"`
2. Provider default sets `Environment=dev`, resource sets `Environment=prod`. Result? → `prod` (resource wins)
3. Which attribute shows the final merged tags? → `tags_all`
4. In `merge(a, b)`, which wins when both have the same key? → `b` (the later map)
5. Do ASG-launched instances get `default_tags`? → No; use `tag` blocks with `propagate_at_launch = true`
6. A second `provider "aws"` with `alias = "west"`. Does it inherit the first one's `default_tags`? → No; give it its own block
7. Why do tags not show in Cost Explorer? → Cost allocation tags weren't activated in Billing
