
# -- object/main.tf -- #

resource "aws_s3_bucket" "s3_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_object" "object" {
  bucket       = var.bucket_name
  key          = "index.html"
  source       = var.source_file #"object/index.html"
  content_type = "text/html"
  etag = filemd5(var.source_file)
  #acl  = "public-read"
  depends_on = [
    aws_s3_bucket.s3_bucket
  ]
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket-config" {
  bucket = aws_s3_bucket.s3_bucket.id

  rule {
    id = "log"

    expiration {
      days = 90
    }

    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 60
      storage_class = "GLACIER"
    }
  }
}