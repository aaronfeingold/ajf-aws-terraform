variable "name_prefix" {
  description = "Prefix to use for resource names"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., prod, staging)"
  type        = string
}

variable "environment_prefix" {
  description = "Prefix for environment-specific resources"
  type        = string
}

variable "lambda_arn" {
  description = "ARN of the Lambda function to invoke"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
