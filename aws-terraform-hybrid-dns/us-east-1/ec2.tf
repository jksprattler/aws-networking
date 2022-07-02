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
