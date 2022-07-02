resource "aws_vpc" "awsvpc" {
  cidr_block           = "10.10.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "micros4l-aws"
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

resource "aws_security_group" "AWSSecurityGroup" {
  name        = "AWSSecurityGroup"
  description = "Enable SSH and DNS"
  vpc_id      = aws_vpc.awsvpc.id

  ingress {
    description = "Allow SSH IPv4 IN"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP IPv4 IN"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow HTTPS IPv4 OUT - SSM"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS IPv4 IN - SSM"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow tcp DNS IN"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #  egress {
  #    description = "Allow tcp DNS OUT"
  #    from_port   = 53
  #    to_port     = 53
  #    protocol    = "tcp"
  #    cidr_blocks = ["0.0.0.0/0"]
  #  }   

  ingress {
    description = "Allow udp DNS IN"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #  egress {
  #    description = "Allow udp DNS OUT"
  #    from_port   = 53
  #    to_port     = 53
  #    protocol    = "udp"
  #    cidr_blocks = ["0.0.0.0/0"]
  #  }    

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "AWSDefaultInstanceSecurityGroupSelfReferenceRule" {
  type              = "ingress"
  from_port         = 0
  to_port           = 65535
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.AWSSecurityGroup.id
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
