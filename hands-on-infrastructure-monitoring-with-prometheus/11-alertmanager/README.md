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
  ...

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

### Questions
1. What happens to the notifications if there's a network partition between Alertmanager instances in the same cluster?

In the case of a network partition, each side of the partition will send notifications for the alerts they are aware of: in a clustering failure scenario, it's better to receive duplicate notifications for an issue than to not get any at all.

2. Can an alert trigger multiple receivers? What is required for that to happen?

By setting continue to true on a route, it will make the matching process keep going through the routing tree until the next match, thereby allowing multiple receivers to be triggered.

3. What's the difference between group_interval and repeat_interval?

The group_interval configuration defines how long to wait for additional alerts in a given alert group (defined by group_by) before sending an updated notification when a new alert is received; repeat_interval defines how long to wait until resending notifications for a given alert group when there are no changes.

4. What happens if an alert does not match any of the configured routes?

The top-level route, also known as the catch-all or fallback route, will trigger a default receiver when incoming alerts aren't matched in other sub-routes.

5. If the notification provider you require is not supported natively by Alertmanager, how can you use it?

The webhook integration allows Alertmanager to issue an HTTP POST request with the JSON payload of the notification to a configurable endpoint. 

6. When writing custom notifications, how are CommonLabels and CommonAnnotations populated?

The `CommonLabels` field is populated with the labels that are common to all alerts in the notification. The `CommonAnnotations` field does exactly the same, but for annotations.

7. What can you do to ensure that the full alerting path is working from end to end?

A good approach is to use a deadman's switch alert: create an alert that is guaranteed to always be firing, and then configure Alertmanager to route that alert to a (hopefully) external system that will be responsible for letting you know whether it ever stops receiving notifications.
