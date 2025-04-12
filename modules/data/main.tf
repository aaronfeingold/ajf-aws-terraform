data "aws_ssm_parameter" "aws_account_id" {
  name = "/terraform/aws_account_id"
}

data "aws_ssm_parameter" "environment_prefix" {
  name = "/terraform/environments/${var.environment}/prefix"
}

data "aws_ssm_parameter" "ecr_repository_uris" {
  for_each = var.ecr_repository_names
  name     = "/terraform/ecr/${each.value}/uri"
}
