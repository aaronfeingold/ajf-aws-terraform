terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

data "aws_s3_bucket" "bucket" {
  for_each = var.buckets
  bucket   = each.key
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  for_each = var.buckets

  bucket = data.aws_s3_bucket.bucket[each.key].id
  versioning_configuration {
    status = each.value.versioning_enabled ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  for_each = var.buckets

  bucket = data.aws_s3_bucket.bucket[each.key].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access_block" {
  for_each = var.buckets

  bucket = data.aws_s3_bucket.bucket[each.key].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
