variable "environment" {
  description = "Environment name"
  type        = string
}

variable "ecr_repository_names" {
  description = "Map of ECR repository names to look up"
  type        = map(string)
}
