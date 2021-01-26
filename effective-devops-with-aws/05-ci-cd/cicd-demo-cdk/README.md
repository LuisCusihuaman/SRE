# CICD GITHUB ANSIBLE CODEDEPLOY CODEPIPELINE DEMO!

This is my first CDK application, ansible is used for boostraping

Requirements:

- AWS CLI - https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html
- NPM - https://docs.npmjs.com/downloading-and-installing-node-js-and-npm

# Step 0 - SETUP

```
MY_PUBLIC_IP=$(curl -s http://whatismijnip.nl |cut -d " " -f 5)/32

export ACCOUNT_ID=”XXXXXXXXXXXX" AWS_REGION="YOUR_REGION"

npm install
```

# Step 1 - Setup ssh key pair

```

# SSH EC2 KEY Jenkins
ssh-keygen -t rsa -b 4096 -f ~/.ssh/ansible -C "ansible-demo"

aws ec2 import-key-pair \
  --region $AWS_REGION \
  --key-name "ansible" \
  --public-key-material fileb://~/.ssh/ansible.pub

chmod 400 ~/.ssh/ansible.pub

# GITHUB TOKEN FOR CODEPIPELINE

aws secretsmanager create-secret --name myGithubToken \
          --description "Basic Create Secret" --secret-string "YOUR_GITHUB_ACCESS_TOKEN"
```

# Step 2 - Deploy

```
cdk bootstrap aws://$ACCOUNT_ID/$AWS_REGION

./node_modules/aws-cdk/bin/cdk deploy InstanceStack\
    --parameters myPublicIP=$MY_PUBLIC_IP --parameters keyPair=ansible

 ./node_modules/aws-cdk/bin/cdk deploy BucketArtifactStack \
 --parameters ArtifactCICDBucketNAME="aws-cusihuaman-dev-artifacts"

 ./node_modules/aws-cdk/bin/cdk deploy CodeBuildStack \
 --parameters nodejsAppRelativePath="effective-devops-with-aws/05-ci-cd/helloworld"

 ./node_modules/aws-cdk/bin/cdk deploy CodeDeployStack

 ./node_modules/aws-cdk/bin/cdk deploy CodePipelineStack \
  --parameters githubAccountName="LuisCusihuaman" \
  --parameters repoGithubName="SRE" \
  --parameters repoBranchName="cicd_demo_cdk"
  
```

# Step 3 - Test

_Wait for less than 1 minute while the ec2 instance initializes_

```
curl http://HelloWorldCdkStack.JenkinsServerURL
```

Hello World

# Destroy

```

./node_modules/aws-cdk/bin/cdk destroy HelloWorldCdkStack

aws ec2 delete-key-pair --key-name ansible
```

# REFERENCES:

You can't create ssm secure string from Cloudformation, cdk either:

https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-resource-ssm-parameter.html

You can't create ec2 key pair from Cloudformation, cdk either:

https://github.com/aws/aws-cdk/issues/5252

Webhook github outh only accept secret manager and not ssm parameter store:
https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-codepipeline-webhook-webhookauthconfiguration.html

Github token:
https://docs.aws.amazon.com/codepipeline/latest/userguide/appendix-github-oauth.html#GitHub-create-personal-token-CLI

AWS DOCS:
https://docs.aws.amazon.com/codepipeline/latest/userguide/tutorials-four-stage-pipeline.html#tutorials-four-stage-pipeline-prerequisites-jenkins-iam-role