import * as cdk from '@aws-cdk/core';
import * as codepipeline from '@aws-cdk/aws-codepipeline';
import * as codepipeline_actions from '@aws-cdk/aws-codepipeline-actions';
import * as codedeploy from '@aws-cdk/aws-codedeploy';
import * as s3 from '@aws-cdk/aws-s3';
import * as codebuild from '@aws-cdk/aws-codebuild';
import * as iam from '@aws-cdk/aws-iam';
import * as fs from 'fs';
import * as path from 'path';

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

    const sourceOutput = new codepipeline.Artifact('SourceOut');

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
      input: new codepipeline.Artifact('SourceOut'),
      outputs: [new codepipeline.Artifact('BuildOut')],
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
      input: new codepipeline.Artifact('BuildOut'),
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

    const codePipelineRole = new iam.Role(this, 'codePipelineRole', {
      assumedBy: new iam.ServicePrincipal('codepipeline.amazonaws.com'),
    });

    const pathPolicy = path.join(__dirname, 'codepipeline_policy.json');
    const policyDocument = JSON.parse(fs.readFileSync(pathPolicy, 'utf8'));

    const customPolicyDocument = iam.PolicyDocument.fromJson(policyDocument);
    const newManagedPolicy = new iam.ManagedPolicy(this, 'MyNewManagedPolicy', {
      document: customPolicyDocument,
    });
    codePipelineRole.addManagedPolicy(newManagedPolicy);

    const codePipelineDemo = new codepipeline.Pipeline(this, 'cicdDemo', {
      role: codePipelineRole,
      pipelineName: 'cicdDemo',
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
    });
  }
}
