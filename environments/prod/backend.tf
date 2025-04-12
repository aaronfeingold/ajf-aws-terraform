terraform {
  backend "s3" {
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    # Bucket will be provided via CLI or environment variables
  }
}
