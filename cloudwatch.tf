resource "aws_cloudwatch_event_rule" "this" {
  name                = "prowler"
  description         = "Run Prowler"
  schedule_expression = var.prowler_schedule
  tags                = var.tags
}

resource "aws_cloudwatch_event_target" "this" {
  arn      = aws_codebuild_project.this.arn
  rule     = aws_cloudwatch_event_rule.this.name
  role_arn = aws_iam_role.trigger.arn
}

resource "aws_cloudwatch_event_rule" "notification" {
  count         = var.create_cloudwatch_event_rule && var.create_cloudwatch_event_target ? 1 : 0
  name          = "security-hub-prowler-notifications"
  description   = "Send Security Hub Notifications."
  event_pattern = var.cloudwatch_event_pattern
  tags          = var.tags
}

resource "aws_cloudwatch_event_target" "notification" {
  count    = var.create_cloudwatch_event_rule && var.create_cloudwatch_event_target ? 1 : 0
  arn      = var.cloudwatch_event_target_arn
  rule     = aws_cloudwatch_event_rule.notification[0].name
  role_arn = aws_iam_role.notification[0].arn
  dynamic "input_transformer" {
    for_each = length(var.cloudwatch_event_target_transformer) > 0 ? [var.cloudwatch_event_target_transformer] : []
    content {
      input_paths    = input_transformer.value.input_paths
      input_template = input_transformer.value.input_template
    }
  }
}

resource "aws_iam_role" "notification" {
  count              = var.create_cloudwatch_event_rule ? 1 : 0
  name               = "prowler-notifications"
  assume_role_policy = data.aws_iam_policy_document.notifications_assume_role_policy.json
  inline_policy {
    name   = "prowler-notifications-policy"
    policy = var.cloudwatch_event_role_policy
  }
}

resource "aws_cloudwatch_metric_alarm" "codebuild_failure_alarm" {
  count               = var.create_codebuild_cloudwatch_alarm ? 1 : 0
  alarm_name          = "[${data.aws_iam_account_alias.current.account_alias}] codebuild-prowler-build-failed"
  alarm_description   = "[${data.aws_iam_account_alias.current.account_alias}] Codebuild Prowler project build failed (P3)"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "FailedBuilds"
  namespace           = "AWS/CodeBuild"
  period              = 300
  statistic           = "Sum"
  threshold           = 1
  treat_missing_data  = "ignore"
  tags                = var.tags

  dimensions = {
    ProjectName = aws_codebuild_project.this.name
  }

  alarm_actions = var.codebuild_notification_sns_topic_arn
}
