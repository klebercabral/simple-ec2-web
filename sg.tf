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