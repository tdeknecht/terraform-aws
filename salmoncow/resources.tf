# ******************************************************************************
# Application resources
# ******************************************************************************

# EC2 using AWS CloudFormation EC2 module. Module S3 location
resource "aws_s3_bucket_object" "cfm_ec2_public" {
    bucket = module.s3_bucket_salmoncow.id
    key    = "cloudformation_stacks/ec2_public.yaml"
    source = "../../cloudformation/modules/compute/ec2_public.yaml"
    etag   = filemd5("../../cloudformation/modules/compute/ec2_public.yaml")

    tags   = local.tags
}

# EC2 using AWS CloudFormation EC2 module
resource "aws_cloudformation_stack" "public_ec2" {
    depends_on   = [aws_s3_bucket_object.cfm_ec2_public]
    
    name         = "public-ec2"
    template_url = format("https://%s.s3.amazonaws.com/%s",module.s3_bucket_salmoncow.id,aws_s3_bucket_object.cfm_ec2_public.id)
    tags         = local.tags

    parameters = {
        VpcIdParm = module.vpc_one.vpc_id
        RegionId  = local.region
        SubnetId  = module.vpc_one.public_subnet_ids[0]
    }
}