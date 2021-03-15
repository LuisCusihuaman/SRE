# CONSUL NOMAD CLUSTER!

Step by Step deploy production-scale nomad-consul cluster

Requirements:

- AWS CLI - https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html
- Packer
- Terraform

# Step 0 - SETUP

```bash
MY_PUBLIC_IP=$(curl -s http://whatismijnip.nl |cut -d " " -f 5)/32

export ACCOUNT_ID=”XXXXXXXXXXXX" AWS_DEFAULT_REGION="YOUR_REGION"

```

# Step 1 - Setup ssh key pair

```bash

# SSH EC2 KEY
ssh-keygen -t rsa -b 4096 -f ~/.ssh/nomad -C "nomad-demo"

aws ec2 import-key-pair \
  --region $AWS_REGION \
  --key-name "nomad" \
  --public-key-material fileb://~/.ssh/nomad.pub

chmod 400 ~/.ssh/nomad.pub
```

# Step 1 - Setup AMI with Packer

### To build the Nomad and Consul AMI:

1. cd nomad-ami
2. Configure your AWS credentials using one of
   the [options supported by the AWS SDK](http://docs.aws.amazon.com/sdk-for-java/v1/developer-guide/credentials.html).
   Usually, the easiest option is to set the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables.
3. Update the `variables` section of the `nomad-consul-docker.json` Packer template to configure the AWS region and
   Nomad version you wish to use.
4. Run `packer build nomad-consul-docker.json`.

# Step 2 - Terraform

```bash
terraform init
terraform plan
terraform apply
```

### References

AWS DOCS:
https://docs.aws.amazon.com/codepipeline/latest/userguide/tutorials-four-stage-pipeline.html#tutorials-four-stage-pipeline-prerequisites-jenkins-iam-role