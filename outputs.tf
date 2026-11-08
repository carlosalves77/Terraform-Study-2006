# ---------- Rede ----------

output "vpc_id" {
  description = "ID da VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block da VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = aws_subnet.private[*].id
}

# ---------- Infra ----------

# output "ec2_large_ssh" {
#   description = "Comando SSH para a instância ec2-large"
#   value       = var.key_name == null ? "sem key pair — use SSM/EC2 Instance Connect" : "ssh -i ~/.ssh/${var.key_name}.pem ubuntu@${aws_instance.ec2-large.public_ip}"
# }
