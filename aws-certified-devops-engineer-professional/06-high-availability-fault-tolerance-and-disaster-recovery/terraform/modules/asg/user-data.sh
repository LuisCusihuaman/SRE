#!/bin/bash
# Please make sure to launch Amazon Linux 2
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Hello World from $(hostname -f)" > /var/www/html/index.html
echo "Healthy" > /var/www/html/health.html