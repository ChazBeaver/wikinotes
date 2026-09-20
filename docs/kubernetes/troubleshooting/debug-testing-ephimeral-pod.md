🐞 Debugging Pod (Ephemeral) + Service Env Check
Use the following command to create a temporary debug pod in your namespace:

```bash
kubectl run debug --rm -it --restart=Never --image=busybox:1.28 -- sh
```

> --rm: Deletes the pod automatically after exit
> 
> -it: Interactive terminal
> 
> --restart=Never: Runs as a one-off pod (not managed by a controller)
> 
> --image=busybox:1.28: Lightweight image with basic tools
> 
> -- sh: Opens a shell inside the container

📝 Note
Often times, the pod will not remove itself properly from existence after exiting; in the event this happens, run the following example command:

```bash
kubectl delete po debug --force --grace-period=0
```
