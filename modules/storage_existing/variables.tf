variable "buckets" {
  description = "Map of S3 bucket names to their configurations"
  type = map(object({
    environment = string
    versioning_enabled  = bool
  }))
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
