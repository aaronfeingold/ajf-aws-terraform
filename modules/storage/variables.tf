variable "buckets" {
  description = "Map of S3 buckets to create"
  type = map(object({
    environment       = string
    versioning_enabled = bool
  }))
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
