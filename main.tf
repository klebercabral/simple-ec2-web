provider "aws" {
  region                    = var.region
  version                   = "~> 2.0"
}
data "http" "myip" {
  url = "https://api.ipify.org/"
}
data "aws_vpc" "default" {
  default = true
}
data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}
data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"

    values = [
      "amzn2-ami-hvm-*-x86_64-gp2",
    ]
  }

  filter {
    name = "owner-alias"

    values = [
      "amazon",
    ]
  }
}
module "firewall" {
  source                    = "terraform-aws-modules/security-group/aws"
  name                      = "lab-terraform-aws-sg"
  vpc_id                    = data.aws_vpc.default.id
  egress_with_cidr_blocks   = [
  {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = "0.0.0.0/0"
  }
  ]
  ingress_with_cidr_blocks  = [
  {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    description = "ssh"
    cidr_blocks = "${chomp(data.http.myip.body)}/32"
  },
  {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    description = "http"
    cidr_blocks = "${chomp(data.http.myip.body)}/32"
  },
  ]
}
module "ec2" {
  source                    = "terraform-aws-modules/ec2-instance/aws"
  name                      = "lab-terraform-aws"
  instance_count            = 1
  ami                       = data.aws_ami.amazon_linux.id
  instance_type             = var.ec2_instance_type
  key_name                  = var.key_pair_name
  vpc_security_group_ids    = [module.firewall.this_security_group_id]
  subnet_id                 = tolist(data.aws_subnet_ids.all.ids)[0]
}
output "public1" {
  value = module.ec2.public_ip[0]
}