resource "aws_securityhub_product_subscription" "this" {
  count       = var.enable_security_hub_subscription ? 1 : 0
  product_arn = "arn:aws:securityhub:${data.aws_region.current.name}::product/prowler/prowler"
}
