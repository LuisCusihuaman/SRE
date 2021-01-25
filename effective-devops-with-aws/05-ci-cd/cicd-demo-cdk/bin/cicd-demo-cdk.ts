#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from '@aws-cdk/core';
import { CodePipelineStack } from '../lib/codepipeline-stack';
import { BucketArtifactStack } from '../lib/bucket-artifact-stack';
import { CodeBuildStack } from '../lib/codebuild-stack';
import { CodeDeployStack } from '../lib/codedeploy-stack';
import { InstanceStack } from '../lib/instance-stack';

const app = new cdk.App();
const env = { region: process.env.AWS_REGION, account: process.env.ACCOUNT_ID };

const instanceStack = new InstanceStack(app, 'InstanceStack', { env });
cdk.Tags.of(instanceStack).add('Environment', 'Development', {
  applyToLaunchedInstances: true,
  includeResourceTypes: ['AWS::EC2::Instance'],
});
new BucketArtifactStack(app, 'BucketArtifactStack', { env });
new CodeBuildStack(app, 'CodeBuildStack', { env });
new CodeDeployStack(app, 'CodeDeployStack', { env });
new CodePipelineStack(app, 'CodePipelineStack', { env });
