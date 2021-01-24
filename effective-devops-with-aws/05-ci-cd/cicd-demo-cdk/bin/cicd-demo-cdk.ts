#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from '@aws-cdk/core';
import { JenkinsStack } from '../lib/jenkins-stack';
import { CodeDeployStack } from '../lib/codedeploy-stack';
import { CodePipelineStack } from '../lib/codepipeline-stack';


const app = new cdk.App();
new JenkinsStack(app, 'InstanceStack');
new CodeDeployStack(app, 'CodeDeployStack');
new CodePipelineStack(app, 'CodePipelineStack');