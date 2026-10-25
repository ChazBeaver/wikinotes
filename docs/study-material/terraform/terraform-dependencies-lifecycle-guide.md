# Terraform Dependencies and Lifecycle

**Associate 004 · Terraform 1.12 · Objectives 4b, 4f**
| [Study map](terraform-associate-004-overview.md)

## References create dependencies

**Excerpt:** The subnet needs the network ID.

```hcl
resource "aws_vpc" "lab" {
  cidr_block = "10.20.0.0/16"
}

resource "aws_subnet" "app" {
  vpc_id     = aws_vpc.lab.id
  cidr_block = "10.20.1.0/24"
}
```

```text
Create:   network → subnet
Destroy:  subnet → network
```

Terraform builds a directed acyclic graph (DAG) from dependencies.
Independent resources can run in parallel.
Circular references produce a dependency-cycle error.
The order of files and blocks does not determine resource order.

Reference: [Dependency graph](https://developer.hashicorp.com/terraform/internals/graph).

## Use explicit dependencies for hidden requirements

**Excerpt:** An instance needs an IAM policy attachment before it starts.
Other instance arguments are omitted.

```hcl
resource "aws_instance" "app" {
  ami                  = var.ami_id
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.app.name

  depends_on = [aws_iam_role_policy.app]
}
```

The instance already references the instance profile.
The separate policy is a behavioral dependency without a direct value reference.

- Prefer a normal reference when a resource needs another resource's value.
- Use `depends_on` when the required behavior is not represented by a reference.
- Use object references, not quoted addresses, in `depends_on`.
- A module-wide dependency can delay all resources and data reads inside the module.
- Extra dependencies can make plans more conservative and produce more unknown values.

Reference: [depends_on](https://developer.hashicorp.com/terraform/language/v1.12.x/meta-arguments/depends_on).

## Read resource addresses

| Address | Meaning |
| --- | --- |
| `aws_vpc.lab.id` | Attribute of a managed resource |
| `data.aws_vpc.existing.id` | Attribute returned by a data source |
| `aws_instance.app[0].id` | Attribute of a `count` instance |
| `aws_instance.app["api"].id` | Attribute of a `for_each` instance |
| `module.network.vpc_id` | Child-module output |
| `module.network.aws_vpc.lab` | Resource address used by state commands |

Normal configuration accesses child values through outputs.
It cannot directly read a child's internal resource attributes.
In shell commands, quote addresses that contain brackets.

```bash
terraform state show 'aws_instance.app["api"]'
```

Reference: [Resource addressing](https://developer.hashicorp.com/terraform/cli/state/resource-addressing).

## Select a lifecycle rule

| Rule | Effect | Limit |
| --- | --- | --- |
| `create_before_destroy = true` | Create the replacement before deleting the old object | Both objects must be able to exist together |
| `prevent_destroy = true` | Reject a plan that destroys or replaces the object | Removing the entire resource block removes this protection |
| `ignore_changes = [tags["Owner"]]` | Ignore that attribute when planning updates | The value is still used during creation |
| `replace_triggered_by = [terraform_data.release]` | Replace this resource when the referenced resource changes | Requires managed-resource references, not a plain variable |

Lifecycle rules do not turn every update into a replacement.
`create_before_destroy` changes the order when replacement is already required.
Unique names, quotas, and capacity can prevent both objects from existing together.
The rule can also propagate to dependencies.

Reference: [Lifecycle rules](https://developer.hashicorp.com/terraform/language/v1.12.x/meta-arguments/lifecycle).

## See replacement order

**Local lab:** Save this as `main.tf` in an empty directory.

```hcl
variable "release" {
  type    = string
  default = "v1"
}

resource "terraform_data" "deployment" {
  input            = var.release
  triggers_replace = var.release

  lifecycle {
    create_before_destroy = true
  }
}
```

```bash
terraform init
terraform apply
terraform plan -var='release=v2'
```

**Expected:** The second plan replaces the resource. `+/-` means create, then destroy.
Without the lifecycle rule, replacement normally shows `-/+`: destroy, then create.

You can request replacement without editing a resource argument:

```bash
terraform plan -replace=terraform_data.deployment
```

`-replace` does not bypass `prevent_destroy`.
Use `-target` only for exceptional recovery or troubleshooting.
A targeted plan can omit other required changes. Follow it with a complete plan.

Reference: [Plan options](https://developer.hashicorp.com/terraform/cli/commands/plan).

## Self-test

1. Does moving a block above another block change its dependency order?
2. Does `create_before_destroy` remove naming constraints?
3. Does deleting a resource block retain its `prevent_destroy` protection?
4. Should you add `depends_on` when a normal attribute reference already expresses the dependency?

**Answers:** 1. No. 2. No. 3. No. 4. Usually no.
