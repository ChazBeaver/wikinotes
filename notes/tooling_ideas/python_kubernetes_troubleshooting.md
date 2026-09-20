• Python-based local Kubernetes troubleshooting dashboard.

  - Runs as a local web app (Flask/FastAPI) on localhost:<port>, talks to the cluster via kubectl/Kubernetes Python client (no in-cluster deployment required).
  - Core goal: simplify troubleshooting/monitoring of scheduling and stateful workloads (e.g., StatefulSet migrations) by exposing key config and status in one place.
  - Must show, per volume/PVC/PV: retention policy (Retain/Delete/Recycle), bound status, storage class, namespace, and related workload (StatefulSet/Deployment).
  - Must show, per pod/workload: node, affinities, anti-affinities, tolerations, relevant node taints, and any PodDisruptionBudgets that apply.
  - UI requirement: clear, filterable tables/views for volumes, pods, nodes, and PDBs, with obvious relationships (e.g., clicking a StatefulSet shows its pods, volumes, node
    constraints).

  - Designed to be read-only at first (no mutating cluster state), focused on surfacing scheduling/retention constraints for faster root cause analysis.
