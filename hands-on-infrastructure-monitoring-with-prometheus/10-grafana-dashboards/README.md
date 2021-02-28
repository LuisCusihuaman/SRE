# Grafana Dashboards

### Step 1 - Setup env

```bash
vagrant global-status
vagrant up
vagrant status
```

Te new instances will be available for inspection at Prometheus

http://192.168.42.10:9090 | vagrant ssh prometheus

http://192.168.42.11:3000 | vagrant ssh grafana

```bash
vagrant ssh prometheus
```

### Cleanup

```bash
vagrant destroy -f
```

## Data source

To have data to query, we must configure a data source. There are two ways to configure a data source. One way is by
adding a YAML file with the required configuration in the Grafana provisioning path, which is picked up by the service
when starting up and is configured automatically

```bash
vagrant@grafana:~$ cat /etc/grafana/provisioning/datasources/prometheus.yaml
```

## Explore

This feature was introduced in Grafana 6 and its developers continue to improve its tight integration with Prometheus.

**Metrics list**: In the top-left corner, we can find a combo box called Metrics. This lists metrics in a hierarchical
form, grouped by their prefix, and even detects and groups recording rules when they follow the double-colon naming
convention.

**Query field**: Besides suggesting and autocompleting metrics, the query field also displays useful tooltips about
PromQL functions and can even expand recording rules that are detected in their originating expression.

**Context menus**: You can choose to open the query from any dashboard panel directly in the Explore page.

## Grafana running on Kubernetes

Deploying Grafana on Kubernetes involves mostly the same method as deploying it in VMs, so we're just going to focus on
some of the finer points that an operator should be aware

```bash
cd kubernetes

minikube start \
  --cpus=2 \
  --memory=3072 \
  --kubernetes-version="v1.14.0" \
  --vm-driver=virtualbox
```

Add the Prometheus Operator components and follow its deployment, as follows:

```bash
kubectl apply -f ./bootstrap/
kubectl rollout status deployment/prometheus-operator -n monitoring
```

Add the new Prometheus at cluster:

```bash
kubectl apply -f ./prometheus/
kubectl rollout status statefulset/prometheus-k8s -n monitoring
```

Add all the targets:

```bash
kubectl apply -f ./services/
kubectl get servicemonitors --all-namespaces
```

Now that the Kubernetes environment is running, we can proceed with Grafana-specific configurations.

For the data source, since we might want to add sensitive information such as authentication in the future, we are going
to use a Kubernetes secret. This also implies that there should be a ServiceAccount for accessing that secret.

```bash
kubectl apply -f ./grafana/grafana-serviceaccount.yaml
kubectl apply -f ./grafana/grafana-datasources-provision.yaml #secret
```

Now, it's time to add our example dashboard to Grafana. These are going to be available to the Grafana deployment as
ConfigMaps:

```bash
kubectl apply -f ./grafana/grafana-dashboards-provision.yaml
kubectl apply -f ./grafana/grafana-dashboards.yaml
```

It's now time to deploy Grafana and take advantage of all the preceding configurations:

```bash
kubectl apply -f ./grafana/grafana-deployment.yaml
```

Finally, we can add a service so that we can access the newly launched Grafana instance, and a ServiceMonitor so that
the Prometheus Operator configures Prometheus to collect metrics:

```bash
kubectl apply -f ./grafana/grafana-service.yaml
kubectl apply -f ./grafana/grafana-servicemonitor.yaml

#You can now access the Grafana:
minikube service grafana -n monitoring
```

### Delete all:

```bash
minikube delete
```

## Questions

1. How can you provision a data source automatically in Grafana?

Grafana supports automatic provisioning of data sources by reading YAML definitions from a provisioning path at startup.

2. How do Grafana dashboard variables work?

Variables allow a dashboard to configure placeholders that can be used in expressions and title strings, and those
placeholders can be filled with values from either a static or dynamic list, which are usually presented to the
dashboard user in the form of a drop-down menu.

3. What's the building block of a dashboard?

In Grafana, the building block is the panel.

4. When you update a dashboard that's published to grafana.com, does it change its ID?

No, it does not. The dashboard ID will remain the same, but the iteration will be incremented.
