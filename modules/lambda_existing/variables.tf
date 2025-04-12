variable "functions" {
  description = "Map of Lambda function names to their configurations"
  type = map(object({
    environment                  = string
    maximum_event_age_in_seconds = number
    maximum_retry_attempts       = number
    log_retention_days           = number
    allow_api_gateway            = bool
  }))
}

variable "api_gateway_execution_arn" {
  description = "Execution ARN of the API Gateway"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
