# Agentdots CI hosting recommendation

Recorded: 2026-10-26

Status: Recommendation for a small future improvement. This note does not
implement CI or provision infrastructure.

## Recommendation

Use a standard GitHub-hosted Linux runner for a small Agentdots CI workflow,
while continuing to run `./test.sh` locally. Keep the home Kubernetes cluster
as a separate learning project for when the time and learning objective fit.
CI is an optional safeguard for the existing workflow; continuing with local
checks until a convenient implementation window is reasonable.

The immediate goal is small, enjoyable improvements while certification study
and existing commitments take priority. The
[homelab and certification build plan](homelab-and-certification-build-plan.md)
owns the homelab schedule and its certification completion gate. This CI
recommendation can proceed independently of that deferred build.

## Separate the checks, workflow, and runner

| Piece | Purpose | Starting choice |
| --- | --- | --- |
| Repository checks | Define and verify expected behavior | Agentdots' existing `./test.sh` |
| CI workflow | Decide when to run the checks and report failures | A small GitHub Actions workflow |
| Runner | Supply the machine executing the job | A standard GitHub-hosted Linux runner |

Keep test logic in repository scripts and have CI call those scripts. GitHub
supports both hosted and self-hosted runners through workflow configuration.
A future home runner can execute the same `./test.sh`; changing runners may
still require adapting dependencies, permissions, and environment setup.
[GitHub runner selection](https://docs.github.com/en/actions/how-tos/write-workflows/choose-where-workflows-run/choose-the-runner-for-a-job)

## Small next step

Use the CI change as the first real Agentdots plan/build/review pilot:

1. Write a short brief with observable acceptance criteria.
2. Add one Linux job that checks out the repository, supplies its required
   tools, and runs `./test.sh` on pushes and pull requests.
3. Verify the isolated checks locally and observe a hosted run after publication.
   Record hosted execution as unverified until it actually runs.
4. Give a fresh reviewer the original brief and actual changes, then allow
   one correction round before reporting any remaining findings.

The CI job should run isolated regression checks. Machine drift checks through
`doctor.sh` stay local. Keep installation, desktop activation, and infrastructure
provisioning outside this test job, and preserve the existing secret-scan hook.

## Cost and later expansion

As checked on 2026-10-26, GitHub Free includes 2,000 hosted-runner minutes per
month for private repositories, shared across the account. Standard hosted
runners are free for public repositories. Larger runners have separate charges;
check the account's plan, existing usage, and current pricing before rollout.
[GitHub Actions billing](https://docs.github.com/en/billing/concepts/product-billing/github-actions)

When self-hosting becomes a useful learning objective, one VM or spare machine
can run a self-hosted runner. Kubernetes is an optional later hosting choice.
Self-hosting adds responsibility for the operating system, installed tools,
availability, and runner environment.
[GitHub self-hosted runners](https://docs.github.com/en/actions/concepts/runners/self-hosted-runners)

Revisit runner hosting when a concrete requirement appears, such as access to
a private lab network, a specific operating system, or hardware the hosted job
cannot provide. Build the cluster when cluster operations are the intended
learning project. Starting with portable checks and hosted CI preserves that
option while keeping the current improvement small.
