provider "aws" {
  alias  = "accepter"
  region = "us-east-2"
}

resource "aws_vpc" "awsvpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "micros4l-aws"
  }
}

# VPC Peering connection from us-east-1 to us-east-2
resource "aws_vpc_peering_connection" "owner" {
  vpc_id      = aws_vpc.awsvpc.id
  peer_vpc_id = var.accepter_vpc_id
  peer_region = "us-east-2"
  auto_accept = false
  lifecycle {
    ignore_changes = [
      peer_vpc_id,
    ]
  }
}

resource "aws_vpc_peering_connection_accepter" "accepter" {
  vpc_peering_connection_id = aws_vpc_peering_connection.owner.id
  auto_accept               = true
  provider                  = aws.accepter
}

# VPC Peering routes
resource "aws_route" "owner" {
  route_table_id            = aws_route_table.micros4l-aws-rt.id
  destination_cidr_block    = "192.168.10.0/24"
  vpc_peering_connection_id = aws_vpc_peering_connection.owner.id
}

resource "aws_route" "accepter" {
  route_table_id            = var.accepter_route_table_id
  destination_cidr_block    = aws_vpc.awsvpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.owner.id
  provider                  = aws.accepter
  lifecycle {
    ignore_changes = [
      route_table_id,
    ]
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "micros4l-private-a" {
  vpc_id            = aws_vpc.awsvpc.id
  cidr_block        = "10.10.0.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "micros4l-private-a"
  }
}

resource "aws_subnet" "micros4l-private-b" {
  vpc_id            = aws_vpc.awsvpc.id
  cidr_block        = "10.10.10.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "micros4l-private-b"
  }
}

resource "aws_route_table" "micros4l-aws-rt" {
  vpc_id = aws_vpc.awsvpc.id
  tags = {
    Name = "micros4l-aws-rt"
  }
}

resource "aws_route_table_association" "rt-assoc-a" {
  subnet_id      = aws_subnet.micros4l-private-a.id
  route_table_id = aws_route_table.micros4l-aws-rt.id
}

resource "aws_route_table_association" "rt-assoc-b" {
  subnet_id      = aws_subnet.micros4l-private-b.id
  route_table_id = aws_route_table.micros4l-aws-rt.id
}

resource "aws_vpc_endpoint" "awsssminterfaceendpoint" {
  vpc_id = aws_vpc.awsvpc.id
  subnet_ids = [
    aws_subnet.micros4l-private-a.id,
    aws_subnet.micros4l-private-b.id
  ]
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.AWSSecurityGroup.id
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "awsssmec2messagesinterfaceendpoint" {
  vpc_id = aws_vpc.awsvpc.id
  subnet_ids = [
    aws_subnet.micros4l-private-a.id,
    aws_subnet.micros4l-private-b.id
  ]
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.AWSSecurityGroup.id
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "awsssmmessagesinterfaceendpoint" {
  vpc_id = aws_vpc.awsvpc.id
  subnet_ids = [
    aws_subnet.micros4l-private-a.id,
    aws_subnet.micros4l-private-b.id
  ]
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.AWSSecurityGroup.id
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "awss3endpoint" {
  vpc_id          = aws_vpc.awsvpc.id
  route_table_ids = [aws_route_table.micros4l-aws-rt.id]
  service_name    = "com.amazonaws.${var.region}.s3"
}
