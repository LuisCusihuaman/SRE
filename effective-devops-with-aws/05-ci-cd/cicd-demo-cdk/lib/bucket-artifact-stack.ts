import * as cdk from '@aws-cdk/core';
import { RemovalPolicy } from '@aws-cdk/core';
import * as s3 from '@aws-cdk/aws-s3';

export class BucketArtifactStack extends cdk.Stack {
  constructor(scope: cdk.Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const ArtifactCICDBucketNAME = new cdk.CfnParameter(
      this,
      'ArtifactCICDBucketNAME',
      {
        type: 'String',
        description: 'Your Bucket CICD Bucket Name',
      },
    );

    new s3.Bucket(this, 'ArtifactCICDBucket', {
      removalPolicy: RemovalPolicy.DESTROY,
      autoDeleteObjects: true,
      bucketName: ArtifactCICDBucketNAME.valueAsString,
    });

    new cdk.CfnOutput(this, 'ArtifactCICDBucketNAMEOuput', {
      value: ArtifactCICDBucketNAME.valueAsString,
      description: 'Bucket used in codebuild',
      exportName: 'ArtifactCICDBucketNAME',
    });
  }
}
