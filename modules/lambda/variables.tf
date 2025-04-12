variable "functions" {
  description = "Map of Lambda functions to create"
  type = map(object({
    image_uri                        = string
    environment                      = string
    additional_environment_variables = map(string)
  }))
}

variable "lambda_role_name" {
  description = "Name of the Lambda execution role"
  type        = string
}

variable "lambda_timeout" {
  description = "Timeout for Lambda functions in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory_size" {
  description = "Memory size for Lambda functions in MB"
  type        = number
  default     = 512
}

variable "s3_bucket_arns" {
  description = "List of S3 bucket ARNs that Lambda functions can access"
  type        = list(string)
}

variable "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
