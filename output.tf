output "public" {
  value = module.ec2.public_ip[*]
}