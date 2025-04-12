variable "organization_name" {
  description = "Name of the organization"
  type        = string
  default     = "org-name"
}

variable "project_name" {
  description = "Name of the infrastructure project"
  type        = string
  default     = "terraform-infra"  # Generic in the repo, actual value in tfvars
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
  sensitive   = true
}

variable "aws_regions" {
  description = "AWS regions configuration"
  type = object({
    primary   = string
    secondary = list(object({
      name = string
      alias = string
    }))
  })
  default = {
    primary = "us-east-1"
    secondary = [
      {
        name  = "us-east-2"
        alias = "ohio"
      },
      {
        name  = "us-west-2"
        alias = "oregon"
      }
    ]
  }
}

variable "applications" {
  description = "Configuration for all applications in the organization"
  type = map(object({
    description = string
    environment = string

    # S3 buckets
    buckets = map(object({
      versioning_enabled = bool
      region             = string  # Use this to determine which provider to use
    }))

    # Lambda functions
    lambda_functions = map(object({
      maximum_event_age_in_seconds = number
      maximum_retry_attempts       = number
      log_retention_days           = number
      allow_api_gateway            = bool
    }))

    # ECR repositories
    ecr_repositories = map(object({
      keep_last_images = number
    }))

    # Step Functions
    step_functions = map(object({
      enabled = bool
      schedule = string
      lambda_function_name = string
    }))
  }))

  default = {
    "app-1" = {
      description = "Example application 1"
      environment = "prod"

      buckets = {
        "example-bucket" = {
          versioning_enabled = true
          region             = "us-east-1"
        }
      },

      lambda_functions = {
        "example-function" = {
          maximum_event_age_in_seconds = 60
          maximum_retry_attempts       = 2
          log_retention_days           = 30
          allow_api_gateway            = true
        }
      },

      ecr_repositories = {
        "example-repo" = {
          keep_last_images = 30
        }
      },

      step_functions = {}
    }
  }
}
