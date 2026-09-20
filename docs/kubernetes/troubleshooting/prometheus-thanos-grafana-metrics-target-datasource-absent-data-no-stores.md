# 🔍 Troubleshooting Guide: Prometheus Metrics Missing in Grafana via Thanos

## 🎯 Symptoms

- Grafana dashboards show no data or fail to autocomplete metrics like `http_requests_total`

- Thanos Querier returns no results

- `/stores` endpoint returns HTML or empty response

## 🛠 Step 1: Validate the App is Exposing Metrics

Use a debug pod to verify the target app is exposing metrics internally.

```bash
kubectl run debug --rm -it --image=busybox:1.28 -n <app-namespace> --restart=Never -- sh
```

From inside:
```bash
wget -qO- http://<service-name>:<port>/metrics | grep http
```

✅ If metrics (e.g., promhttp_metric_handler_requests_total) appear, the app is healthy.

## 🛠 Step 2: Confirm Prometheus is Scraping the Service

