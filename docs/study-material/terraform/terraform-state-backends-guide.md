# Terraform State and Backends

**Associate 004 · Terraform 1.12 · Objectives 2d, 6a–6c**
| [Study map](terraform-associate-004-overview.md)

## Know what state records

```text
Configuration address       State binding        Real object
aws_vpc.lab                 id = vpc-example      AWS network
```

State connects resource addresses to real objects.
It also records resource attributes, dependency metadata, and provider associations.
Cached attributes help Terraform work with large configurations.
State is not the desired configuration and is not a live inventory of every cloud resource.

| Artifact | Purpose |
| --- | --- |
| `.tf` files | Describe the desired configuration |
| Resource state | Record Terraform's known objects and their attributes |
| Saved plan | Record proposed actions for a later apply |
| `.terraform.lock.hcl` | Select provider versions and verify packages |
| `.terraform/` | Store local initialization data and downloaded dependencies |

Deleting state does not delete the real resources.
Terraform can lose their bindings and propose duplicate creation.

Reference: [Purpose of state](https://developer.hashicorp.com/terraform/language/v1.12.x/state/purpose).

## Select a storage location

| Storage | Resource state location | Execution location |
| --- | --- | --- |
| Default local backend | `terraform.tfstate` in the working directory | Local machine |
| S3, Azure Storage, or GCS backend | Remote storage | Usually the machine running the CLI |
| HCP Terraform with remote execution | HCP workspace | HCP workers |
| HCP Terraform with local execution | HCP workspace | Local machine |

Remote state storage does not automatically mean remote execution.
Backend types are built into Terraform. They are not installed as provider plugins.

**Excerpt:** Store local state at a different path.

```hcl
terraform {
  backend "local" {
    path = "state/lab.tfstate"
  }
}
```

The local backend supports locking on the local system.
Local files are inconvenient for multiple people on different machines.

Reference: [Local backend](https://developer.hashicorp.com/terraform/language/v1.12.x/backend/local).

## Configure a remote backend

**Excerpt:** This requires an existing S3 bucket and suitable AWS permissions.

```hcl
terraform {
  backend "s3" {
    bucket       = "example-team-tfstate"
    key          = "exam/dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
```

- Create the storage before initialization. This backend block does not create its bucket.
- Use one backend block per configuration.
- Do not use `var`, `local`, or resource references inside backend settings.
- Do not combine `backend` and `cloud` in the same configuration.
- Supply backend credentials through its supported environment or credential mechanism.
- Provider connection settings do not configure backend authentication.
- Backend settings can enter initialization files and saved plans. Keep secrets out of them.

References: [Backend configuration](https://developer.hashicorp.com/terraform/language/v1.12.x/backend)
and [S3 backend](https://developer.hashicorp.com/terraform/language/v1.12.x/backend/s3).

## Supply partial configuration

**Excerpt:** Keep the backend type in `main.tf`.

```hcl
terraform {
  backend "s3" {}
}
```

Put non-secret settings in `state.s3.tfbackend`:

```hcl
bucket       = "example-team-tfstate"
key          = "exam/dev/terraform.tfstate"
region       = "us-east-1"
encrypt      = true
use_lockfile = true
```

```bash
terraform init -backend-config=state.s3.tfbackend
```

The settings file contains arguments, not a second `terraform` block.

## Migrate or reconfigure

| Command | Effect |
| --- | --- |
| `terraform init -migrate-state` | Reinitialize and copy existing state to the new backend after confirmation |
| `terraform init -reconfigure` | Accept the current backend settings without migrating existing state |

For a migration, stop other writers first. Keep a protected backup of the current state.
Change the backend settings. Run initialization with `-migrate-state`.
Then inspect state and run a plan to check the bindings.
`-reconfigure` is not a state-copy command.
HCP `cloud` integration has its own initialization migration flow. See the [HCP guide](terraform-hcp-guide.md).

Reference: [Initialization](https://developer.hashicorp.com/terraform/cli/commands/init).

## Understand state locking

```text
Run A acquires the state lock → writes state → releases the lock
Run B cannot write the same state while Run A holds that lock
```

Locking prevents competing writers from corrupting state.
Support depends on the backend and its configuration.
Encryption, version history, and locking solve different problems.

```bash
terraform plan -lock-timeout=60s
terraform force-unlock LOCK_ID
```

The second command is for a stale lock that you own.
First confirm that the original run has stopped.
It does not stop another process or repair damaged state.
Avoid `-lock=false` for ordinary team work.

Reference: [State locking](https://developer.hashicorp.com/terraform/language/v1.12.x/state/locking).

## Recognize CLI workspaces

```bash
terraform workspace list
terraform workspace new dev
terraform workspace select default
terraform workspace show
```

A CLI workspace selects a separate state for the same working configuration.
Creating one does not copy infrastructure or the current workspace's state.
With local storage, non-default states are under `terraform.tfstate.d/<workspace>/`.
Use `terraform.workspace` to read the selected workspace name in configuration.
CLI workspaces do not provide separate credentials or access-control boundaries by themselves.

Reference: [CLI workspaces](https://developer.hashicorp.com/terraform/language/v1.12.x/state/workspaces).

## Self-test

1. Does an S3 backend make AWS execute Terraform for you?
2. Does the dependency lock file prevent concurrent state writes?
3. Which initialization flag copies state to a new backend?
4. Can backend settings use `var.bucket_name`?

**Answers:** 1. No. 2. No. 3. `-migrate-state`. 4. No.
