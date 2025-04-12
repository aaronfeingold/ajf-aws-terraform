variable "api_name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "rewire_lambda_arn" {
  description = "ARN of the rewire Lambda function"
  type        = string
}

variable "oz_rewire_lambda_arn" {
  description = "ARN of the oz-rewire Lambda function"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "rewire_route_path" {
  description = "API route path for rewire service"
  type        = string
  default     = "rewire-service"
}

variable "oz_rewire_route_path" {
  description = "API route path for oz rewire service"
  type        = string
  default     = "oz-service"
}

