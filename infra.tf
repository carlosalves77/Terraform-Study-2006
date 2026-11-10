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
  EOF

    # # Ubuntu 24.04 uses socket-activated SSH; override the socket's port,
    # # not just sshd_config (which the socket ignores for the ListenStream).
    # mkdir -p /etc/systemd/system/ssh.socket.d
    # printf '[Socket]\nListenStream=\nListenStream=50222\n' \
    #   > /etc/systemd/system/ssh.socket.d/override.conf
    # sed -i 's/^#\?Port .*/Port 50222/' /etc/ssh/sshd_config
    # systemctl daemon-reload
    # systemctl restart ssh.socket
  

  user_data_replace_on_change = true

  lifecycle {
    ignore_changes = [ami] # evita recriar a instância quando sair uma AMI nova
  }

  tags = {
    Name        = "${var.project_name}-ec2-large"
    Environment = var.environment
  }
}
