terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "tls_private_key" "devops" {
  algorithm = "ED25519"
}

resource "local_sensitive_file" "devops_private_key" {
  filename        = "${path.module}/../Devops_Lab_App.pem"
  content         = tls_private_key.devops.private_key_openssh
  file_permission = "0600"
}

resource "aws_key_pair" "devops" {
  key_name   = "Devops_Lab_App_TF"
  public_key = tls_private_key.devops.public_key_openssh
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "devops" {
  name        = "devops-lab-sg"
  description = "Allow SSH, Jenkins, and app access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-lab-sg"
  }
}

resource "aws_instance" "devops" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  key_name               = aws_key_pair.devops.key_name
  vpc_security_group_ids = [aws_security_group.devops.id]
  user_data              = file("${path.module}/user_data.sh")

  tags = {
    Name = "devops-lab-ec2"
  }
}