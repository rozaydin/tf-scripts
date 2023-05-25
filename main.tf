# terraform {
#   backend "s3" {
#     bucket  = "ts-state-oracle-dev"
#     key     = "state/oracle-dev"
#     region  = "us-west-2"
#     profile = "deckers-dev-admin"
#   }
# }

provider "aws" {
  region  = "eu-central-1"
  profile = "rozaydin"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "apollo"
  cidr = "10.58.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b"]
  public_subnets  = ["10.58.1.0/24", "10.58.2.0/24"]
  private_subnets = ["10.58.5.0/24", "10.58.6.0/24"]

  enable_nat_gateway = false
  tags               = var.tags
}

# security groups
resource "aws_security_group" "client_vpn_sg" {
  name        = "client-vpm-sg"
  description = "Allow HTTP and SSH traffic via Terraform"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# certificates

resource "aws_acm_certificate" "client_vpn_server_cert" {
  private_key      = file("./easyrsa/keys/server.key")
  certificate_body = file("./easyrsa/keys/server.crt")
}

resource "aws_acm_certificate" "client_vpn_client1_cert" {
  private_key      = file("./easyrsa/keys/client1.domain.tld.key")
  certificate_body = file("./easyrsa/keys/client1.domain.tld.crt")
}

resource "aws_acm_certificate" "client_vpn_client2_cert" {
  private_key      = file("./easyrsa/keys/client2.domain.tld.key")
  certificate_body = file("./easyrsa/keys/client2.domain.tld.crt")
}

# cloudwatch log group

resource "aws_cloudwatch_log_group" "client_vpn_log_group" {
  name = "clientvpn"
  tags = var.tags
}

# Client VPN

resource "aws_ec2_client_vpn_endpoint" "client_vpn" {

  depends_on = [aws_cloudwatch_log_group.client_vpn_log_group]

  description            = "client_vpn"
  server_certificate_arn = aws_acm_certificate.client_vpn_server_cert.arn
  client_cidr_block      = "172.0.0.0/16"

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = aws_acm_certificate.client_vpn_server_cert.arn
  }

  connection_log_options {
    enabled               = true
    cloudwatch_log_group  = aws_cloudwatch_log_group.client_vpn_log_group.name
    # cloudwatch_log_stream = 
  }

}

resource "aws_ec2_client_vpn_network_association" "vpn_zone" {
  for_each               = { for k, instance in module.vpc.private_subnets[*] : k => instance }
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = each.value
  security_groups        = [aws_security_group.client_vpn_sg.id]
}

