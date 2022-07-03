output "aws_route53_resolver_inbound_endpoint_ips" {
  value = aws_route53_resolver_endpoint.m4linbound.ip_address
}
