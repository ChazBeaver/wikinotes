# Terraform Variables, Types, and Outputs

**Associate 004 · Terraform 1.12 · Objectives 4c–4d**
| [Study map](terraform-associate-004-overview.md)

## Follow the value

```text
Caller input → var.environment → local.label → resource → output
```

**Local lab:** Save this as `main.tf` in an empty directory.

```hcl
variable "environment" {
  type        = string
  description = "Environment name."
  default     = "dev"
  nullable    = false
}

locals {
  label = "api-${var.environment}"
}

resource "terraform_data" "label" {
  input = local.label
}

output "label" {
  value = terraform_data.label.output
}
```

```bash
terraform init
terraform apply -var='environment=test'
terraform output -raw label
```

**Expected:** `api-test`. Confirm the apply when Terraform asks.

| Construct | Set by | Reference |
| --- | --- | --- |
| Input variable | Caller, input file, environment, or default | `var.environment` |
| Local value | An expression inside the module | `local.label` |
| Root output | An expression inside the root module | `terraform output label` |
| Child output | An expression inside the child module | `module.child.label` |

Reference: [Values in modules](https://developer.hashicorp.com/terraform/language/v1.12.x/values).

## Select a type

| Type | Example value | Rule |
| --- | --- | --- |
| `string` | `"dev"` | Text |
| `number` | `3` | Numeric value |
| `bool` | `true` | True or false |
| `list(string)` | `["web", "api", "web"]` | Ordered. Duplicates allowed. |
| `set(string)` | `toset(["web", "api"])` | Unique members. No numeric index. |
| `map(number)` | `{ web = 2, api = 3 }` | String keys. One element type. |
| `tuple([string, number])` | `["web", 2]` | Fixed positions with specified types |
| `object({ name = string, replicas = number })` | `{ name = "web", replicas = 2 }` | Named attributes with specified types |

Lists, sets, and maps are collection types. Tuples and objects are structural types.
A literal such as `["web", 2]` starts as a tuple.
Terraform can convert compatible values to satisfy a declared type.

Reference: [Type constraints](https://developer.hashicorp.com/terraform/language/v1.12.x/expressions/type-constraints).

## Use an object

**Excerpt:** Declare a group of related settings.

```hcl
variable "service" {
  type = object({
    name     = string
    replicas = number
    tags     = optional(map(string), {})
  })

  default = {
    name     = "api"
    replicas = 2
  }
}

locals {
  service_name = var.service.name
  copies       = var.service.replicas
  tags         = var.service.tags
}
```

**Expected:** `service_name` is `"api"`. `copies` is `2`. `tags` is an empty map.

## Distinguish null, unknown, and sensitive

| Value | Meaning | Example |
| --- | --- | --- |
| `null` | No value | Omit an optional resource argument |
| Unknown | Terraform will learn the value later | An ID displayed as `(known after apply)` |
| Sensitive | Terraform hides the value in normal output | A marked password variable |

`null` is not an empty string or an unknown value.
An explicit `null` can override a variable default when `nullable = true`.
With `nullable = false` and a default, a null input uses that default.
Without a usable default, a non-nullable variable rejects null.

The type keyword `any` asks Terraform to infer a suitable type.
It does not mean that every element of `list(any)` can retain a different type.

## Inputs and outputs: exam details

- A variable without a default requires a value.
- A `.tfvars` file assigns input values. It does not declare variables.
- Terraform automatically loads variable files for the root module, not child modules.
- A child receives values through arguments in its `module` block.
- `terraform output` reads root outputs from state. It does not refresh infrastructure.
- `terraform output -json` returns machine-readable values.
- `-raw` is useful for a single string, number, or boolean output.
- Sensitive outputs still require protection. `-raw` and `-json` can reveal their values.

References: [Input variables](https://developer.hashicorp.com/terraform/language/v1.12.x/values/variables)
and [output command](https://developer.hashicorp.com/terraform/cli/commands/output).
See [input precedence](terraform-variable-precedence-cheatsheet.md) for loading order.

## Self-test

1. Which type removes duplicates and has no numeric index?
2. Does a child module automatically receive the root's variables?
3. Does `sensitive = true` remove a value from state?
4. Is `(known after apply)` the same as `null`?

**Answers:** 1. A set. 2. No. Pass arguments. 3. No. 4. No.
