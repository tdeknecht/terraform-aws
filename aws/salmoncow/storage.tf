# ******************************************************************************
# S3
# ******************************************************************************

# Create backend.tf S3 bucket (yes, it's a circular dependency)
module "s3_bucket_tf_backend" {
    source = "../modules/storage/s3/s3_bucket/"

    ou        = local.ou
    use_case  = local.use_case
    tags      = local.tags

    bucket_name = local.use_case
}
