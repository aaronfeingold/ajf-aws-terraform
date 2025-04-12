terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_regions.primary
  default_tags {
    tags = {
      Organization = var.organization_name
      ManagedBy    = "terraform"
    }
  }
}

# Create region-specific providers dynamically
locals {
  secondary_regions = { for region in var.aws_regions.secondary : region.alias => region.name }
}

# Create providers for each secondary region
provider "aws" {
  alias  = "ohio"
  region = local.secondary_regions["ohio"]
  default_tags {
    tags = {
      Organization = var.organization_name
      ManagedBy    = "terraform"
    }
  }
}

provider "aws" {
  alias  = "oregon"
  region = local.secondary_regions["oregon"]
  default_tags {
    tags = {
      Organization = var.organization_name
      ManagedBy    = "terraform"
    }
  }
}

# Process applications
locals {
  # Organize buckets by region for each application
  primary_region_buckets = flatten([
    for app_name, app in var.applications : [
      for bucket_name, bucket in app.buckets :
        { app_name = app_name, bucket_name = bucket_name, bucket_config = bucket }
        if bucket.region == var.aws_regions.primary
    ]
  ])

  # Create maps of buckets by region for easy processing
  primary_buckets_map = { for item in local.primary_region_buckets :
    item.bucket_name => {
      environment = var.applications[item.app_name].environment
      versioning_enabled = item.bucket_config.versioning_enabled
    }
  }

  ohio_buckets_map = merge([
    for app_name, app in var.applications : {
      for bucket_name, bucket in app.buckets :
        bucket_name => {
          environment = app.environment
          versioning_enabled = bucket.versioning_enabled
        }
        if bucket.region == "us-east-2"
    }
  ]...)

  oregon_buckets_map = merge([
    for app_name, app in var.applications : {
      for bucket_name, bucket in app.buckets :
        bucket_name => {
          environment = app.environment
          versioning_enabled = bucket.versioning_enabled
        }
        if bucket.region == "us-west-2"
    }
  ]...)

  # Process ECR repositories and Lambda functions for each application
  ecr_repositories = merge([
    for app_name, app in var.applications : {
      for repo_name, repo in app.ecr_repositories :
        repo_name => {
          environment = app.environment
          keep_last_images = repo.keep_last_images
        }
    }
  ]...)

  lambda_functions = merge([
    for app_name, app in var.applications : {
      for function_name, function in app.lambda_functions :
        function_name => {
          environment = app.environment
          maximum_event_age_in_seconds = function.maximum_event_age_in_seconds
          maximum_retry_attempts = function.maximum_retry_attempts
          log_retention_days = function.log_retention_days
          allow_api_gateway = function.allow_api_gateway
        }
    }
  ]...)

  # Common tags for all resources
  common_tags = {
    Organization = var.organization_name
    ManagedBy    = "terraform"
  }
}

# Storage module for primary region
module "storage_existing" {
  source = "../../modules/storage_existing"
  buckets = local.primary_buckets_map
  tags = local.common_tags
}

# Storage module for Ohio region
module "storage_existing_ohio" {
  source = "../../modules/storage_existing"
  providers = {
    aws = aws.ohio
  }
  buckets = local.ohio_buckets_map
  tags = local.common_tags
}

# Storage module for Oregon region
module "storage_existing_oregon" {
  source = "../../modules/storage_existing"
  providers = {
    aws = aws.oregon
  }
  buckets = local.oregon_buckets_map
  tags = local.common_tags
}

# Lambda module
module "lambda_existing" {
  source = "../../modules/lambda_existing"
  functions = local.lambda_functions
  tags = local.common_tags
}

# ECR module
module "ecr_existing" {
  source = "../../modules/ecr_existing"
  repositories = local.ecr_repositories

  # Generate a standard policy for all repositories
  repository_policies = {
    for repo_name, _ in local.ecr_repositories : repo_name => jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Sid    = "AllowLambdaPull",
          Effect = "Allow",
          Principal = {
            Service = "lambda.amazonaws.com"
          },
          Action = [
            "ecr:BatchGetImage",
            "ecr:GetDownloadUrlForLayer"
          ]
        }
      ]
    })
  }

  tags = local.common_tags
}

# Step Functions module - Create only for applications that need them
module "step_functions" {
  for_each = {
    for app_name, app in var.applications : app_name => app
    if length(app.step_functions) > 0
  }

  source = "../../modules/step_function"

  name_prefix        = each.key
  environment         = each.value.environment
  environment_prefix  = each.key
  lambda_arn          = module.lambda_existing.functions[
    each.value.step_functions["scraper-fanout"].lambda_function_name
  ].arn

  tags = merge(local.common_tags, {
    Application = each.key
    Environment = each.value.environment
  })
}
