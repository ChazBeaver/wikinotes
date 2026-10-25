# Terraform Sensitive Data and Ephemeral Values

**Associate 004 · Terraform 1.12 · Objective 4h**
| [Study map](terraform-associate-004-overview.md)

## Redaction and storage are separate

| Mechanism | Purpose | Can the value remain in state or a saved plan? |
| --- | --- | --- |
| `sensitive = true` | Hide a value in normal CLI/UI output | Yes |
| `ephemeral = true` | Omit a variable or child output from state and plans | No, for that ephemeral value |
| `ephemeral` resource | Obtain or generate temporary data | Terraform omits that resource's values |
| Write-only resource argument | Send a value to a provider without storing that argument | Terraform omits that argument |

Sensitive values can propagate through expressions.
An output that exposes a sensitive value must be marked sensitive.
Redaction does not encrypt state.
`terraform output -raw` and `-json` can reveal sensitive outputs.

Reference: [Sensitive data](https://developer.hashicorp.com/terraform/language/v1.12.x/manage-sensitive-data).

## Mark a temporary input

**Excerpt:** Declare a secret without including a secret value.

```hcl
variable "db_password" {
  type      = string
  sensitive = true
  ephemeral = true
}
```

Supply the value through an approved secret source at run time.
Both settings are useful: one controls display, and the other controls persistence.
Marking a value ephemeral does not erase older state versions that already contain it.

## Select a permitted destination

| Destination for an ephemeral value | Allowed? |
| --- | --- |
| Provider configuration | Yes |
| A provider-supported write-only argument | Yes |
| Another ephemeral resource | Yes |
| An ephemeral variable or child-module output | Yes |
| A local expression used only in permitted ephemeral contexts | Yes |
| A provisioner or connection configuration | Yes |
| A normal stored resource argument | No |
| A root-module output | No |
| Resource instance keys that Terraform must persist | No |

Ephemeral variables and resources require Terraform 1.10 or later.
Write-only arguments require Terraform 1.11 or later.
Both are available within the exam's Terraform 1.12 scope.
The selected provider must also support the resource or argument.

## Pass a value to a write-only argument

**Excerpt:** Other database arguments and provider setup are omitted.

```hcl
resource "aws_db_instance" "app" {
  identifier = "exam-app"

  password_wo         = var.db_password
  password_wo_version = 1
}
```

The provider receives `password_wo`. Terraform does not store that argument in state or the plan.
The normal `password_wo_version` value is stored.
Increase the version when you intend to update the password.
Terraform cannot compare old and new password values because it does not retain them.

A write-only argument can also accept a normal value.
It does not remove copies of that value stored by another resource or output.
The `_wo` suffix is a provider naming convention, not a suffix you can add to any argument.

Reference: [Write-only arguments](https://developer.hashicorp.com/terraform/language/v1.12.x/manage-sensitive-data/write-only).

## Generate temporary data

**Excerpt:** Requires a Random provider version that supports ephemeral resources.

```hcl
ephemeral "random_password" "session" {
  length  = 24
  special = false
}
```

Reference the result as `ephemeral.random_password.session.result`.
Use a permitted destination, such as a write-only argument.
Terraform does not retain the generated value for the next run.
If later access is required, store the secret in a suitable external secret service.

Reference: [Ephemeral resources](https://developer.hashicorp.com/terraform/language/v1.12.x/manage-sensitive-data/ephemeral).

## Understand Vault's role

```text
Workload authentication → Vault → temporary credential → provider → API
```

Vault can store secrets or issue credentials with a limited lifetime.
Terraform uses the Vault provider to interact with Vault.
Vault authorization policies determine what the caller can access.

**Excerpt:** A traditional data-source read still has a state risk.

```hcl
provider "vault" {
  address = "https://vault.example.com"
}

data "vault_kv_secret_v2" "app" {
  mount = "secret"
  name  = "exam/app"
}
```

The provider requires authentication from an approved external source.
Fetching a value from Vault does not automatically make it ephemeral.
A normal data source can place returned secrets in state.
Short credential lifetimes do not remove the need to protect state.

Reference: [Vault provider security](https://registry.terraform.io/providers/hashicorp/vault/latest/docs).

## Protect all copies

- Keep secret values out of configuration and version control.
- Keep state, saved plans, and diagnostic logs out of version control.
- Use access controls and encryption for remote state.
- Protect older state snapshots and backups.
- Prefer temporary workload credentials when the platform supports them.
- Treat `TF_VAR_` as input transport. It does not encrypt or automatically redact a value.

## Self-test

1. Does `sensitive` keep a password out of state?
2. Can a root output be ephemeral?
3. Why does a write-only password often have a separate version argument?
4. Does a normal Vault data source guarantee that no secret enters state?

**Answers:** 1. No. 2. No. 3. To signal an update without comparing stored passwords. 4. No.
