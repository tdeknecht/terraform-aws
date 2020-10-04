# ------------------------------------------------------------------------------
# Outputs
# ------------------------------------------------------------------------------

output "id" {
  description = "The name of the bucket."
  value       = aws_s3_bucket.s3_bucket.id
}

output "arn" {
  description = "The ARN of the bucket. Will be of format `arn:aws:s3:::bucketname`."
  value       = aws_s3_bucket.s3_bucket.arn
}

output "bucket_domain_name" {
  description = "The bucket domain name. Will be of format `bucketname.s3.amazonaws.com`."
  value       = aws_s3_bucket.s3_bucket.bucket_domain_name
}