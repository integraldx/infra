terraform {
  cloud {
    organization = "integraldx"

    workspaces {
      name = "infra"
    }
  }

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }

    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "aws" {
  region     = "ap-northeast-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "name"
    values = ["al2023-ami-2023*"]
  }
}

resource "aws_instance" "misskey" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t3a.medium"

  user_data = file("scripts/misskey_user_data.sh")

  vpc_security_group_ids = [aws_security_group.allow_web_access.id]

  tags = {
    Name      = "Misskey"
    Terraform = "true"
  }
}

resource "aws_security_group" "allow_web_access" {
  name        = "allow_web_access"
  description = "Allow http, https traffic"

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Terraform = "true"
  }
}

resource "aws_eip" "misskey_ip" {
  instance = aws_instance.misskey.id
}

resource "cloudflare_record" "misskey" {
  zone_id = var.cloudflare_dot_social_zone_id
  name    = "@"
  value   = aws_eip.misskey_ip.public_ip
  type    = "A"
  ttl     = 3600
}

resource "aws_s3_bucket" "misskey_deployment" {
  bucket = "misskey-deployment"

  tags = {
    Terraform = "true"
  }
}

resource "aws_codedeploy_deployment_config" "misskey_deployment_config" {
  deployment_config_name = "misskey-deployment-config"

  minimum_healthy_hosts {
    type = "HOST_COUNT"
    value = 1
  }
}
