output "target_state_machine_arn" {
  value = aws_sfn_state_machine.ExposedKeyStepFunction.arn
}