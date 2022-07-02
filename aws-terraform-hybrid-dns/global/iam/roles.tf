resource "aws_iam_instance_profile" "EC2profile" {
  name = "EC2profile"
  role = aws_iam_role.EC2Role.name
}

resource "aws_iam_role" "EC2Role" {
  name               = "EC2Role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
           "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
EOF    

}

resource "aws_iam_role_policy_attachment" "EC2Role-ssmcore-attach" {
  role       = aws_iam_role.EC2Role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "EC2Role-ssmpatch-attach" {
  role       = aws_iam_role.EC2Role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMPatchAssociation"
}
