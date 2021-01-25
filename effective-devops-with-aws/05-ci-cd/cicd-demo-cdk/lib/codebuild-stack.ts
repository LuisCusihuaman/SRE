import * as cdk from '@aws-cdk/core';
import * as codebuild from '@aws-cdk/aws-codebuild';
import * as iam from '@aws-cdk/aws-iam';

export class CodeBuildStack extends cdk.Stack {
  constructor(scope: cdk.Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const nodejsAppRelativePath = new cdk.CfnParameter(
      this,
      'nodejsAppRelativePath',
      {
        type: 'String',
        description: 'Directory where your app and appspec.yml is',
      },
    );

    const codeBuildRole = new iam.Role(this, 'codeBuildRole', {
      assumedBy: new iam.ServicePrincipal('codebuild.amazonaws.com'),
    });

    codeBuildRole.addManagedPolicy(
      iam.ManagedPolicy.fromAwsManagedPolicyName('AmazonS3FullAccess'),
    );

    const codebuildProject = new codebuild.PipelineProject(
      this,
      'codebuildProject',
      {
        role: codeBuildRole,
        projectName: 'CodeBuildProject',
        description: 'We will test whether or not nodejs application',
        environment: {
          computeType: codebuild.ComputeType.SMALL,
          buildImage: codebuild.LinuxBuildImage.AMAZON_LINUX_2_3,
        },
        environmentVariables: {
          ['nodejsAppRelativePath']: {
            value: nodejsAppRelativePath.valueAsString,
            type: codebuild.BuildEnvironmentVariableType.PLAINTEXT,
          },
        },
      },
    );

    new cdk.CfnOutput(this, 'codebuildProjectARN', {
      value: codebuildProject.projectArn,
      exportName: 'codebuildProjectARN',
      description: 'Codebuild proejct arn for codepipeline',
    });
  }
}
