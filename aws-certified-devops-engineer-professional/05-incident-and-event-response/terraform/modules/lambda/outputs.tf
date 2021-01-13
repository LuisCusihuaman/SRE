output "delete_access_key_arn" {
  value = aws_lambda_function.DeleteAccessKeyPair.arn
}
output "lookup_cloudtrail_arn" {
  value = aws_lambda_function.LookupCloudTrailEvents.arn
}
output "notify_security_arn" {
  value = aws_lambda_function.NotifySecurity.arn
}