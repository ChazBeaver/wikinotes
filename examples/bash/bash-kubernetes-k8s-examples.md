# Bash Kubernetes Examples

## Pipe Returned Pattern Into The Next Command

```bash
k get all | grep <pattern> | awk '{print $1}' | xargs -I{} kubectl get {}
```


## Get All SVC Ports with SVC Names Identified

```bash
kubectl get svc --no-headers | awk '{print $1}' | while read svc; do echo "=== $svc ==="; kubectl get svc "$svc" -o yaml | grep port: -A 8 -B 2; echo; done
```

## Pass Two Variables to Custom Status (SAFEST METHOD)
### loop with input redirection:

#### Single Line
```bash
while read po podstatus; do echo "=== $po | Status: $podstatus ==="; kubectl get po "$po" -o yaml | grep "name: http" -B3 -A5; echo; echo; done < <(kubectl get po --no-headers | awk '{print $1, $3}')
```

#### Multi Line
```bash
while read po podstatus; do
  echo "=== $po | Status: $podstatus ==="
  kubectl get po "$po" -o yaml | grep "name: http" -B3 -A5
  echo
  echo
done < <(kubectl get po --no-headers | awk '{print $1, $3}')
```

### This works in both zsh and bash because input redirection doesn't fork a subshell in the same way.


## Delete All Pods FORCEFULLY in a given Namespace
```bash
kubectl get po --no-headers -n default | awk '{print $1}' | while read po; do echo "=== $po ==="; kubectl delete po "$po" -n default --force --grace-period=0; echo; done
```
