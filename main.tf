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

# 

# Certificate

resource "aws_acm_certificate" "cert" {

  domain_name       = "test.ridvanozaydin.com"
  validation_method = "DNS"

  tags = var.tags

  validation_option {
    domain_name       = "test.ridvanozaydin.com"
    validation_domain = "ridvanozaydin.com"
  }

  # to replace a certificate which is currently in use 
  lifecycle {
    create_before_destroy = true
  }
}

data "aws_route53_zone" "ridvanozaydincom" {
  name         = "ridvanozaydin.com"
  private_zone = false
}

resource "aws_route53_record" "testridvanozaydincom" {
  for_each = {
    for dvo in aws_acm_certificate.cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.ridvanozaydincom.zone_id
}


resource "aws_acm_certificate_validation" "testridvanozaydincom" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for record in aws_route53_record.testridvanozaydincom : record.fqdn]
}

# Client VPN

# resource "aws_ec2_client_vpn_endpoint" "example" {
#   description            = "clientvpn-example"
#   server_certificate_arn = aws_acm_certificate.cert.arn
#   client_cidr_block      = "172.0.0.0/16"

#   authentication_options {
#     type                       = "certificate-authentication"
#     root_certificate_chain_arn = aws_acm_certificate.cert.arn
#   }
  
# }