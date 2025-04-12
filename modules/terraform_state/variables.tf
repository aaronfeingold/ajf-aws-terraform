variable "terraform_state_bucket" {
  description = "Name of the S3 bucket for Terraform state"
  type        = string
  default     = "terraform-state"
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "project-name"
}

variable "organization_name" {
  description = "Name of the organization"
  type        = string
  default     = "org-name"
}

