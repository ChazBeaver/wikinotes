# Locate all git branches within a main directory


## Assume the branch name is 'dev' follow the example below

```bash
for d in $(find . -type d -name .git); do
  repo=$(dirname "$d")
  if git -C "$repo" branch --list | grep -qE '(^|\s)dev$'; then
    echo "dev branch found in: $repo"
  fi
done
```
