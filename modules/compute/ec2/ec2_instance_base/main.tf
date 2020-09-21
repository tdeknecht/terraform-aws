# ------------------------------------------------------------------------------
# EC2: AWS Linux
# ------------------------------------------------------------------------------

locals {
  module_security_groups = var.ssh_from_my_ip ? [
    aws_security_group.allow_ssh[0].id,
    ] : []
}

resource "aws_instance" "this" {
  ami                    = length(var.ami) > 0 ? var.ami : data.aws_ami.aws_linux_2.id
  instance_type          = var.instance_type
  iam_instance_profile   = var.iam_instance_profile
  vpc_security_group_ids = concat(var.security_group_ids, local.module_security_groups)
  subnet_id              = var.subnet_id
  user_data              = var.user_data
  tags                   = var.tags
}

data "aws_ami" "aws_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_eip" "this" {
  count = var.public_ip ? 1 : 0

  instance = aws_instance.this.id
  vpc      = true
}

data "http" "checkip" { 
  url = "http://icanhazip.com" 
}

data "aws_subnet" "selected" {
  id = var.subnet_id
}

resource "aws_security_group" "allow_ssh" {
  count = var.ssh_from_my_ip ? 1 : 0

  name        = "ssh_from_requester_ip"
  description = "Allow SSH from requesters current public IP"
  vpc_id      = data.aws_subnet.selected.vpc_id
  tags = merge(
    {
      "Name" = "${var.use_case}-${var.ou}-requester-ip-ssh-sg"
    },
    var.tags
  )

  ingress {
    description = "SSH from requesters current public IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.checkip.body)}/32"]
  }
}