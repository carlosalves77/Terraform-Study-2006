# terraform-study-2026

Laboratório pessoal de estudo de Terraform provisionando infraestrutura na AWS.

## O que é criado

| Recurso | Detalhes |
|---|---|
| VPC | CIDR configurável (`10.0.0.0/16` por padrão) |
| Subnets públicas | 1 por AZ, com IP público automático |
| Subnets privadas | 1 por AZ, range `10.0.100+/24` |
| Internet Gateway | Anexado à VPC |
| NAT Gateway | Opcional (`enable_nat_gateway = true`) |
| Route tables | Pública (via IGW) e privada (via NAT se habilitado) |
| Security Group | SSH liberado apenas para o IP público de quem aplica |
| EC2 (`ec2-large`) | Ubuntu 24.04 LTS, `c7i-flex.large`, EBS `gp3` criptografado, IMDSv2 obrigatório |

## Pré-requisitos

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.2
- AWS CLI configurado (`aws configure`)
- Um EC2 Key Pair criado na região alvo

## Uso rápido

```bash
# Inicializar
terraform init

# Planejar (escolha um ambiente)
terraform plan -var="environment=test"

# Aplicar
terraform apply -var="environment=test"

# Destruir
terraform destroy -var="environment=test"
```

## Variáveis principais

| Variável | Padrão | Descrição |
|---|---|---|
| `aws_region` | `us-east-2` | Região AWS |
| `project_name` | `carldev-lab` | Prefixo de todos os recursos |
| `environment` | — | `test`, `qa`, `staging` ou `prod` (obrigatório) |
| `vpc_cidr` | `10.0.0.0/16` | CIDR da VPC |
| `az_count` | `2` | Número de Availability Zones |
| `enable_nat_gateway` | `false` | Habilitar NAT Gateway para subnets privadas |
| `key_name` | `carl-terraform` | Nome do EC2 Key Pair existente |
| `instance_type` | `c7i-flex.large` | Tipo da instância EC2 |
| `ec2_volume_gb` | `30` | Tamanho do volume root em GB |

## Outputs

| Output | Descrição |
|---|---|
| `vpc_id` | ID da VPC criada |
| `vpc_cidr_block` | CIDR da VPC |
| `public_subnet_ids` | IDs das subnets públicas |
| `private_subnet_ids` | IDs das subnets privadas |
| `ec2_large_ssh` | Comando SSH pronto para usar |

## Backend remoto (S3)

O backend S3 está comentado em `backend.tf`. Para habilitá-lo, descomente e ajuste:

```hcl
backend "s3" {
  bucket         = "carldev-lab-tfstate"
  key            = "terraform.tfstate"
  region         = "us-east-2"
  dynamodb_table = "carldev-lab-tflock"
  encrypt        = true
}
```

## Estrutura de arquivos

```
.
├── backend.tf    # Provider AWS e configuração de backend
├── variables.tf  # Declaração de variáveis
├── locals.tf     # Valores derivados (AZs, config EC2)
├── network.tf    # VPC, subnets, IGW, NAT, SGs, route tables
├── infra.tf      # Instância EC2
└── outputs.tf    # Outputs da infraestrutura
```
