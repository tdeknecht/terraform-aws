# ------------------------------------------------------------------------------
# S3 bucket
# ------------------------------------------------------------------------------

resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket
  acl    = var.acl
  policy = var.policy

  versioning {
    enabled    = var.versioning
    mfa_delete = var.mfa_delete
  }

  lifecycle_rule {
    id      = "base"
    enabled = var.base_lifecycle_rule

    abort_incomplete_multipart_upload_days = 7

    noncurrent_version_expiration {
      days = var.noncurrent_version_expiration
    }

    expiration {
      expired_object_delete_marker = true
    }
  }

  tags = merge(
    {
      Name = "${var.use_case}-${var.ou}-${data.aws_region.current.name}"
    },
    var.tags
  )
}

resource "aws_s3_bucket_public_access_block" "this_s3_bucket" {
  bucket                  = aws_s3_bucket.s3_bucket.id
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}
