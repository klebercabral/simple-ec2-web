output "public1" {
  value = module.ec2.public_ip[0]
}