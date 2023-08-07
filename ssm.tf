resource "aws_ssm_parameter" "prowler_allowlist" {
  name  = "/prowler/allowlist"
  type  = "String"
  value = var.prowler_allowlist
}
