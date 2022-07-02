terraform {
  backend "s3" {
    bucket  = "jennas-tf-statefiles-master"
    key     = "global/iam/terraform.tfstate"
    region  = "us-east-1"
    profile = "default"
    encrypt = true
  }
}
