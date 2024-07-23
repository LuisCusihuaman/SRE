# Resource: AWS IAM User - Basic User (No AWSConsole Access for AWS Services)
resource "aws_iam_user" "basic_user" {
  name          = "${local.name}-eksadmin2"
  path          = "/"
  force_destroy = true
  tags          = local.common_tags
}

# Resource: AWS IAM User Policy - EKS Full Access
resource "aws_iam_user_policy" "basic_user_eks_policy" {
  name = "${local.name}-eks-full-access-policy"
  user = aws_iam_user.basic_user.name

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iam:ListRoles",
          "eks:*",
          "ssm:GetParameter"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
