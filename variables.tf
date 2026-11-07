variable "aws_region" {
  description = "Região AWS onde tudo será criado"
  type        = string
  default     = "us-east-2"
}

variable "project_name" {
  description = "Prefixo usado no nome de todos os recursos"
  type        = string
  default     = "carldev-lab"


  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Use apenas minúsculas, números e hífen."
  }
}

variable "environment" {
  description = "Ambiente (test, qa, staging, prod) — definido em environments/<env>.tfvars"
  type        = string

  validation {
    condition     = contains(["test", "qa", "staging", "prod"], var.environment)
    error_message = "Use test, qa, staging ou prod."
  }
}

# ---------------- Rede ----------------

variable "vpc_cidr" {
  description = "Bloco CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_count" {
  description = "Quantas Availability Zones usar"
  type        = number
  default     = 2
}

variable "enable_nat_gateway" {
  description = <<-EOT
  EOT
  type        = bool
  default     = false
}


variable "key_name" {
  description = "Nome de um EC2 Key Pair já existente na região."
  type        = string
  default     = "carl-terraform"
}

# ---------------- Compute ----------------

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "c7i-flex.large"
}

variable "ec2_volume_gb" {
  description = "Tamanho (GB) do volume EBS root da EC2"
  type        = number
  default     = 30
}