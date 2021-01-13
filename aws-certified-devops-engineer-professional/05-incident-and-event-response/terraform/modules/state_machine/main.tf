locals {
  TRUSTED_POLICY = <<TRUSTED
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Effect":"Allow",
      "Principal":{
        "Service":"states.${data.aws_region.current.name}.amazonaws.com"
      },
      "Action":"sts:AssumeRole"
    }
  ]
}
  TRUSTED
}

resource "aws_iam_role" "StepFunctionExecutionRole" {
  name = "StepFunctionExecutionRole"
  assume_role_policy = local.TRUSTED_POLICY
}
resource "aws_iam_role_policy" "StepFunctionExecutionPolicy" {
  name = "StatesExecutionPolicy"
  role = aws_iam_role.StepFunctionExecutionRole.id
  policy = data.aws_iam_policy_document.StatesExecutionPolicy.json
}
resource "aws_sfn_state_machine" "ExposedKeyStepFunction" {
  name = "ExposedKeyStepFunction"
  role_arn = aws_iam_role.StepFunctionExecutionRole.arn
  definition = templatefile("${path.module}/step-function.json", {
    DeleteAccessKeyPairArn = var.delete_access_key_arn
    LookupCloudTrailEventsArn = var.lookup_cloudtrail_arn
    NotifySecurityArn = var.notify_security_arn
  }
  )
}