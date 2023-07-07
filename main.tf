terraform {
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
  owners = ["amazon"]
}

resource "aws_instance" "misskey" {
  ami = data.aws_ami.amazon_linux.id
  instance_type = "t3a.medium"

  tags = {
    Name = "Misskey"
  }
}

resource "cloudflare_zone" "social" {
  account_id = var.cloudflare_account_id
  zone = "integraldx.social"
}

resource "cloudflare_record" "misskey" {
  zone_id = cloudflare_zone.social.id
  name = "@"
  value = aws_instance.misskey.public_ip
  type = "A"
  ttl = 3600
}
