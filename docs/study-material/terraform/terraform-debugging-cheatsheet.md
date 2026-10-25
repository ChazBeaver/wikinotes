# Terraform Debugging

**Associate 004 · Terraform 1.12 · Objective 7c**
| [Study map](terraform-associate-004-overview.md)

## Match the failure to the tool

| Symptom | First check |
| --- | --- |
| Invalid syntax or argument | Run `terraform validate` after initialization |
| Inconsistent style | Run `terraform fmt -check` |
| Missing plugin or module | Run `terraform init` |
| Conflicting provider versions | Inspect requirements with `terraform providers` |
| An unexpected resource change | Read `terraform plan` and the relevant state object |
| API authentication failure | Check the provider's credential source and permissions |
| State lock error | Check whether another run is active |
| Provider crash or unclear API behavior | Enable diagnostic logging |

Verbose logs add detail. They do not correct the configuration or credentials.

## Enable logs for one command

Run this in an initialized lab directory:

```bash
TF_LOG=DEBUG TF_LOG_PATH=./terraform-debug.log terraform plan
```

These environment assignments apply only to that command.
`TF_LOG_PATH` selects a file. The file is appended to across runs.
`TF_LOG_PATH` alone does not enable logging.

| Level | Detail |
| --- | --- |
| `ERROR` | Errors |
| `WARN` | Warnings and errors |
| `INFO` | General progress and higher-severity messages |
| `DEBUG` | Diagnostic detail |
| `TRACE` | Most detail |

`TF_LOG=JSON` requests JSON-formatted logs at TRACE detail.
Treat the diagnostic format as unstable. Do not make application logic depend on it.

Reference: [Terraform logging](https://developer.hashicorp.com/terraform/internals/v1.12.x/debugging).

## Enable logs for several commands

```bash
export TF_LOG=TRACE
export TF_LOG_PATH=./terraform-trace.log
terraform plan
unset TF_LOG
unset TF_LOG_PATH
```

Without `TF_LOG_PATH`, Terraform writes diagnostic logs to standard error.
Keep logs out of version control. They can contain secret values and request details.

## Separate Core and provider detail

**Alternative:** Select independent log levels.

```bash
unset TF_LOG
TF_LOG_CORE=ERROR TF_LOG_PROVIDER=TRACE terraform plan
```

`TF_LOG_CORE` controls Terraform Core logs.
`TF_LOG_PROVIDER` controls provider logs.
Use these when the failure is easier to isolate by component.

## Read a failure in order

1. Read the error summary.
2. Find the resource address and source line.
3. Check whether failure occurred during initialization, validation, planning, or apply.
4. Check the related variable, provider, backend, or module.
5. Enable logs if the normal error lacks sufficient detail.
6. Correct the cause.
7. Run a new plan.

After a partial apply, some resources can already exist.
Terraform records completed changes when possible.
A new plan identifies remaining work. Repeating apply is not an automatic rollback.

Reference: [Troubleshooting workflow](https://developer.hashicorp.com/terraform/tutorials/configuration-language/troubleshooting-workflow).

## Self-test

1. Which log level provides the most detail?
2. Does `TF_LOG_PATH` alone enable logs?
3. Do logs go to standard output or standard error by default?
4. Should a diagnostic log be committed with the configuration?

**Answers:** 1. `TRACE`. 2. No. 3. Standard error. 4. No.
