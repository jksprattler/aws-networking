data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

data "aws_iam_instance_profile" "EC2profile" {
  name = "EC2profile"
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

  egress {
    description = "Allow tcp DNS OUT"
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow udp DNS IN"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow udp DNS OUT"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

resource "aws_instance" "awsec2a" {
  depends_on = [
    aws_vpc_endpoint.awsssminterfaceendpoint,
    aws_vpc_endpoint.awsssmec2messagesinterfaceendpoint,
    aws_vpc_endpoint.awsssmmessagesinterfaceendpoint
  ]
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t2.micro"
  iam_instance_profile   = data.aws_iam_instance_profile.EC2profile.name
  subnet_id              = aws_subnet.micros4l-private-a.id
  vpc_security_group_ids = [aws_security_group.AWSSecurityGroup.id]
  tags = {
    Name = "micros4l-awsec2a"
  }
  user_data = <<EOF
  #!/bin/bash -xe
  cd /tmp 
  sudo yum install -y https://s3.${var.region}.amazonaws.com/amazon-ssm-${var.region}/latest/linux_amd64/amazon-ssm-agent.rpm 
  sudo systemctl enable amazon-ssm-agent 
  sudo systemctl start amazon-ssm-agent

EOF
}

resource "aws_instance" "awsec2b" {
  depends_on = [
    aws_vpc_endpoint.awsssminterfaceendpoint,
    aws_vpc_endpoint.awsssmec2messagesinterfaceendpoint,
    aws_vpc_endpoint.awsssmmessagesinterfaceendpoint
  ]
  ami                    = data.aws_ami.amazon-linux-2.id
  instance_type          = "t2.micro"
  iam_instance_profile   = data.aws_iam_instance_profile.EC2profile.name
  subnet_id              = aws_subnet.micros4l-private-b.id
  vpc_security_group_ids = [aws_security_group.AWSSecurityGroup.id]
  tags = {
    Name = "micros4l-awsec2b"
  }
  user_data = <<EOF
  #!/bin/bash -xe
  cd /tmp 
  sudo yum install -y https://s3.${var.region}.amazonaws.com/amazon-ssm-${var.region}/latest/linux_amd64/amazon-ssm-agent.rpm
  sudo systemctl enable amazon-ssm-agent 
  sudo systemctl start amazon-ssm-agent

EOF  
}
