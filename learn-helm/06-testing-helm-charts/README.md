# Testing Helm Charts

Requirements:

-   minikube, kubectl, helm, git

```bash
minikube start \
  --cpus=2 \
  --memory=2048 \
  --kubernetes-version="v1.16.2" \
  --vm-driver=virtualbox
```

Dedicated namespace:

```bash
kubectl create namespace testing-helm-charts
```

### Creating the chart tests

As you recall, the Guestbook chart consists of a Redis backend and a PHP frontend.

```bash
mkdir guestbook/templates/test
touch guestbook/templates/test/{backend,frontend}-connection.yaml
```

test/backend-connection.yaml:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: {{ include "guestbook.fullname" . }}-test-backend-connection
  labels:
    {{- include "guestbook.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": test
    "helm.sh/hook-delete-policy": before-hook-creation
  spec:
    containers:
      - name: test-backend-connection
        image: redis:alpine3.11
        command: ["/bin/sh","-c"]
        args: ["redis-cli -h {{ .Values.redis.fullnameOverride }}-master MGET messages "]
    restartPolicy: Never
```

test/frontend-connection.yaml:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: {{ include "guestbook.fullname" . }}-test-frontend-connection
  labels:
    {{- include "guestbook.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": test
    "helm.sh/hook-delete-policy": before-hook-creation
  spec:
    containers:
      - name: test-frontend-connection
        image: curlimages/curl:7.68.0
        command: ["/bin/sh", "-c"]
        args: ["curl {{ include "guestbook.fullname" . }}"]
    restartPolicy: Never
```

### Running the chart tests

```bash
helm install my-guestbook guestbook -n testing-helm-charts --wait
helm test my-guestbook -n testing-helm-charts --logs
```

### Cleaning up your environment

```bash
kubectl delete ns testing-helm-charts
minikube delete
```

## Questions

1. What additional value does the ct tool bring to Helm's built-in testing capabilities?

The Chart Testing (ct) tool allows Helm chart maintainers to more easily test Helm charts in a git monorepo. It performs thorough testing and ensures that charts that are modified have had their versions incremented.

2. What is the purpose of the ci/ folder when used with the ct tool?

The ci/ folder is used to test multiple different combinations of Helm values.

https://github.com/helm/chart-testing
