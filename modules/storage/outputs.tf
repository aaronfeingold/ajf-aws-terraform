output "bucket_arns" {
  description = "ARNs of the created S3 buckets"
  value       = { for k, v in aws_s3_bucket.bucket : k => v.arn }
}

output "bucket_names" {
  description = "Names of the created S3 buckets"
  value       = { for k, v in aws_s3_bucket.bucket : k => v.id }
}
