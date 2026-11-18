# terraform-study-2026

Laboratório pessoal de estudo de Terraform provisionando infraestrutura na AWS.

## O que é criado

| Recurso | Detalhes |
|---|---|
| VPC | CIDR configurável via tfvars |
| Subnets públicas | 1 por AZ, com IP público automático |
| Subnets privadas | 1 por AZ, range `+100` no terceiro octeto |
| Internet Gateway | Anexado à VPC |
| NAT Gateway | Opcional (`enable_nat_gateway = true`) |
| Route tables | Pública (via IGW) e privada (via NAT se habilitado) |
| Security Group | SSH (porta 22) liberado apenas para `my_ip` |
| EC2 (`ec2-large`) | Ubuntu 24.04 LTS, `c7i-flex.large`, EBS `gp3` criptografado, IMDSv2 obrigatório, IP fixo na segunda subnet pública |

## Pré-requisitos

- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.2
- AWS CLI configurado (`aws configure`)
- Um EC2 Key Pair criado na região alvo

## Uso rápido

```bash
# Inicializar (backend S3 já ativo em backend.tf)
terraform init

# Planejar
TF_VAR_my_ip=$(curl -s ifconfig.me) terraform plan -var-file="environments/test.tfvars"

# Aplicar
TF_VAR_my_ip=$(curl -s ifconfig.me) terraform apply -var-file="environments/test.tfvars"

# Destruir
TF_VAR_my_ip=$(curl -s ifconfig.me) terraform destroy -var-file="environments/test.tfvars"
```

## Variáveis principais

| Variável | Padrão | Descrição |
|---|---|---|
| `aws_region` | `us-east-2` | Região AWS |
| `project_name` | `carldev-lab` | Prefixo de todos os recursos |
| `environment` | — | `test`, `qa`, `staging` ou `prod` (obrigatório) |
| `my_ip` | — | Seu IP público para a regra de ingress SSH (obrigatório) |
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

O backend S3 está ativo em `backend.tf` usando **native S3 locking** (`use_lockfile = true`, disponível a partir do Terraform 1.10):

```hcl
backend "s3" {
  bucket       = "carldev-lab-tfstate"
  key          = "terraform.tfstate"
  region       = "us-east-2"
  use_lockfile = true
  encrypt      = true
}
```

Para criar o bucket pela primeira vez:

```bash
bash s3-bucket.sh
```

## CI/CD (GitHub Actions)

| Workflow | Gatilho | Ação |
|---|---|---|
| `terraform-plan.yml` | PR para `main` | `terraform plan -var-file="environments/prod.tfvars"` |
| `terraform-apply.yml` | Push para `main` | `terraform apply -auto-approve -var-file="environments/prod.tfvars"` |

O IP público é injetado via secret `MY_PUBLIC_IP` como `TF_VAR_my_ip`. O apply roda no GitHub Environment **production** (suporta gate de aprovação manual).

## Estrutura de arquivos

```
.
├── backend.tf                    # Provider AWS e backend S3
├── variables.tf                  # Declaração de variáveis
├── locals.tf                     # Valores derivados (AZs, config EC2)
├── network.tf                    # VPC, subnets, IGW, NAT, SGs, route tables
├── infra.tf                      # Instância EC2
├── outputs.tf                    # Outputs da infraestrutura
├── s3-bucket.sh                  # Script para criar o bucket de backend
├── environments/
│   ├── test.tfvars
│   ├── qa.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
└── .github/workflows/
    ├── terraform-plan.yml
    └── terraform-apply.yml
```
