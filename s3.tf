resource "random_string" "this" {
  length  = 8
  upper   = false
  lower   = true
  numeric = true
  special = false
}

resource "aws_s3_bucket" "this" {
  bucket = "prowler-reports-${random_string.this.result}"
  #acl    = "log-delivery-write"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  lifecycle_rule {
    id                                     = "Permanently delete objects after ${var.s3_delete_objects_after} days"
    enabled                                = true
    prefix                                 = "*"
    abort_incomplete_multipart_upload_days = var.s3_delete_objects_after
    expiration {
      expired_object_delete_marker = false
      days                         = var.s3_delete_objects_after
    }
  }
  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket                  = aws_s3_bucket.this.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "ObjectWriter"
  }
}
