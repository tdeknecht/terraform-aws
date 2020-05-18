# ******************************************************************************
# EC2: public instance
# ******************************************************************************

# EC2 using AWS CloudFormation EC2 module. Module S3 location
resource "aws_s3_bucket_object" "cfm_ec2_public" {
  bucket = module.s3_bucket_salmoncow.id
  key    = "cloudformation_stacks/ec2_public.yaml"
  source = "../../cloudformation/ec2_public.yaml"
  etag   = filemd5("../../cloudformation/ec2_public.yaml")

  tags = local.tags
}

# Learn our public IP address. Use this for the SSH rule for the instance
data "http" "checkip" { url = "http://icanhazip.com" }
output "my_public_ip" { value = chomp(data.http.checkip.body) }

# EC2 using AWS CloudFormation EC2 module
resource "aws_cloudformation_stack" "public_ec2" {
  depends_on = [aws_s3_bucket_object.cfm_ec2_public]

  name         = "public-ec2"
  template_url = format("https://%s.s3.amazonaws.com/%s", module.s3_bucket_salmoncow.id, aws_s3_bucket_object.cfm_ec2_public.id)
  tags         = local.tags

  parameters = {
    RegionId    = local.region
    VpcIdParm   = module.vpc_one.vpc_id
    SubnetId    = module.vpc_one.public_subnet_ids[0]
    KeyName     = "aws_salmoncow"
    SSHLocation = chomp(data.http.checkip.body)
  }
}

output cloudformation_ec2_public { value = aws_cloudformation_stack.public_ec2.outputs }