# ACM Certificate module

A simple module for managing AWS ACM certificates.

## Example A: New Certificate Using DNS Validation

```terraform
module "acm_cert_example" {
  source = "git::https://github.com/tdeknecht/aws-terraform//modules/network/acm_certificate/"

  ou                        = "test"
  certificate_domain_name   = "example.com"
  validation_domain_name    = "example.com"
  validation_method         = "DNS"
  subject_alternative_names = ["www.example.com"]
  tags                      = local.tags
}
output "certificate_arn" { value = module.acm_cert_example.certificate_arn }
```