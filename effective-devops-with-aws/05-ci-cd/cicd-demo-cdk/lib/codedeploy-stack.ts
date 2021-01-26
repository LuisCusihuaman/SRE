import * as cdk from '@aws-cdk/core';
import * as codedeploy from '@aws-cdk/aws-codedeploy';
import * as iam from '@aws-cdk/aws-iam';

export class CodeDeployStack extends cdk.Stack {
  constructor(scope: cdk.Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const codeDeployRole = new iam.Role(this, 'codeBuildRole', {
      assumedBy: new iam.ServicePrincipal('codedeploy.amazonaws.com'),
    });

    codeDeployRole.addManagedPolicy(
      iam.ManagedPolicy.fromAwsManagedPolicyName('AmazonS3FullAccess'),
    );
    codeDeployRole.addManagedPolicy(
      iam.ManagedPolicy.fromManagedPolicyArn(
        this,
        'codedeployPolicy',
        'arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole',
      ),
    );

    const codeDeployDemo = new codedeploy.ServerApplication(
      this,
      'codeDeployDemo',
      {
        applicationName: 'codeDeployDemo',
      },
    );
    const codeDeployDemoGroup = new codedeploy.ServerDeploymentGroup(
      this,
      'serverCodeDeployDemoGroup',
      {
        application: codeDeployDemo,
        deploymentGroupName: 'codeDeployDemoGroup',
        ec2InstanceTags: new codedeploy.InstanceTagSet({
          Environment: ['Development'],
        }),
        deploymentConfig: codedeploy.ServerDeploymentConfig.ALL_AT_ONCE,
        role: codeDeployRole,
      },
    );
    new cdk.CfnOutput(this, 'codeDeployDemoGroup', {
      value: codeDeployDemoGroup.deploymentGroupArn,
    });
  }
}
