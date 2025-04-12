variable "repositories" {
  description = "Map of ECR repository names to their configurations"
  type = map(object({
    environment      = string
    keep_last_images = number
  }))
}

variable "repository_policies" {
  description = "Map of ECR repository names to their IAM policies"
  type = map(string)
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
