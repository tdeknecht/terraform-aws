# ------------------------------------------------------------------------------
# data, variables, locals, etc.
# ------------------------------------------------------------------------------

data "aws_region" "current" {}

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

  dynamic "website" {
    for_each = length(var.index_document) > 0 || length(var.redirect_all_requests_to) > 0 ? toset([true]) : []

    content {
      index_document           = length(var.index_document) > 0 ? var.index_document : null
      error_document           = length(var.error_document) > 0 ? var.error_document : null
      redirect_all_requests_to = length(var.redirect_all_requests_to) > 0 ? var.redirect_all_requests_to : null
      routing_rules            = length(var.routing_rules) > 0 ? var.routing_rules : null
    }
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

  # lifecycle {
  #   prevent_destroy = true
  # }

  tags = merge(
    {
      "Name" = "${var.use_case}-${var.ou}-${data.aws_region.current.name}"
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
