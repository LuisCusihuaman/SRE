---
title: Terraform Remote State Storage with AWS S3 and DynamnoDB
description: Implement Terraform Remote State Storage with AWS S3 and DynamnoDB
---

## Step-01: Introduction
- Understand Terraform Backends
- Understand about Remote State Storage and its advantages
- This state is stored by default in a local file named "terraform.tfstate", but it can also be stored remotely, which works better in a team environment.
- Create AWS S3 bucket to store `terraform.tfstate` file and enable backend configurations in terraform settings block
- Understand about **State Locking** and its advantages
- Create DynamoDB Table and  implement State Locking by enabling the same in Terraform backend configuration


## Pre-requisite Step
- Copy Terraform Projects-1 and 2 to Section-12
  - 01-ekscluster-terraform-manifests
  - 02-k8sresources-terraform-manifests
- Copy folder `08-AWS-EKS-Cluster-Basics/01-ekscluster-terraform-manifests` to `12-Terraform-Remote-State-Storage/`
- Copy folder `11-Kubernetes-Resources-via-Terraform\02-k8sresources-terraform-manifests` to `12-Terraform-Remote-State-Storage/`

## Step-02: Create S3 Bucket
- Go to Services -> S3 -> Create Bucket
- **Bucket name:** terraform-on-aws-eks
- **Region:** US-East (N.Virginia)
- **Bucket settings for Block Public Access:** leave to defaults
- **Bucket Versioning:** Enable
- Rest all leave to **defaults**
- Click on **Create Bucket**
- **Create Folder**
  - **Folder Name:** dev
  - Click on **Create Folder**
- **Create Folder**
  - **Folder Name:** dev/eks-cluster
  - Click on **Create Folder**  
- **Create Folder**
  - **Folder Name:** dev/app1k8s
  - Click on **Create Folder**    


## Step-03: EKS Cluster: Terraform Backend Configuration
- **File Location:** `01-ekscluster-terraform-manifests/c1-versions.tf`
- [Terraform Backend as S3](https://www.terraform.io/docs/language/settings/backends/s3.html)
- Add the below listed Terraform backend block in `Terrafrom Settings` block in `c1-versions.tf`
```t
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "terraform-on-aws-eks"
    key    = "dev/eks-cluster/terraform.tfstate"
    region = "us-east-1" 
 
    # For State Locking
    dynamodb_table = "dev-ekscluster"    
  }  
```

## Step-04: terraform.tfvars
- **File Location:** `01-ekscluster-terraform-manifests/terraform.tfvars`
- Update `environment` to `dev`
```t
# Generic Variables
aws_region = "us-east-1"
environment = "dev"
business_divsion = "hr"
```

## Step-05: Add State Locking Feature using DynamoDB Table
- Understand about Terraform State Locking Advantages
### Step-05-01: EKS Cluster DynamoDB Table
- Create Dynamo DB Table for EKS Cluster
  - **Table Name:** dev-ekscluster
  - **Partition key (Primary Key):** LockID (Type as String)
  - **Table settings:** Use default settings (checked)
  - Click on **Create**
### Step-05-02: App1 Kubernetes DynamoDB Table
- Create Dynamo DB Table for app1k8s
  - **Table Name:** dev-app1k8s
  - **Partition key (Primary Key):** LockID (Type as String)
  - **Table settings:** Use default settings (checked)
  - Click on **Create**


## Step-06: Create EKS Cluster: Execute Terraform Commands
```t
# Change Directory
cd 01-ekscluster-terraform-manifests

# Initialize Terraform 
terraform init
Observation: 
Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.

# Terraform Validate
terraform validate

# Review the terraform plan
terraform plan 
Observation: 
1) Below messages displayed at start and end of command
Acquiring state lock. This may take a few moments...
Releasing state lock. This may take a few moments...
2) Verify DynamoDB Table -> Items tab

# Create Resources 
terraform apply -auto-approve

# Verify S3 Bucket for terraform.tfstate file
dev/eks-cluster/terraform.tfstate
Observation: 
1. Finally at this point you should see the terraform.tfstate file in s3 bucket
2. As S3 bucket version is enabled, new versions of `terraform.tfstate` file new versions will be created and tracked if any changes happens to infrastructure using Terraform Configuration Files
```

## Step-07: Kubernetes Resources: Terraform Backend Configuration
- **File Location:** `02-k8sresources-terraform-manifests/c1-versions.tf`
- Add the below listed Terraform backend block in `Terrafrom Settings` block in `c1-versions.tf`
```t
  # Adding Backend as S3 for Remote State Storage
  backend "s3" {
    bucket = "terraform-on-aws-eks"
    key    = "dev/app1k8s/terraform.tfstate"
    region = "us-east-1" 

    # For State Locking
    dynamodb_table = "dev-app1k8s"    
  }   
```


## Step-8: Clean-Up
```t
# Delete Kubernetes  Resources
cd 02-k8sresources-terraform-manifests
terraform apply -destroy -auto-approve
rm -rf .terraform*

# Verify Kubernetes Resources
kubectl get pods
kubectl get svc

# Delete EKS Cluster (Optional)
1. As we are using the EKS Cluster with Remote state storage, we can and we will reuse EKS Cluster in next sections
2. Dont delete or destroy EKS Cluster Resources

cd 01-ekscluster-terraform-manifests/
terraform apply -destroy -auto-approve
rm -rf .terraform*
```

## Additional Reference
## Step-00: Little bit theory about Terraform Backends
- Understand little bit more about Terraform Backends
- Where and when Terraform Backends are used ?
- What Terraform backends do ?
- How many types of Terraform backends exists as on today ? 


## References 
- [AWS S3 Backend](https://www.terraform.io/docs/language/settings/backends/s3.html)
- [Terraform Backends](https://www.terraform.io/docs/language/settings/backends/index.html)
- [Terraform State Storage](https://www.terraform.io/docs/language/state/backends.html)
- [Terraform State Locking](https://www.terraform.io/docs/language/state/locking.html)
- [Remote Backends - Enhanced](https://www.terraform.io/docs/language/settings/backends/remote.html)

