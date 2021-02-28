# Alert Manager

Alertmanager is a fundamental component of the Prometheus stack, the Operator is also able to manage its instances.
Besides taking care of an Alertmanager cluster, the Operator is also responsible for managing the configuration of
recording and alerting rules.

### Step 1 - Setup env

```bash
minikube start \
  --cpus=2 \
  --memory=3072 \
  --kubernetes-version="v1.14.0" \
  --vm-driver=virtualbox
```

Prometheus Operator components:

```bash
kubectl apply -f ./bootstrap/
kubectl -n monitoring rollout status deployment/prometheus-operator
```

Prometheus cluster:

```bash
kubectl apply -f ./prometheus/
kubectl rollout status statefulset/prometheus-k8s -n monitoring
```

targets:

```bash
kubectl apply -f ./services/
kubectl get servicemonitors --all-namespaces
```

After the Kubernetes test environment is running, we can proceed with Alertmanager-specific configurations and alert
rules.

For the Alertmanager configuration, since we might want to add sensitive information such as email credentials or a
pager token, we are going to use a Kubernetes secret.

```bash
kubectl apply -f ./alertmanager/alertmanager-serviceaccount.yaml
kubectl apply -f ./alertmanager/alertmanager-configuration.yaml
```

the minimal configuration that is encoded in the secret:

```yaml
global:

route:
  receiver: "null"
  group_by:
    - job
  group_interval: 3m
  repeat_interval: 3h
  routes:
    - match:
        alertname: deadmanswitch
      receiver: "null"

receivers:
  - name: "null"
```

To ensure that the Prometheus instances can collect metrics from the newly created Alertmanagers, we'll add a new
Service and ServiceMonitor:

```bash
kubectl apply -f ./alertmanager/alertmanager-service.yaml
kubectl apply -f ./alertmanager/alertmanager-servicemonitor.yaml
```

Now, we can proceed with the deployment and get the AlertManager Operator to do the heavy lifting for us.

```bash
kubectl apply -f ./alertmanager/alertmanager-deploy.yaml
kubectl rollout status statefulset/alertmanager-k8s -n monitoring
```

It's now time to add the alerting rules:

```yaml
...
kind: PrometheusRule
...
spec:
  groups:
    - name: exporter-down
      rules:
        - alert: AlertmanagerDown
          annotations:
            description: Alertmanager is not being scraped.
            troubleshooting: https://github.com/kubernetes-monitoring/kubernetes-mixin/blob/master/runbook.md
          expr: |
            absent(up{job="alertmanager-service",namespace="monitoring"} == 1)
          for: 5m
          labels:
            severity: page
  ...```

```

```bash
  kubectl apply -f ./alertmanager/alerting-rules.yaml
```

Finally, you can access the web interface of Prometheus and Alertmanager:

```bash
minikube service alertmanager-service -n monitoring
minikube service prometheus-service -n monitoring

# FOR DELETE ALL:
minikube delete
```
