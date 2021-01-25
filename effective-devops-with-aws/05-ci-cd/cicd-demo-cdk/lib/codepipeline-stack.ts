import * as cdk from '@aws-cdk/core';
import * as codepipeline from '@aws-cdk/aws-codepipeline';
import * as codepipeline_actions from '@aws-cdk/aws-codepipeline-actions';
import * as codedeploy from '@aws-cdk/aws-codedeploy';
import * as s3 from '@aws-cdk/aws-s3';
import * as codebuild from '@aws-cdk/aws-codebuild';

export class CodePipelineStack extends cdk.Stack {
  private boostrapGithubActionPipeline() {
    const oauth = cdk.SecretValue.secretsManager('myGithubToken');

    const repoGithubName = new cdk.CfnParameter(this, 'repoGithubName', {
      type: 'String',
      description: 'Your nodejs github repository name',
    });
    const githubAccountName = new cdk.CfnParameter(this, 'githubAccountName', {
      type: 'String',
      description: 'Your github account name',
    });
    const repoBranchName = new cdk.CfnParameter(this, 'repoBranchName', {
      type: 'String',
      description: 'Your target branch name',
    });

    const sourceOutput = new codepipeline.Artifact('source_output');

    return new codepipeline_actions.GitHubSourceAction({
      oauthToken: oauth,
      output: sourceOutput,
      repo: repoGithubName.valueAsString,
      actionName: 'Source',
      owner: githubAccountName.valueAsString,
      branch: repoBranchName.valueAsString,
    });
  }

  private boostrapCodeBuildAction() {
    return new codepipeline_actions.CodeBuildAction({
      actionName: 'Build',
      input: new codepipeline.Artifact('source_output'),
      outputs: [new codepipeline.Artifact('build_output')],
      project: codebuild.Project.fromProjectArn(
        this,
        'codebuildProject',
        cdk.Fn.importValue('codebuildProjectARN'),
      ),
    });
  }

  private boostrapCodeDeployActionPipeline() {
    return new codepipeline_actions.CodeDeployServerDeployAction({
      actionName: 'CodeDeploy',
      input: new codepipeline.Artifact('build_output'),
      deploymentGroup: codedeploy.ServerDeploymentGroup.fromServerDeploymentGroupAttributes(
        this,
        'codeDeployDemoGroup',
        {
          application: codedeploy.ServerApplication.fromServerApplicationName(
            this,
            'ServerApplication',
            'codeDeployDemo',
          ),
          deploymentGroupName: 'codeDeployDemoGroup',
        },
      ),
    });
  }

  constructor(scope: cdk.Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const artifactBucket = s3.Bucket.fromBucketName(
      this,
      'artifactBucket',
      cdk.Fn.importValue('ArtifactCICDBucketNAME'),
    );

    const codePipelineDemo = new codepipeline.Pipeline(
      this,
      'codePipelineDemo',
      {
        pipelineName: 'codePipelineDemo',
        artifactBucket,
        stages: [
          {
            stageName: 'Source',
            actions: [this.boostrapGithubActionPipeline()],
          },
          {
            stageName: 'Build',
            actions: [this.boostrapCodeBuildAction()],
          },
          {
            stageName: 'Deploy',
            actions: [this.boostrapCodeDeployActionPipeline()],
          },
        ],
      },
    );
  }
}
