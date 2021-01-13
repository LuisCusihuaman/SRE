locals {
  TRUSTED_POLICY = <<TRUSTED
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AllowCWEServiceToAssumeRole",
      "Effect":"Allow",
      "Action":["sts:AssumeRole"],
      "Principal":{
        "Service":["events.amazonaws.com"]
      }
    }
  ]
}
  TRUSTED
  STEPFUNCTION_POLICY = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "states:StartExecution",
            "Resource": "${var.step_function_machine_arn}"
        }
    ]
}
  POLICY
}


## CLOUDWATCH EVENT INVOKE STEPFUNCTION MACHINE
resource "aws_iam_role" "ExecuteStateMachineRole" {
  name = "ExecuteStateMachineRole"
  assume_role_policy = local.TRUSTED_POLICY
}
resource "aws_iam_role_policy" "ExecuteStateMachinePolicy" {
  name = "ExecuteStateMachine"
  role = aws_iam_role.ExecuteStateMachineRole.id
  policy = local.STEPFUNCTION_POLICY
}

resource "aws_cloudwatch_event_rule" "RiskCredentialsExposedRule" {
  name = "RiskCredentialsExposedRule"
  event_pattern = file("${path.module}/event-pattern.json")
}

resource "aws_cloudwatch_event_target" "RiskCredentialsExposedRuleTarget" {
  rule = aws_cloudwatch_event_rule.RiskCredentialsExposedRule.name
  role_arn = aws_iam_role.ExecuteStateMachineRole.arn
  arn = var.step_function_machine_arn
}