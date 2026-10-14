# Terraform Variable Precedence (Associate 004)

When Terraform finds a value for the same variable in several places, the one
**loaded last wins**.

## The order (lowest → highest priority)

```text
1. default in the variable block      (variables.tf)        ← weakest
2. Environment variables              TF_VAR_<name>
3. terraform.tfvars                    (auto-loaded)
4. terraform.tfvars.json               (auto-loaded)
5. *.auto.tfvars / *.auto.tfvars.json  (auto-loaded, alphabetical order)
6. -var and -var-file on the CLI       (in the order typed) ← strongest
```

If none of these sets a value and there's no `default`, Terraform **prompts**
you interactively (or errors with `-input=false`).

**Mnemonic, weakest to strongest:** **D**on't **E**ver **T**rust **A**
**C**ommand: **D**efault, **E**nv, **T**fvars, **A**uto.tfvars, **C**LI

## Each source

| # | Source | Example | Remember |
| --- | --- | --- | --- |
| 1 | `default` | `variable "region" { default = "us-east-1" }` | Fallback only. Any other source overrides it. |
| 2 | Environment | `export TF_VAR_region=us-west-2` | Prefix must be `TF_VAR_`; the rest matches the variable name. Common in CI and for secrets. |
| 3 | `terraform.tfvars` | `region = "us-west-2"` | Loaded automatically, but **only this exact name**. |
| 4 | `terraform.tfvars.json` | `{ "region": "us-west-2" }` | Same as #3 in JSON; loaded after it. |
| 5 | `*.auto.tfvars` | `prod.auto.tfvars` | Loaded automatically; several files load alphabetically, so the last one alphabetically wins. |
| 6 | CLI | `terraform apply -var="region=eu-west-1"` or `-var-file=prod.tfvars` | Highest priority. When you pass several, the **last one typed** wins. |

## Picking a var file on the command line

Keep one `.tfvars` file per environment and choose it at run time:

```text
aws/
├── main.tf
├── variables.tf
├── testing.tfvars     # instance_type = "t3.micro"
└── prod.tfvars        # instance_type = "m5.large"
```

```bash
terraform plan    -var-file="testing.tfvars"
terraform apply   -var-file="testing.tfvars"
terraform destroy -var-file="testing.tfvars"
```

- **Pass the same file to every command.** If `apply` doesn't get the same
  `-var-file` as `plan`, it uses different values. Alternatively, save the
  plan and apply that; it already contains the values:

  ```bash
  terraform plan -var-file="testing.tfvars" -out=tfplan
  terraform apply tfplan
  ```

- **It overrides the auto-loaded files** (`terraform.tfvars`,
  `*.auto.tfvars`), which still load first.
- **You can stack files.** In
  `-var-file="common.tfvars" -var-file="prod.tfvars"`, values in
  `prod.tfvars` win for any key both files set.
- The path is relative to the directory you run Terraform in. The quotes are
  optional unless the path has spaces.

## Exam traps

- **A file named `prod.tfvars` is not loaded automatically.** You must pass
  `-var-file=prod.tfvars`. Only `terraform.tfvars`, `terraform.tfvars.json`,
  and `*.auto.tfvars(.json)` are auto-loaded.
- **`-var-file` and `-var` have the same priority level.** Among them, order on
  the command line decides: in `-var-file=a.tfvars -var="region=x"`, the `-var`
  wins because it comes later.
- **Environment variables are near the bottom.** They lose to every tfvars
  file, even though they feel "global".
- **`variables.tf` is just a name for a file.** It holds declarations; its
  `default` is the weakest value.

## Quick self-test

1. `default = "a"`, `TF_VAR_x=b`, `terraform.tfvars` sets `"c"`. Result? → `c`
2. `terraform.tfvars` sets `"c"`, `z.auto.tfvars` sets `"d"`. Result? → `d`
3. `a.auto.tfvars` sets `"1"`, `b.auto.tfvars` sets `"2"`. Result? → `2`
4. `terraform.tfvars` sets `"c"`, CLI has `-var="x=e"`. Result? → `e`
5. Does `dev.tfvars` load without a flag? → No; use `-var-file=dev.tfvars`
6. No value anywhere and no default. What happens? → Terraform prompts for it
7. You ran `plan -var-file="testing.tfvars"`, then plain `terraform apply`. Which values does `apply` use? → Not `testing.tfvars`; it re-plans with only the auto-loaded files
8. `-var-file="common.tfvars" -var-file="prod.tfvars"`, both set `region`. Which wins? → `prod.tfvars` (last one typed)
