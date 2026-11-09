data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ---------- EC2 ----------

resource "aws_instance" "ec2-large" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = local.ec2.type
  private_ip                  = local.ec2.private_ip
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  key_name                    = var.key_name
  subnet_id                   = aws_subnet.public[1].id
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  associate_public_ip_address = true

  # Força IMDSv2 (boa prática de segurança)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2 # 2 se for rodar containers/pods que acessam metadata
  }

  # ---------- EBS (root) ----------
  root_block_device {
    volume_type           = "gp3"
    volume_size           = local.ec2.volume_gb
    encrypted             = true
    delete_on_termination = true

    tags = {
      Name = "${var.project_name}-ec2-large-root"
    }
  }

  user_data = <<-EOF
    #!/bin/bash
    set -euo pipefail
    hostnamectl set-hostname ${var.project_name}
    apt-get update -y
    apt-get upgrade -y

    # Set SSH Port
    sed -i 's/^#\?Port .*/Port 50222/' /etc/ssh/sshd_config
    systemctl restart sshd
  EOF

  

  user_data_replace_on_change = true

  lifecycle {
    ignore_changes = [ami] # evita recriar a instância quando sair uma AMI nova
  }

  tags = {
    Name        = "${var.project_name}-ec2-large"
    Environment = var.environment
  }
}
