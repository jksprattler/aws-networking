terraform {
  backend "s3" {
    bucket         = "jennas-tf-statefiles-master"
    dynamodb_table = "tf-statelocks"
    key            = "global/iam/terraform.tfstate"
    region         = "us-east-1"
    profile        = "default"
    encrypt        = true
  }
}
