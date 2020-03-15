# ******************************************************************************
# S3 bucket object
# ******************************************************************************

resource "aws_s3_bucket_object" "object" {
    bucket = var.bucket_name
    key    = var.key
    source = var.path_to_object
}

