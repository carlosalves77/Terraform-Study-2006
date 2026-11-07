locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)

  ec2 = {
    type       = var.instance_type
    private_ip = cidrhost(aws_subnet.public[1].cidr_block, 10) 
    volume_gb  = var.ec2_volume_gb
  }
}
