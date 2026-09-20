# Restart All Workloads in All Namespaces

Below is a command that will restart all workloads across all namespaces in a cluster

```bash
for ns in $(kubectl get ns -o jsonpath='{.items[*].metadata.name}'); do                                                    
  for kind in deploy daemonset statefulset; do
    kubectl get "${kind}" -n "${ns}" -o name | xargs -I {} kubectl rollout restart {} -n "${ns}"
  done
done

```
