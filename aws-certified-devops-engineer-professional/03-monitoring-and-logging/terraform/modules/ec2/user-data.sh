#!/bin/bash

yum update -y
yum install httpd -y
systemctl enable httpd
systemctl start httpd
echo "Hello world" > /var/www/html/index.html

# install the agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm
# create resource for agent
mkdir -p /usr/share/collectd/ && touch /usr/share/collectd/types.db
# configure the agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:AmazonCloudWatch-linux -s
# restart agent
systemctl restart amazon-cloudwatch-agent.service
