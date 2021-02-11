# Instructions 

```bash
minikube delete
```

```bash
minikube start \
  --cpus=2 \
  --memory=2048 \
  --kubernetes-version="v1.14.0" \
  --vm-driver=virtualbox
```

```bash
kubectl apply -f 01-monitoring-namespace.yaml
kubectl apply -f 02-prometheus-configmap.yaml
kubectl apply -f 03-prometheus-deployment.yaml
```

```bash
kubectl rollout status deployment/prometheus-deployment -n monitoring
kubectl logs --tail=20 -n monitoring -l app=prometheus
```

```bash
kubectl apply -f 04-prometheus-service.yaml
minikube service prometheus-service -n monitoring
```

```bash
kubectl apply -f 05-hey-deployment.yaml
```

```bash
kubectl rollout status deployment/hey-deployment -n monitoring
kubectl logs --tail=20 -n monitoring -l app=hey
```

```bash
kubectl apply -f 06-hey-service.yaml
minikube service hey-service -n monitoring
```

```bash
kubectl create -f prometheus-configmap-update.yaml -o yaml --dry-run | kubectl apply -f -
```

```bash
kubectl apply -f prometheus-deployment-update.yaml
kubectl rollout status deployment/prometheus-deployment -n monitoring
```
