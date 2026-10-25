# Terraform Infrastructure as Code

**Associate 004 · Terraform 1.12 · Objectives 1a–1c**
| [Study map](terraform-associate-004-overview.md)

## The main idea

Infrastructure as Code (IaC) describes infrastructure in files.
Terraform compares the desired configuration with existing objects.
It proposes actions that bring those objects into the desired state.

| Term | Meaning | Example |
| --- | --- | --- |
| Configuration | Your description of the desired result | Two application instances |
| Provider | A plugin that communicates with an API | AWS, Azure, GitHub |
| Resource | An object Terraform manages | A network or repository |
| State | Terraform's record of managed objects | A resource address mapped to an object ID |
| Plan | Proposed actions | Add one instance |
| Apply | Execute the proposed actions | Create that instance |

Reference: [What is Terraform?](https://developer.hashicorp.com/terraform/intro)

## Declarative and imperative instructions

| Approach | Example | Who selects the operations? |
| --- | --- | --- |
| Imperative | Create a network. Then create a server. | The script author |
| Declarative | A server must exist in this network. | Terraform and its providers |

**Excerpt:** Declare an AWS network and a subnet.

```hcl
resource "aws_vpc" "lab" {
  cidr_block = "10.20.0.0/16"
}

resource "aws_subnet" "app" {
  vpc_id     = aws_vpc.lab.id
  cidr_block = "10.20.1.0/24"
}
```

The reference creates a dependency. Terraform creates the network before the subnet.
The order of the blocks in the file does not set the execution order.

## Why use IaC?

| Need | IaC benefit | Example |
| --- | --- | --- |
| Repeat an environment | Reuse configuration | Create a second test environment |
| Review a change | Use version control and plans | Review a proposed subnet change |
| Find the cause of a change | Keep configuration history | Find the commit that changed an instance size |
| Reduce manual differences | Use one declared configuration | Apply the same tags to each environment |
| Recover infrastructure | Reuse configuration and protected state | Rebuild infrastructure after a failure |
| Work as a team | Share code and remote state | Review code before another person applies it |

IaC does not back up application data. A database still needs its own backup process.
Reusing code does not copy the state of an existing environment.

## Multi-cloud does not mean identical resources

```text
One Terraform workflow
  ├── AWS provider       → AWS network
  ├── Azure provider     → Azure resource group
  └── GitHub provider    → GitHub repository
```

The workflow is consistent. The resource schemas remain provider-specific.
An `aws_instance` cannot create an Azure virtual machine.

| Deployment | Example |
| --- | --- |
| Multi-cloud | AWS application and Azure recovery infrastructure |
| Hybrid cloud | On-premises virtual machines and a public-cloud network |
| Service-agnostic workflow | Cloud infrastructure plus DNS and GitHub configuration |

Terraform needs a suitable provider and API access for each system.
Reference: [Terraform use cases](https://developer.hashicorp.com/terraform/intro/use-cases).

## Predict the next plan

```text
Configuration: two instances
Real objects:  one managed instance
Plan:          create the missing instance

Configuration: two instances
Real objects:  two matching managed instances
Plan:          no changes
```

Stable configuration should produce no changes when the real objects already match.
External changes, changing input data, or provider behavior can produce a new plan.

## Self-test

1. Does Terraform use file order to select resource order?
2. Can one AWS resource block create an Azure resource?
3. Does version-controlled configuration replace a database backup?
4. Which artifact lets a reviewer inspect proposed infrastructure changes?

**Answers:** 1. No. It uses dependencies. 2. No. 3. No. 4. The plan.
