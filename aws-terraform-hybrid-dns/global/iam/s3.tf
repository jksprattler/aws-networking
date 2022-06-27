resource "aws_s3_bucket" "jennas-tf-statefiles-master" {
  bucket = "jennas-tf-statefiles-master"

  versioning {
    enabled = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

## Disable s3 bucket public access
resource "aws_s3_bucket_public_access_block" "jennas-tf-statefiles-master-access" {
  bucket = aws_s3_bucket.jennas-tf-statefiles-master.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
