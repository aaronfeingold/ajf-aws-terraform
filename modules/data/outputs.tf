output "environment_prefix" {
  description = "The environment prefix from SSM"
  value       = nonsensitive(data.aws_ssm_parameter.environment_prefix.value)
}

output "aws_account_id" {
  description = "The AWS account ID from SSM"
  value       = nonsensitive(data.aws_ssm_parameter.aws_account_id.value)
}

output "ecr_repository_uris" {
  description = "Map of ECR repository names to their URIs"
  value       = { for k, v in data.aws_ssm_parameter.ecr_repository_uris : k => nonsensitive(v.value) }
}
