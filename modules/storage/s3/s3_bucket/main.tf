# ------------------------------------------------------------------------------
# S3 bucket
# ------------------------------------------------------------------------------

resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
  acl    = "private"

  tags = merge(
    { Name = "${var.use_case}-${var.ou}-${data.aws_region.current.name}" },
    var.tags
  )
}
