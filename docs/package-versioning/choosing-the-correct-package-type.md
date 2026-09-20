CPU Architecture: Correct Package Version

Run this command on your Linux server to check your architecture:

```bash
  uname -m
```
Then match the output:

| `uname -m` Output | Use This File                           |
| ----------------- | --------------------------------------- |
| `x86_64`          | `kustomize_v5.6.0_linux_amd64.tar.gz`   |
| `aarch64`         | `kustomize_v5.6.0_linux_arm64.tar.gz`   |
| `ppc64le`         | `kustomize_v5.6.0_linux_ppc64le.tar.gz` |
| `s390x`           | `kustomize_v5.6.0_linux_s390x.tar.gz`   |

