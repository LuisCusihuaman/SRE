# Building Your First Helm Chart

```bash
minikube start \
  --cpus=2 \
  --memory=2048 \
  --kubernetes-version="v1.16.2" \
  --vm-driver=virtualbox
```

Dedicated namespace:

```bash
kubectl create namespace build-helm-chart
```

### Creating a Guestbook Helm chart

Run the following command on your local command line to scaffold this chart:

```bash
helm create guestbook
```

The process to add a Redis chart dependency can be performed by following these steps:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm search repo redis --versions

cat << EOF >> guestbook/Chart.yaml
dependencies:
  - name: redis
    version: 10.5.x
    repository: https://charts.bitnami.com/bitnami
EOF

helm dependency update guestbook
```

### Adding values to configure the Redis chart

Append to guestbook/values.yaml

```yaml
redis:
    # Override the redis.fullname template
    fullnameOverride: redis
    # Enable unauthenticated access to Redis
    usePassword: false
    # Disable AOF persistence
    configmap: |-
        appendonly no
```

Modify in `guestbook/values.yaml` the following:

```yaml
image:
    repository: gcr.io/google-samples/gb-frontend
    pullPolicy: IfNotPresent
service:
    type: NodePort
    port: 80
```

Replace the `appVersion` for `v4` and `version` for `1.0.0` in `guestbook/Chart.yaml`.

### Installing the Guestbook chart

```bash
helm install my-guestbook guestbook -n build-helm-chart
kubectl get pods -n build-helm-chart
```

### Accessing the application

```bash
helm get notes my-guestbook -n build-helm-chart

export NODE_PORT=$(kubectl get --namespace build-helm-chart -o jsonpath="{.spec.ports[0].nodePort}" services my-guestbook)
export NODE_IP=$(kubectl get nodes --namespace build-helm-chart -o jsonpath="{.items[0].status.addresses[0].address}")
echo http://$NODE_IP:$NODE_PORT
```

When you are ready, uninstall this chart with the helm `uninstall` command, like this:

```bash
helm uninstall my-guestbook -n build-helm-chart
kubectl delete pvc -l app=redis -n build-helm-chart
```

### Improving the Guestbook Helm chart

-   Life cycle hooks to back up and restore the Redis database
-   Input validation to ensure only valid values are provided

First, you should create a new folder to contain the hook templates.

**Creating the pre-upgrade hook to take a data snapshot**

```bash
mkdir guestbook/templates/backup
touch guestbook/templates/backup/{persistentvolumeclaim,job}.yaml
```

backup/persistentvolumeclaim.yaml:

```yaml
{{- if .Values.redis.master.persistence.enabled }}
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: redis-data-{{ .Values.redis.fullnameOverride }}-master-0-backup-{{ sub .Release.Revision 1 }}
  labels:
    {{- include "guestbook.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": pre-upgrade
    "helm.sh/hook-weight": "0"
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: {{ .Values.redis.master.persistence.size }}
{{- end }}
```

backup/job.yaml:

```yaml
{{- if .Values.redis.master.persistence.enabled }}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "guestbook.fullname" . }}-backup
  labels:
    {{- include "guestbook.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": pre-upgrade
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
    "helm.sh/hook-weight": "1"
spec:
  template:
    spec:
      containers:
        - name: backup
          image: redis:alpine3.11
          command: ["/bin/sh", "-c"]
          args: ["redis-cli -h {{ .Values.redis.fullnameOverride }}-master save && cp /data/dump.rdb /backup/dump.rdb"]
          volumeMounts:
            - name: redis-data
              mountPath: /data
            - name: backup
              mountPath: /backup
      restartPolicy: Never
      volumes:
        - name: redis-data
          persistentVolumeClaim:
            claimName: redis-data-{{ .Values.redis.fullnameOverride }}-master-0
        - name: backup
          persistentVolumeClaim:
            claimName: redis-data-{{ .Values.redis.fullnameOverride }}-master-0-backup-{{ sub .Release.Revision 1 }}
{{- end }}
```

**_Creating the pre-rollback hook to restore the database_**

```bash
mkdir guestbook/templates/restore
touch guestbook/templates/restore/job.yaml
```

restore/job.yaml:

```yaml
{{- if .Values.redis.master.persistence.enabled }}
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "guestbook.fullname" . }}-restore
  labels:
    {{- include "guestbook.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": pre-rollback
    "helm.sh/hook-delete-policy": before-hook-creation,hook-succeeded
spec:
  template:
    spec:
      containers:
        - name: restore
          image: redis:alpine3.11
          command: ["/bin/sh", "-c"]
          args: ["cp /backup/dump.rdb /data/dump.rdb &&
            redis-cli -h {{ .Values.redis.fullnameOverride }}-master debug restart || true"]
          volumeMounts:
            - name: redis-data
              mountPath: /data
            - name: backup
              mountPath: /backup
      restartPolicy: Never
      volumes:
        - name: redis-data
          persistentVolumeClaim:
            claimName: redis-data-{{ .Values.redis.fullnameOverride }}-master-0
        - name: backup
          persistentVolumeClaim:
            claimName: redis-data-{{ .Values.redis.fullnameOverride }}-master-0-backup-{{ .Release.Revision }}
{{- end }}
```

### Executing the life cycle hooks

```bash
helm install my-guestbook guestbook -n build-helm-chart
```

Once a message has been written and its text is displayed under the Submit button, run the helm upgrade command to trigger the pre-upgrade hook.

```bash
helm upgrade my-guestbook guestbook -n build-helm-chart
kubectl get pvc -n build-helm-chart
```

_This PVC contains a data snapshot that can be used to restore the database during the pre-rollback life cycle phase._

1. Let's now proceed to add an additional message to the Guestbook frontend.
2. Now, run the helm rollback

```bash
helm rollback my-guestbook 1 -n build-helm-chart
```

3. Now go back to the UI and see if the messages were restored until that rollback

### Cleaning up your environment

```bash

kubectl delete namespace build-helm-chart
minikube delete
```
