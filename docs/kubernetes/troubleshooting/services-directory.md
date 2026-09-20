🔍 Troubleshooting Service Discovery
Use this command inside a pod to view environment variables automatically injected by Kubernetes for Services in the same namespace. It helps verify that:

```bash
env | grep SERVICE
```

The pod started after the Service was created.

The pod correctly received service discovery variables (e.g., MYAPP_SERVICE_HOST).

📌 Use it when: You want to confirm that the pod is aware of available services via environment variables.

✅ Note: This method is legacy — prefer DNS-based service discovery (e.g., curl myservice:port) for dynamic and up-to-date routing.
