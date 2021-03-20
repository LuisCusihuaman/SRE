# Installing your First Helm Chart

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo list
helm search repo wordpress
helm show chart bitnami/wordpress --version 8.1.0
```

```bash
minikube start \
  --cpus=2 \
  --memory=2048 \
  --kubernetes-version="v1.16.2" \
  --vm-driver=virtualbox
```

Dedicated namespace:

```bash
kubectl create namespace first-helm-chart
```

### Creating a values file for configuration

```bash
helm show values bitnami/wordpress --version 8.1.0

tee wordpress-values.yaml > /dev/null <<EOF
wordpressUsername: helm-user
wordpressPassword: my-pass
wordpressEmail: helm-user@example.com
wordpressFirstName: Helm_is
wordpressLastName: Fun
wordpressBlogName: Learn Helm!
service:
    type: NodePort
EOF
```

Now, with a proper understanding of the `helm install` usage, run the following command:

```bash
helm install wordpress bitnami/wordpress --values=wordpress-values.yaml --namespace first-helm-chart --version 8.1.0

helm get values wordpress --namespace first-helm-chart
helm get all wordpress --namespace first-helm-chart
```

### Accessing the WordPress application

```bash
export NODE_PORT=$(kubectl get --namespace chapter3 -o jsonpath="{.spec.ports[0].nodePort}" services wordpress)
export NODE_IP=$(kubectl get nodes --namespace chapter3 -o jsonpath="{.items[0].status.addresses[0].address}")
echo "WordPress URL: http://$NODE_IP:$NODE_PORT/"
echo "WordPress Admin URL: http://$NODE_IP:$NODE_PORT/admin"
```

### Upgrading the WordPress release

```bash
cat << EOF >> wordpress-values.yaml
replicaCount: 2
resources:
  requests:
    memory: 256Mi
    cpu: 100m
EOF

helm upgrade wordpress bitnami/wordpress --values wordpress-values.yaml -n first-helm-chart --version 8.1.0

helm history wordpress -n first-helm-chart
```

### Uninstalling the WordPress release

```bash
helm uninstall wordpress -n first-helm-chart
kubectl get pvc -n first-helm-chart
kubectl delete pvc -l release=wordpress -n first-helm-chart
```

### Cleaning up your environment

```bash
minikube delete
```
