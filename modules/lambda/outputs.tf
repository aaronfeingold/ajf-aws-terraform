output "function_arns" {
  description = "ARNs of the Lambda functions"
  value       = { for k, v in aws_lambda_function.function : k => v.arn }
}

output "function_names" {
  description = "Names of the Lambda functions"
  value       = { for k, v in aws_lambda_function.function : k => v.function_name }
}

output "role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_exec_role.arn
}
