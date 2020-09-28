# ------------------------------------------------------------------------------
# data, variables, locals, etc.
# ------------------------------------------------------------------------------

data "aws_region" "current" {}

locals {
  # if host (index_document) or redirect (redirect_all_requests_to), it's a website
  # website_type = length(var.index_document) > 0 ? "host" : "redirect"

  website = length(var.index_document) > 0 || length(var.redirect_all_requests_to) > 0 ? { 
    "config" = {
      "index_document" = var.index_document,
      "error_document" = var.error_document,
      "routing_rules"  = var.routing_rules,
      "redirect_all_requests_to" = var.redirect_all_requests_to,
    }
  } : {}
}

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
    for_each = local.website

    content {
      index_document           = website.value.index_document
      error_document           = website.value.error_document
      redirect_all_requests_to = website.value.redirect_all_requests_to
      routing_rules            = website.value.routing_rules
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
