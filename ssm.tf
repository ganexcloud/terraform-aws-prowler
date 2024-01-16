resource "aws_ssm_parameter" "prowler_allowlist" {
  name  = "/prowler/allowlist"
  type  = "String"
  tier  = "Advanced"
  value = var.prowler_allowlist
}
