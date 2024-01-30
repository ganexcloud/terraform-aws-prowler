resource "aws_s3_bucket" "this" {
  bucket = "${local.s3_bucket_name_prefix}-prowler"
  #acl    = "log-delivery-write"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
  lifecycle_rule {
    id                                     = "Permanently delete reports after ${var.s3_delete_objects_after} days"
    enabled                                = true
    prefix                                 = "reports/"
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

resource "aws_s3_object" "allowlist" {
  bucket = aws_s3_bucket.this.id
  key    = "files/allowlist.yaml"
  source = local.prowler_allowlist_filepath
  etag   = filemd5(local.prowler_allowlist_filepath)
}

resource "aws_s3_object" "config" {
  bucket = aws_s3_bucket.this.id
  key    = "files/config.yaml"
  source = local.prowler_config_filepath
  etag   = filemd5(local.prowler_config_filepath)
}
