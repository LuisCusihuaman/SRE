# Hello World EC2 CDK project!

This is my first CDK application, ansible is used for boostraping

# Step 0 - SETUP

```
MY_PUBLIC_IP=$(curl -s http://whatismijnip.nl |cut -d " " -f 5)/32

export ACCOUNT_ID=”XXXXXXXXXXXX" AWS_REGION=”us-east-2"

npm install
```

# Step 1 - Setup ssh key pair

```
      
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ansible -C "ansible-demo"

aws ec2 import-key-pair \
  --region $AWS_REGION \
  --key-name "ansible" \
  --public-key-material fileb://~/.ssh/ansible.pub

chmod 400 ~/.ssh/ansible.pub
```

# Step 2 - Deploy

```
./node_modules/aws-cdk/bin/cdk deploy HelloWorldCdkStack --parameters myPublicIP=$MY_PUBLIC_IP --parameters keyPair=ansible
```

# Step 3 - Test

_Wait for less than 1 minute while the ec2 instance initializes_

```
curl http://HelloWorldCdkStack.publicIP:3000
```

Hello World

# Destroy

```
./node_modules/aws-cdk/bin/cdk destroy HelloWorldCdkStack

aws ec2 delete-key-pair --key-name ansible
```
