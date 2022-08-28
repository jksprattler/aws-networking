# Authenticate by:
# $ aws configure
#
# or:
# $ export AWS_ACCESS_KEY_ID='<key goes here>'
# $ export AWS_SECRET_ACCESS_KEY='<secret goes here>'
#
# or just set profile
# $ export AWS_PROFILE='<your aws account profile>'

provider "aws" {
  region  = var.region
}
