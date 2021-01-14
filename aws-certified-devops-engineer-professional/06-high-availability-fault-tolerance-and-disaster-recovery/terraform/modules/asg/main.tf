provider "aws" {
  region = "us-east-2"
}
locals {
  AM2_AMI_US_EAST_2 = "ami-0a0ad6b70e61be944"
  any_port = 0
  any_protocol = "-1"
}

# SG INSTANCES
resource "aws_security_group" "asg_sg" {
  name = "asg_sg"
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["${chomp(data.http.myip.body)}/32"]
  }
  egress {
    from_port = local.any_port
    to_port = local.any_port
    protocol = local.any_protocol
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "asg_sg"
  }
}

# ASG WITH LAUNCH TEMPLATE
resource "aws_launch_template" "my_demo_template" {
  name = "my_demo_template"
  image_id = local.AM2_AMI_US_EAST_2
  instance_type = var.instance_type
  vpc_security_group_ids = [aws_security_group.asg_sg.id]
  user_data = filebase64("user-data.sh")
  tags = {
    Name = "DemoTemplate"
    Environment = "Development"
  }
  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "InstanceTag"
      Environment = "Development"
    }
  }
}
resource "aws_autoscaling_policy" "TargetCPU60" {
  autoscaling_group_name = aws_autoscaling_group.demo_asg_launch_template.name
  name = "TargetCPU60"
  policy_type = "TargetTrackingScaling"
  target_tracking_configuration {
    target_value = 60
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  }
}
resource "aws_autoscaling_group" "demo_asg_launch_template" {
  name = "demo_asg_launch_template"
  vpc_zone_identifier = data.aws_subnet_ids.default.ids
  desired_capacity = 1
  max_size = 1
  min_size = 1
  health_check_type = "ELB"
  target_group_arns = [aws_alb_target_group.demo-target-group.arn]
  min_elb_capacity = 1
  launch_template {
    id = aws_launch_template.my_demo_template.id
    version = "$Latest"
  }
  depends_on = [aws_lb.demo_alb]
}

resource "aws_security_group" "alb_sg" {
  name = "alb_sg"
  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = local.any_port
    to_port = local.any_port
    protocol = local.any_protocol
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "alb_sg"
  }
}
resource "aws_lb" "demo_alb" {
  name = "DemoALB"
  load_balancer_type = "application"
  subnets = data.aws_subnet_ids.default.ids
  security_groups = [aws_security_group.alb_sg.id]
  tags = {
    Name = "demo_alb"
  }
}

resource "aws_alb_listener" "http" {
  load_balancer_arn = aws_lb.demo_alb.arn
  port = 80
  protocol = "HTTP"
  default_action {
    target_group_arn = aws_alb_target_group.demo-target-group.arn
    type = "forward"
  }
}

resource "aws_alb_target_group" "demo-target-group" {
  name = "demo-target-group"
  protocol = "HTTP"
  port = 80
  vpc_id = data.aws_vpc.default.id
  health_check {
    protocol = "HTTP"
    path = "/health.html"
    healthy_threshold = 5
    unhealthy_threshold = 2
    timeout = 5
    interval = 30
    matcher = "200"
  }
}