provider "aws" {
  region = "us-east-2"
}

resource "aws_sns_topic" "NotificationTopic" {
  name = "SecurityNotificationTopic"
}

module "lamba_functions" {
  source = "../modules/lambda"
  notification_topic_arn = aws_sns_topic.NotificationTopic.arn
}

