# Automating Helm Processes Using CI/CD and GitOps

Requirements (**Not working, helm jenkins broken**):

-   minikube, kubectl, helm, git, gh (Github cli)

## Creating HELM CHARTS REPOSITORY

1. **Login in Github cli and create repository and dev repository**

```bash
gh auth login
gh repo create helm-chart-repository
gh repo create helm-chart-dev-repository
```

2. **Preparing helm chart dev repository**

```bash
# UPLOAD YOUR CHARTS IN DEV REPO (EXAMPLE) - SKIP IF YOU ALREADY HAVE ONE
cp helm-charts helm-chart-dev-repository/ -r
cd helm-chart-dev-repository/ && git add . && git commit -am "first commit" && git push && cd ..

# DOWNLOAD JENKINS VALUES FOR HELM
mkdir jenkins && wget https://raw.githubusercontent.com/LuisCusihuaman/SRE/master/learn-helm/07-cicd-gitops/01-ci-charts/jenkins/values.yaml -P jenkins
```

3. **Create minikube env**

```bash
minikube start \
  --cpus=2 \
  --memory=4096 \
  --kubernetes-version="v1.16.2" \
  --vm-driver=virtualbox
```

Dedicated namespace:

```bash
kubectl create namespace ci-charts
```

4. **Installing Jenkins**

```bash
helm repo add codecentric https://codecentric.github.io/helm-charts
```

The templating will require the following additional values to be provided during installation:

-   `githubUsername`: The GitHub username
-   `githubPassword`: The GitHub password
-   `githubForkUrl`: The URL of your fork, where is your Jenkinsfile located.
-   `githubPagesRepoUrl`: The URL of your HELM CHARTS REPOSITORY

5. Install your `Jenkins instance` with the `helm install` command, using the following example as a reference:

```bash
export GITHUB_USERNAME=your_username
export GITHUB_PASSWORD=your_password
export CHART_REPOSITORY=https://github.com/$GITHUB_USERNAME/helm-chart-repository

helm install jenkins codecentric/jenkins \
  -n ci-charts --version 1.5.1 \
  --values jenkins/values.yaml \
  --set githubForkUrl=https://github.com/$GITHUB_USERNAME/helm-chart-dev-repository \
  --set githubUsername=$GITHUB_USERNAME \
  --set githubPassword=$GITHUB_PASSWORD \
  --set githubPagesRepoUrl=$CHART_REPOSITORY
```

### Accessing Jenkins

The initial password is logged and also stored in '/var/jenkins_home/secrets/initialAdminPassword'.
Use the following command to retrieve it:

```bash
export POD_NAME=$(kubectl get pods --namespace ci-charts -l "app.kubernetes.io/name=jenkins,app.kubernetes.io/instance=jenkins" -o jsonpath="{.items[0].metadata.name}")
kubectl exec --namespace ci-charts "$POD_NAME" cat /var/jenkins_home/secrets/initialAdminPassword
```

Jenkins server:

```bash
export NODE_PORT=$(kubectl get service --namespace ci-charts -o jsonpath="{.spec.ports[0].nodePort}" jenkins-master)
export NODE_IP=$(kubectl get nodes --namespace ci-charts -o jsonpath="{.items[0].status.addresses[0].address}")
echo "http://$NODE_IP:$NODE_PORT"
```

### Cleaning up your environment

```bash
kubectl delete ns ci-charts
minikube delete
```
