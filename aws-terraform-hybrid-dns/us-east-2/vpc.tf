resource "aws_vpc" "onpremvpc" {
  cidr_block           = "192.168.10.0/24"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "micros4l-onprem"
  }
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "onprem-private-a" {
  vpc_id            = aws_vpc.onpremvpc.id
  cidr_block        = "192.168.10.0/25"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "onprem-private-a"
  }
}

resource "aws_subnet" "onprem-private-b" {
  vpc_id            = aws_vpc.onpremvpc.id
  cidr_block        = "192.168.10.128/25"
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "onprem-private-b"
  }
}

resource "aws_route_table" "onprem-private-rt" {
  vpc_id = aws_vpc.onpremvpc.id
  tags = {
    Name = "onprem-private-rt"
  }
}

resource "aws_route_table_association" "rt-assoc-priv-a" {
  subnet_id      = aws_subnet.onprem-private-a.id
  route_table_id = aws_route_table.onprem-private-rt.id
}

resource "aws_route_table_association" "rt-assoc-priv-b" {
  subnet_id      = aws_subnet.onprem-private-b.id
  route_table_id = aws_route_table.onprem-private-rt.id
}

resource "aws_vpc_endpoint" "onpremssminterfaceendpoint" {
  vpc_id = aws_vpc.onpremvpc.id
  subnet_ids = [
    aws_subnet.onprem-private-a.id,
    aws_subnet.onprem-private-b.id
  ]
  service_name      = "com.amazonaws.${var.region}.ssm"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.OnPremSecurityGroup.id
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "onpremssmec2messagesinterfaceendpoint" {
  vpc_id = aws_vpc.onpremvpc.id
  subnet_ids = [
    aws_subnet.onprem-private-a.id,
    aws_subnet.onprem-private-b.id
  ]
  service_name      = "com.amazonaws.${var.region}.ec2messages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.OnPremSecurityGroup.id
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "onpremssmmessagesinterfaceendpoint" {
  vpc_id = aws_vpc.onpremvpc.id
  subnet_ids = [
    aws_subnet.onprem-private-a.id,
    aws_subnet.onprem-private-b.id
  ]
  service_name      = "com.amazonaws.${var.region}.ssmmessages"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.OnPremSecurityGroup.id
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "onprems3endpoint" {
  vpc_id          = aws_vpc.onpremvpc.id
  route_table_ids = [aws_route_table.onprem-private-rt.id]
  service_name    = "com.amazonaws.${var.region}.s3"
}
