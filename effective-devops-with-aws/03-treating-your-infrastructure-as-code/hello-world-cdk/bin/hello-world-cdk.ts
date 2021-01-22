#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from '@aws-cdk/core';
import { HelloWorldCdkStack } from '../lib/hello-world-cdk-stack';

const app = new cdk.App();
new HelloWorldCdkStack(app, 'HelloWorldCdkStack', {
  env: { region: process.env.AWS_REGION, account: process.env.ACCOUNT_ID },
});
