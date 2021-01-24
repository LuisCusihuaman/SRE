import * as cdk from '@aws-cdk/core';
import * as codepipeline from '@aws-cdk/aws-codepipeline';
import * as codepipeline_actions from '@aws-cdk/aws-codepipeline-actions';
import * as codedeploy from '@aws-cdk/aws-codedeploy';
import * as s3 from '@aws-cdk/aws-s3';

export class CodePipelineStack extends cdk.Stack {

  private boostrapGithubActionPipeline() {
    const oauth = cdk.SecretValue.ssmSecure('my-github-token', '1');
    const repoURL = new cdk.CfnParameter(this, 'repoGitHubURL', {
      type: 'string', description: 'Your nodejs github repository',
    });
    const githubAccountName = new cdk.CfnParameter(this, 'ownerGithubRepo', {
      type: 'string', description: 'Your github account name',
    });
    const sourceOutput = new codepipeline.Artifact('source_output');

    return new codepipeline_actions.GitHubSourceAction({
      oauthToken: oauth, output: sourceOutput, repo: repoURL.valueAsString,
      actionName: 'Source', owner: githubAccountName.valueAsString,
      branch: 'cicd_demo_cdk',
    });
  }

  private boostrapJenkinsActionPipeline() {
    const jenkinsProvider = new codepipeline_actions.JenkinsProvider(this, 'jenkinsProvider', {
      providerName: 'jenkinsProvider', serverUrl: cdk.Fn.importValue('JenkinsServerURL'),
    });
    const jenkinsProjectName = new cdk.CfnParameter(this, 'jenkinsProjectName', {
      type: 'string',
      description: 'The name of the project (sometimes also called job, or task) on your Jenkins.',
    });

    return new codepipeline_actions.JenkinsAction({
      actionName: 'Build',
      jenkinsProvider: jenkinsProvider,
      projectName: jenkinsProjectName.valueAsString,
      type: codepipeline_actions.JenkinsActionType.BUILD,
      inputs: [new codepipeline.Artifact('source_output')],
      outputs: [new codepipeline.Artifact('build_output')],
    });
  }

  private boostrapCodeDeployActionPipeline() {
    return new codepipeline_actions.CodeDeployServerDeployAction({
      actionName: 'CodeDeploy',
      input: new codepipeline.Artifact('build_output'),
      deploymentGroup: codedeploy.ServerDeploymentGroup
        .fromServerDeploymentGroupAttributes(this, 'codeDeployDemoGroup', {
          application: codedeploy.ServerApplication
            .fromServerApplicationName(this, 'codeDeployDemo', 'codeDeployDemo'),
          deploymentGroupName: 'codeDeployDemoGroup',
        }),
    });
  }

  constructor(scope: cdk.Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);
    const s3BucketArn = new cdk.CfnParameter(this, 'artifactBucket', {
      type: 'string',
      description: 'S3 CICD Artifact Bucket',
    });

    const codePipelineDemo = new codepipeline.Pipeline(this, 'codePipelineDemo', {
      pipelineName: 'codePipelineDemo',
      artifactBucket: s3.Bucket.fromBucketArn(this, 'artifactBucket', s3BucketArn.valueAsString),
      stages: [
        {
          stageName: 'Source',
          actions: [this.boostrapGithubActionPipeline()],
        },
        {
          stageName: 'Build',
          actions: [this.boostrapJenkinsActionPipeline()],
        },
        {
          stageName: 'Deploy',
          actions: [this.boostrapCodeDeployActionPipeline()],
        },
      ],
    });
  }
}
