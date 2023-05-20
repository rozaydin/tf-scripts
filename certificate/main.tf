provider "aws" {
  region  = "eu-central-1"
  profile = "rozaydin"
}

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