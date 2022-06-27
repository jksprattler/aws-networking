terraform {
  backend "s3" {
    bucket         = "jennas-tf-statefiles-master"
    dynamodb_table = "tf-statelocks"
    key            = "us-east-1/terraform.tfstate"
    region         = "us-east-1"
    profile        = "default"
    encrypt        = true
  }
}
