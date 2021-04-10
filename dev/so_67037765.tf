module "ami" {
    source = "./so_67037765"

    arch = "arm64"
}

output "ami_arn" { value = module.ami.arn }