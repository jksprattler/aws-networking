resource "aws_route53_zone" "awsdnsm4lcom" {
  name = "aws.microgreens4life.org"

  vpc {
    vpc_id = aws_vpc.awsvpc.id
  }
}

resource "aws_route53_record" "awsdnsm4lcomweb" {
  zone_id = aws_route53_zone.awsdnsm4lcom.zone_id
  name    = "web.aws.microgreens4life.org"
  type    = "A"
  ttl     = "60"
  records = [
    aws_instance.awsec2a.private_ip,
    aws_instance.awsec2b.private_ip
  ]
}

resource "aws_route53_resolver_endpoint" "m4linbound" {
  name      = "m4linbound"
  direction = "INBOUND"

  security_group_ids = [aws_security_group.AWSSecurityGroup.id]

  ip_address {
    subnet_id = aws_subnet.micros4l-private-a.id
  }

  ip_address {
    subnet_id = aws_subnet.micros4l-private-b.id
  }

}

resource "aws_route53_resolver_endpoint" "m4loutbound" {
  name      = "m4loutbound"
  direction = "OUTBOUND"

  security_group_ids = [aws_security_group.AWSSecurityGroup.id]

  ip_address {
    subnet_id = aws_subnet.micros4l-private-a.id
  }

  ip_address {
    subnet_id = aws_subnet.micros4l-private-b.id
  }

}

resource "aws_route53_resolver_rule" "m4loutbound_fwd" {
  domain_name          = "corp.microgreens4life.org"
  name                 = "m4l-corpzone"
  rule_type            = "FORWARD"
  resolver_endpoint_id = aws_route53_resolver_endpoint.m4loutbound.id

  target_ip {
    ip = var.onpremdnsa_priv_ip
  }

  target_ip {
    ip = var.onpremdnsb_priv_ip
  }
}

resource "aws_route53_resolver_rule_association" "m4loutbound_fwd_rule" {
  resolver_rule_id = aws_route53_resolver_rule.m4loutbound_fwd.id
  vpc_id           = aws_vpc.awsvpc.id
}
