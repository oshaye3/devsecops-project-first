output "s3_bucket_devsecops_id" {
  description = "The name of the bucket for S3 devsecops"
  value       = aws_s3_bucket.devsecops.id
}

output "s3_bucket_tfstate_devsecops_id" {
  description = "The name of the bucket for S3 tfstate devsecops"
  value       = aws_s3_bucket.tfstate_devsecops.id
}
