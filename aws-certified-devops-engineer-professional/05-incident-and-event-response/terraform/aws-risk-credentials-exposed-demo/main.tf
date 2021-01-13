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

module "sfn_state_machine" {
  source = "../modules/state_machine"
  delete_access_key_arn = module.lamba_functions.delete_access_key_arn
  lookup_cloudtrail_arn = module.lamba_functions.lookup_cloudtrail_arn
  notify_security_arn = module.lamba_functions.notify_security_arn
}

module "cloudwatch_event" {
  source = "../modules/cloudwatch"
  step_function_machine_arn = module.sfn_state_machine.target_state_machine_arn
}