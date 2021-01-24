import * as cdk from '@aws-cdk/core';
import * as codedeploy from '@aws-cdk/aws-codedeploy';

export class CodeDeployStack extends cdk.Stack {
  constructor(scope: cdk.Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const codeDeployDemo = new codedeploy.ServerApplication(this, 'codeDeployDemo', {
      applicationName: 'codeDeployDemo',
    });
    const codeDeployDemoGroup = new codedeploy.ServerDeploymentGroup(this, 'codeDeployDemoGroup', {
      application: codeDeployDemo,
      deploymentGroupName: 'codeDeployDemoGroup',
      ec2InstanceTags: new codedeploy.InstanceTagSet({
        'Environment': ['Development'],
      }),
      deploymentConfig: codedeploy.ServerDeploymentConfig.ALL_AT_ONCE
    });
    new cdk.CfnOutput(this,'codeDeployDemoGroup',{
      value: codeDeployDemoGroup.deploymentGroupArn
    })
  }
}
