variable "arch" {
  type = string

  validation {
    condition = (
      var.arch == "x86" || var.arch == "arm64"
    )
    error_message = "Valid architectures are 'x86' or 'arm64'."
  }
}

data "aws_ami" "aws_linux_2_x86" {
  count = var.arch == "x86" ? 1 : 0

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "image-id"
    values = ["ami-0742b4e673072066f"]
  }
}

data "aws_ami" "aws_linux_2_arm64" {
  count = var.arch == "arm64" ? 1 : 0

  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "image-id"
    values = ["ami-015f1226b535bd02d"]
  }
}

output "arn" { value = var.arch == "x86" ? data.aws_ami.aws_linux_2_x86[0].arn : data.aws_ami.aws_linux_2_arm64[0].arn }