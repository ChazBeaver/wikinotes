```bash
kubectl get -n monitoring pods --no-headers | awk '{print $1}' | while read name; do                             ✔  84  19:32:54 
  echo "== $name =="
  kubectl get pod "$name" -n monitoring -o json | jq -r '
    "Containers:",
    .spec.containers[].name,
    "InitContainers:",
    (.spec.initContainers[]?.name // "None"),
    "EphemeralContainers:",
    (.spec.ephemeralContainers[]?.name // "None"),
    ""
  '
done
```
