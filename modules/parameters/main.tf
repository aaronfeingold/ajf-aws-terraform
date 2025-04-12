resource "aws_ssm_parameter" "aws_account_id" {
  name        = "/terraform/aws_account_id"
  description = "AWS Account ID"
  type        = "String"
  value       = var.aws_account_id
  tags = {
    Environment = "global"
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

resource "aws_ssm_parameter" "environment_prefixes" {
  for_each = var.environments

  name        = "/terraform/environments/${each.key}/prefix"
  description = "Resource prefix for ${each.key} environment"
  type        = "String"
  value       = each.value.prefix
  tags = {
    Environment = "global"
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}

resource "aws_ssm_parameter" "ecr_repositories" {
  for_each = var.ecr_repositories

  name        = "/terraform/ecr/${each.key}/uri"
  description = "ECR repository URI for ${each.key}"
  type        = "String"
  value       = each.value.uri
  tags = {
    Environment = "global"
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}
