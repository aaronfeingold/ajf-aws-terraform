variable "aws_account_id" {
  description = "AWS Account ID"
  type        = string
}

variable "environments" {
  description = "Map of environment configurations"
  type = map(object({
    prefix = string
  }))
}

variable "ecr_repositories" {
  description = "Map of ECR repository configurations"
  type = map(object({
    uri = string
  }))
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "project-name"
}

