# Terraform Associate 004: Study Map

**Exam target:** Terraform 1.12. **Reviewed:** 2026-10-14.
HashiCorp defines eight exam sections. Cloud-provider-specific knowledge is not required.
See the [official objectives](https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-review-004).

## Start here

1. Read the [final cram sheet](terraform-associate-004-cheatsheet.md).
2. Identify a topic you cannot explain.
3. Open its guide below.
4. Read the examples.
5. Answer the self-test before you read the answers.

The guides use short sentences, direct instructions, and consistent terms.
This follows the intent of [ASD-STE100](https://www.asd-ste100.org/STE_faq.html).
Terraform names remain unchanged. This is not a certified STE translation.

## Find each exam objective

| Objectives | Know how to... | Read |
| --- | --- | --- |
| 1a–1c | Explain IaC, its benefits, and multi-cloud use | [IaC](terraform-iac-overview.md) |
| 2a–2c | Install, select, configure, and combine providers | [Providers and versions](terraform-providers-versions-guide.md) |
| 2d | Explain the purpose of state | [State and backends](terraform-state-backends-guide.md) |
| 3a–3g | Write, initialize, validate, plan, apply, destroy, and format | [Core workflow](terraform-core-workflow.md) |
| 4a | Select a resource or data source | [Block types](terraform-block-types-cheatsheet.md) |
| 4b, 4f | Reference resources and control dependencies | [Dependencies and lifecycle](terraform-dependencies-lifecycle-guide.md) |
| 4c–4d | Use variables, outputs, and complex types | [Variables and types](terraform-variables-types-outputs-guide.md) |
| 4c | Select the winning input value | [Variable precedence](terraform-variable-precedence-cheatsheet.md) |
| 4e | Use expressions and functions | [Expressions](terraform-expressions-functions-cheatsheet.md) |
| 4g | Select and use custom conditions | [Custom conditions](terraform-custom-conditions-guide.md) |
| 4h | Protect secrets, including Vault use | [Sensitive data](terraform-sensitive-data-guide.md) |
| 5a–5d | Source, call, and version modules | [Modules](terraform-modules-guide.md) |
| 6a–6c | Configure storage and explain locking | [State and backends](terraform-state-backends-guide.md) |
| 6d, 7a–7b | Handle drift, import resources, and inspect state | [State operations](terraform-state-operations-guide.md) |
| 7c | Enable and use verbose logs | [Debugging](terraform-debugging-cheatsheet.md) |
| 8a–8d | Use HCP Terraform, projects, and collaboration features | [HCP Terraform](terraform-hcp-guide.md) |

The [official learning path](https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-study-004)
provides further exercises for these objectives.

## Use the examples correctly

| Label | Meaning |
| --- | --- |
| **Local lab** | A complete example. Use a separate, empty directory. |
| **Excerpt** | Part of a configuration. Other settings or resources are required. |
| **Console** | An expression to enter in `terraform console`. |
| **Expected** | The result to compare with your result. |

The local labs use the built-in `terraform_data` resource where practical.
They do not require a cloud account. Each lab has its own state.

Cloud examples explain Terraform behavior. Replace example names before real use.
An `apply` command can create billable resources when you use a cloud provider.

Terraform CLI versions and provider versions are separate.
Provider version constraints in examples are teaching examples, not upgrade recommendations.

## Check your readiness

| Exercise | Expected skill |
| --- | --- |
| Run the core-workflow lab | Explain each command and plan symbol |
| Run the modules lab | Pass a root input to a child and return an output |
| Change a `for_each` key | Predict the resource addresses and replacement effects |
| Rename a resource with `moved` | Keep its existing state binding |
| Compare normal and refresh-only plans | Distinguish infrastructure changes from state updates |
| Explain an HCP workspace | Identify its state, variables, runs, and access controls |
| Explain `sensitive` and `ephemeral` | Identify what can remain in state |

Use the [official sample questions](https://developer.hashicorp.com/terraform/tutorials/certification-004/associate-questions-004)
to learn the question formats. They are not a complete practice exam.

The [AWS tags guide](terraform-aws-tags-guide.md) is optional practical material.
Study the eight exam sections first.
