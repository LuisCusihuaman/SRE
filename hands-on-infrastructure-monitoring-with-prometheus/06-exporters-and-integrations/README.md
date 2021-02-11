# Exporters and integrations

### Step 1 - Setup MINIKUBE

Start a new minikube instance with the following specifications:

```bash
minikube start \
  --cpus=2 \
  --memory=2048 \
  --kubernetes-version="v1.14.0" \
  --vm-driver=virtualbox
```

Deploy the Prometheus Operator and validate the successful deploy as follows:

```bash
kubectl apply -f ./operator/bootstrap/
kubectl rollout status deployment/prometheus-operator -n monitoring
```

Use the Prometheus Operator to deploy Prometheus and ensure the deploy was successful like so:

```bash
kubectl apply -f ./operator/deploy/

kubectl rollout status statefulset/prometheus-k8s -n monitoring
```

Add ServiceMonitors as shown in the following code, which will configure Prometheus jobs:

```bash
kubectl apply -f ./operator/monitor/
kubectl get servicemonitors --all-namespaces
```

### Deploy cAdvisor

```bash
kubectl apply -f ./cadvisor/cadvisor-daemonset.yaml
kubectl apply -f ./cadvisor/cadvisor-servicemonitor.yaml
```

### Deploy kube-state-metrics

As access to the Kubernetes API is required, the role-based access control (RBAC) configuration for this deploy is quite
extensive, which includes a Role, a RoleBindintg, a ClusterRole, a ClusterRoleBinding, and a ServiceAccount

```bash
kubectl apply -f ./kube-state-metrics/kube-state-metrics-rbac.yaml
kubectl apply -f ./kube-state-metrics/kube-state-metrics-deployment.yaml
kubectl apply -f ./kube-state-metrics/kube-state-metrics-service.yaml
```

### Deploy a Pushgateway

By using Pushgateway, Prometheus does not scrape an application instance directly, which prevents having the up metric
as a proxy for health monitoring.

```bash
kubectl apply -f ./pushgateway/pushgateway-deployment.yaml
kubectl apply -f ./pushgateway/pushgateway-service.yaml 
kubectl apply -f ./pushgateway/pushgateway-servicemonitor.yaml
```

You may now validate the web interface for Pushgateway using the following command:

```bash
minikube service pushgateway-service -n monitoring
```

Now that we have our monitoring infrastructure in place, we need to simulate a batch job to validate our setup.

```yaml
apiVersion: batch/v1beta1
kind: CronJob
metadata:
  name: batchjob
spec:
  schedule: "*/1 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: batchjob
              image: kintoandar/curl:7.61.1
              args:
                - -c
                - 'echo "batchjob_example $(date +%s)" | curl -s --data-binary @- http://pushgateway-service.monitoring.svc.cluster.local:9091/metrics/job/batchjob/app/example/squad/yellow'
          restartPolicy: OnFailure
```

```bash
kubectl apply -f ./pushgateway/batchjob-cronjob.yaml
```

Delete environment:

```bash
minikube delete
```