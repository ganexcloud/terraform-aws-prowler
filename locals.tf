locals {
  s3_bucket_name_prefix     = var.s3_bucket_name_prefix == null ? data.aws_iam_account_alias.current.account_alias : var.s3_bucket_name_prefix
  prowler_mutelist_filepath = var.prowler_mutelist_file == null ? "${path.module}/files/allowlist-default.yaml" : var.prowler_mutelist_file
  prowler_config_filepath   = var.prowler_config_file == null ? "${path.module}/files/config-default.yaml" : var.prowler_config_file
}
