environment        = "prod"
vpc_cidr           = "10.3.0.0/16"
az_count           = 3
enable_nat_gateway = false # true em prod real (~US$ 32/mês + tráfego)
instance_type      = "c7i-flex.large"
ec2_volume_gb      = 30
