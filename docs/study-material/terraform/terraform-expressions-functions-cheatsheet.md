# Terraform Expressions and Functions

**Associate 004 · Terraform 1.12 · Objective 4e**
| [Study map](terraform-associate-004-overview.md)

## Read and evaluate expressions

Run `terraform console` in an empty lab directory. Enter one expression at a time.
Use `exit` to stop the console. The examples below need no cloud credentials.

| Console expression | Result |
| --- | --- |
| `2 + 3` | `5` |
| `3 > 2 && true` | `true` |
| `true ? "large" : "small"` | `"large"` |
| `"api-${upper("dev")}"` | `"api-DEV"` |
| `[for n in ["web", "api"] : upper(n)]` | `["WEB", "API"]` |
| `[for n in [1, 2, 3] : n if n > 1]` | `[2, 3]` |
| `{for n in ["web", "api"] : n => length(n)}` | `{ api = 3, web = 3 }` |
| `[{id = "a"}, {id = "b"}][*].id` | `["a", "b"]` |

A `for` expression transforms values. It does not create resources.
Both branches of a conditional must have compatible result types.

Reference: [Expressions](https://developer.hashicorp.com/terraform/language/v1.12.x/expressions).

## Select a function

| Function example | Result or use |
| --- | --- |
| `length(["a", "b"])` | `2` |
| `contains(["dev", "prod"], "qa")` | `false` |
| `lookup({dev = 1}, "prod", 2)` | `2` |
| `merge({env = "dev"}, {env = "prod"})` | `{ env = "prod" }` |
| `concat([1], [2, 3])` | `[1, 2, 3]` |
| `flatten([[1, 2], [3]])` | `[1, 2, 3]` |
| `toset(["a", "a", "b"])` | A set with `"a"` and `"b"` |
| `join("-", ["api", "dev"])` | `"api-dev"` |
| `split(",", "a,b")` | `["a", "b"]` |
| `coalesce(null, "", "dev")` | `"dev"` |
| `try({name = "api"}.port, 8080)` | `8080` |
| `can(tonumber("bad"))` | `false` |
| `jsonencode({enabled = true})` | A JSON string |
| `jsondecode("{\"port\":8080}").port` | `8080` |
| `file("./policy.json")` | Read an existing file as text |
| `templatefile("./config.tftpl", {port = 8080})` | Render an existing template |
| `cidrsubnet("10.20.0.0/16", 8, 1)` | `"10.20.1.0/24"` |

`try` catches dynamic evaluation errors. It does not repair an undeclared variable reference.
`file` and `templatefile` need files that exist before the run.
Terraform does not use those functions to wait for a resource that creates a file.

References: [Functions](https://developer.hashicorp.com/terraform/language/v1.12.x/functions)
and [try](https://developer.hashicorp.com/terraform/language/v1.12.x/functions/try).

## Create instances with count or for_each

**Local lab:** Save this as `main.tf` in a separate directory.

```hcl
resource "terraform_data" "numbered" {
  count = 2
  input = "worker-${count.index}"
}

resource "terraform_data" "named" {
  for_each = {
    web = 80
    api = 8080
  }
  input = "${each.key}:${each.value}"
}
```

```bash
terraform init
terraform plan
```

**Expected:** Four resource instances.

| Expression | Address or value |
| --- | --- |
| First numbered instance | `terraform_data.numbered[0]` |
| API instance | `terraform_data.named["api"]` |
| `each.key` in the API instance | `"api"` |
| `each.value` in the API instance | `8080` |

| Use `count` when... | Use `for_each` when... |
| --- | --- |
| A numeric quantity identifies instances | Stable keys identify instances |
| An index is sufficient | Each instance has separate settings |

Changing a list position can affect instances that use `count`.
Changing a `for_each` key changes the instance address.
The `for_each` value must be a map or a set of strings.
Convert a list explicitly with `toset` when appropriate.
For a set, `each.key` and `each.value` are the same string.
Instance keys must be known before apply. Sensitive keys are not allowed.
Do not use `count` and `for_each` together in one block.

Reference: [for_each](https://developer.hashicorp.com/terraform/language/v1.12.x/meta-arguments/for_each).

## Generate nested blocks with dynamic

**Excerpt:** Generate two ingress blocks inside one security group.

```hcl
resource "aws_security_group" "web" {
  name_prefix = "exam-web-"
  vpc_id      = aws_vpc.lab.id

  dynamic "ingress" {
    for_each = [80, 443]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["10.20.0.0/16"]
    }
  }
}
```

This creates one resource with repeated nested settings.
Unlike resource `for_each`, dynamic-block `for_each` can iterate a list.
`dynamic` cannot generate `lifecycle` or `provisioner` blocks.
It does not declare new top-level resource blocks.

Reference: [Dynamic blocks](https://developer.hashicorp.com/terraform/language/v1.12.x/expressions/dynamic-blocks).

## Self-test

1. Does a `for` expression create resource instances?
2. Which map wins in `merge(a, b)` when both contain the same key?
3. Can a generated resource ID be an unknown `for_each` key during planning?
4. Does `dynamic` create several resources or repeated nested blocks?

**Answers:** 1. No. 2. `b`. 3. No. 4. Repeated nested blocks.
