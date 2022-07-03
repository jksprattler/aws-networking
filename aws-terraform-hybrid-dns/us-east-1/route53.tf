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
