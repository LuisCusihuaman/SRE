import * as cdk from '@aws-cdk/core';
import * as ec2 from '@aws-cdk/aws-ec2';
import { AmazonLinuxGeneration } from '@aws-cdk/aws-ec2';
import { CfnOutput, CfnParameter } from '@aws-cdk/core';
import * as iam from '@aws-cdk/aws-iam';

export class InstanceStack extends cdk.Stack {
  constructor(scope: cdk.Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);
    const ApplicationPort = 3000;

    const myPublicIP = new CfnParameter(this, 'myPublicIP', {
      type: 'String',
      description: 'Your public IP to access ec2 by ssh',
    });
    const keyPair = new CfnParameter(this, 'keyPair', {
      type: 'AWS::EC2::KeyPair::KeyName',
      description:
        'Name of an existing EC2 KeyPair to enable SSH access to the instance',
    });
    const userDataREPO = 'https://github.com/luiscusihuaman/sre';
    const ansiblePlaybook =
      'effective-devops-with-aws/05-ci-cd/ansible/bootstrap-server.yml';

    const vpc = ec2.Vpc.fromLookup(this, 'VPC', { isDefault: true });
    const ec2SecurityGroup = new ec2.SecurityGroup(this, 'ec2SecurityGroup', {
      vpc: vpc,
      allowAllOutbound: true,
      description: `Allow SSH and TCP/${ApplicationPort}`,
      securityGroupName: 'webserverSecurityGroup',
    });
    ec2SecurityGroup.addIngressRule(
      ec2.Peer.ipv4(myPublicIP.valueAsString),
      ec2.Port.tcp(22),
      'allow public ssh access',
    );
    ec2SecurityGroup.addIngressRule(
      ec2.Peer.anyIpv4(),
      ec2.Port.tcp(ApplicationPort),
      `allow public web server port ${ApplicationPort} access`,
    );

    const amazonLinuxImage = new ec2.AmazonLinuxImage({
      generation: AmazonLinuxGeneration.AMAZON_LINUX_2,
    });

    const ec2Role = new iam.Role(this, 'ec2Role', {
      assumedBy: new iam.ServicePrincipal('ec2.amazonaws.com'),
    });

    ec2Role.addManagedPolicy(
      iam.ManagedPolicy.fromAwsManagedPolicyName(
        'AmazonEC2RoleforAWSCodeDeploy',
      ),
    );

    const ec2Instance = new ec2.Instance(this, 'Instance', {
      keyName: keyPair.valueAsString,
      vpc,
      role: ec2Role,
      instanceType: ec2.InstanceType.of(
        ec2.InstanceClass.T2,
        ec2.InstanceSize.MICRO,
      ),
      machineImage: amazonLinuxImage,
      securityGroup: ec2SecurityGroup,
      userData: ec2.UserData.forLinux({
        shebang: `
                  #!/bin/bash
                  yum install -y git
                  /bin/amazon-linux-extras install ansible2 -y
                  /usr/bin/ansible-pull -U ${userDataREPO} ./${ansiblePlaybook} -i localhost 
                 `,
      }),
    });

    new CfnOutput(this, 'publicIP', {
      value: ec2Instance.instancePublicIp,
      description: 'public ip of my ec2 instance',
      exportName: 'yourPublicEC2IP',
    });
  }
}
