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