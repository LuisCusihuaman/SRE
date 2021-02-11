## Static way

### Step 1 - Setup MINIKUBE

Start a new minikube instance with the following specifications:

```bash
minikube start \
  --cpus=2 \
  --memory=2048 \
  --kubernetes-version="v1.14.0" \
  --vm-driver=virtualbox
```

we'll be creating a new namespace called monitoring

```bash
kubectl apply -f 01-monitoring-namespace.yaml                                               
kubectl apply -f 02-prometheus-configmap.yaml                                               
kubectl apply -f 03-prometheus-deployment.yaml   
```

After a successful deployment, we're ready to assign a new service to our instance, choosing NodePort so we can access
it without requiring port-forwarding, like so:

```bash
kubectl apply -f 04-prometheus-service.yaml
minikube service prometheus-service -n monitoring
```

We'll deploy yet another service and add it to our Prometheus server:

```bash
kubectl apply -f 05-hey-deployment.yaml
kubectl rollout status deployment/hey-deployment -n monitoring
kubectl apply -f 06-hey-service.yaml
minikube service hey-service -n monitoring
```

Since Prometheus is statically managed in our example, we need to add the new Hey target for metric collection. This
means that we need to change the Prometheus ConfigMap to reflect the newly added service, like so:

```bash
kubectl apply -f 05-hey-deployment.yaml
kubectl rollout status deployment/hey-deployment -n monitoring
kubectl apply -f 06-hey-service.yaml
minikube service hey-service -n monitoring
```

Since Prometheus is statically managed in our example, we need to add the new Hey target for metric collection.

```bash
kubectl create -f prometheus-configmap-update.yaml -o yaml --dry-run | kubectl apply -f -
kubectl apply -f prometheus-deployment-update.yaml
```

Delete environment:

```bash
minikube delete
```

## Operator way

In our case, besides managing the deployment, including the number of pods and persistent volumes of the Prometheus
server, the Prometheus Operator will also update the configuration dynamically using the concept of ServiceMonitor,
which targets services with matching rules against the labels of running container

```bash
kubectl apply -f 01-monitoring-namespace.yaml
```

The first one defines the ClusterRole and apply the ClusterRole to a ClusterRoleBinding:

```bash
kubectl apply -f 02-prometheus-operator-rbac.yaml
```

Having the new service account configured, we're ready to deploy the Operator itself, like so:

```bash
kubectl apply -f 03-prometheus-operator-deployment.yaml
```

Before proceeding with the setup of Prometheus, we'll need to grant its instances with the right access control
permissions.

```bash
kubectl apply -f 04-prometheus-rbac.yaml
```

```bash
kubectl apply -f 05-prometheus-server.yaml
kubectl apply -f 06-prometheus-service.yaml
minikube service prometheus-service -n monitoring
```

### Adding targets to Prometheus

```bash
kubectl apply -f 07-hey-deployment.yaml
```

Pay close attention to the labels that will be used by the service monitor to target this service:

```bash
kubectl apply -f 08-hey-service.yaml
minikube service hey-service -n default
```

Finally, we are going to create service monitors for both the Prometheus instances and the Hey application, which will
instruct the Operator to configure Prometheus, adding the required targets.

```bash
kubectl apply -f 09-hey-servicemonitor.yaml
kubectl apply -f 10-prometheus-servicemonitor.yaml
```

Delete environment:

```bash
minikube delete
```