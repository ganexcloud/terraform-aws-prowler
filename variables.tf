variable "prowler_version" {
  description = "(Required) Prowler version"
  type        = string
  default     = "3.15.0"
}

variable "prowler_schedule" {
  description = "(Required) Prowler based on cron schedule"
  default     = "cron(0 12 ? * * *)"
  type        = string
}

variable "prowler_cli_options" {
  description = "(Required) Run Prowler With The Following Command"
  type        = string
  default     = "-S --compliance aws_foundational_security_best_practices_aws aws_well_architected_framework_security_pillar_aws cis_3.0_aws aws_audit_manager_control_tower_guardrails_aws aws_well_architected_framework_reliability_pillar_aws soc2_aws mitre_attack_aws --output-modes html json --send-sh-only-fails --no-banner --ignore-exit-code-3"
}

variable "prowler_allowlist_file" {
  description = "(Required) Prowler allowlist file `https://docs.prowler.cloud/en/latest/tutorials/allowlist/`"
  default     = null
  type        = string
}

variable "prowler_config_file" {
  description = "(Required) Prowler configuration file `https://docs.prowler.cloud/en/latest/tutorials/configuration_file/`"
  default     = null
  type        = string
}

variable "enable_security_hub_subscription" {
  description = "(Required) Enable a Prowler Subscription."
  type        = bool
  default     = false
}

variable "codebuild_timeout" {
  description = "(Required) Number of minutes, from 5 to 480 (8 hours), for AWS CodeBuild to wait until timing out any related build that does not get marked as completed."
  default     = 300
  type        = number
}

variable "codebuild_compute_type" {
  description = "(Required) Information about the compute resources the build project will use."
  default     = "BUILD_GENERAL1_SMALL"
  type        = string
}

variable "codebuild_image" {
  description = "(Required) Docker image to use for this build project."
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:5.0"
  type        = string
}

variable "codebuild_buildspec" {
  description = "(Required) The build spec declaration to use for this build project's related builds."
  default     = <<EOF
version: 0.2
phases:
  install:
    runtime-versions:
      python: 3.12
    commands:
      - echo "Installing Prowler and dependencies..."
      - pip3 install detect-secrets==1.4.0 prowler==$PROWLER_VERSION --quiet
      - yum install -y jq --quiet
  build:
    commands:
      - echo "Running Prowler as prowler $PROWLER_OPTIONS"
      - aws s3 cp s3://$S3_BUCKET/files/allowlist.yaml .
      - aws s3 cp s3://$S3_BUCKET/files/config.yaml .
      - prowler --allowlist-file allowlist.yaml --config-file config.yaml $PROWLER_OPTIONS
  post_build:
    commands:
      - echo "Scan Complete"
      - aws s3 cp --no-progress --sse AES256 output/ s3://$S3_BUCKET/reports/`date +%d-%m-%Y`-`date +%H-%M-%S` --recursive
      - echo "Done!"
EOF
  type        = string
}

variable "create_codebuild_cloudwatch_alarm" {
  description = "(Required) Create CloudWatch Alarm to notify sns topic when build fail."
  type        = bool
  default     = true
}

variable "codebuild_notification_sns_topic_arn" {
  description = "(Optional) CloudWatch Event target ARN to Codebuild notifications."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to all resources"
  default     = {}
  type        = map(string)
}

variable "s3_bucket_name_prefix" {
  description = "(Optional) Bucket name prefix. Current account alias if used if none provied."
  default     = null
  type        = string
}

variable "s3_delete_objects_after" {
  description = "(Required) Retention period in days to store Prowler Reports."
  default     = 90
  type        = number
}

variable "create_cloudwatch_event_rule" {
  description = "(Required) Create CloudWatch Event Rule to automatically start pipeline when a change occurs."
  type        = bool
  default     = false
}

variable "create_cloudwatch_event_target" {
  description = "(Required) Create CloudWatch Event Target with API Destination."
  type        = bool
  default     = false
}

variable "cloudwatch_event_pattern" {
  description = "(Optional) Required if create_cloudwatch_event_rule = true. The event pattern described a JSON object."
  type        = string
  default     = <<EOF
{
  "source": ["aws.securityhub"],
  "detail": {
    "findings": {
      "ProductName": ["Prowler"],
      "Compliance": { "Status": ["FAILED"] },
      "Severity": { "Label": ["HIGH", "CRITICAL", "MEDIUM", "LOW"] },
      "RecordState": ["ACTIVE"]
    }
  }
}
EOF
}

variable "cloudwatch_event_role_policy" {
  description = "(Optional) IAM policy used by Cloudwatch Event Role."
  type        = string
  default     = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "events:InvokeApiDestination"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}

variable "cloudwatch_event_target_arn" {
  description = "(Optional) CloudWatch Event target ARN."
  type        = string
  default     = null
}

variable "cloudwatch_event_target_transformer" {
  description = "(Required) CloudWatch event target transformer rule."
  type        = any
  default = {
    input_paths = {
      "account"           = "$.account"
      "compliance-status" = "$.detail.findings[0].Compliance.Status"
      "created-at"        = "$.detail.findings[0].FirstObservedAt"
      "description"       = "$.detail.findings[0].Description"
      "id"                = "$.detail.findings[0].Id"
      "observed-at"       = "$.detail.findings[0].CreatedAt"
      "product-name"      = "$.detail.findings[0].ProductName"
      "region"            = "$.region"
      "resource-region"   = "$.detail.findings[0].Resources[0].Region"
      "resources"         = "$.detail.findings[0].Resources[0].Id"
      "severity"          = "$.detail.findings[0].FindingProviderFields.Severity.Label"
      "source"            = "$.source"
      "time"              = "$.time"
    }
    input_template = <<EOF
{
  "account": "<account>",
  "detail": {
    "compliance-status": "<compliance-status>",
    "created": "<created-at>",
    "link": "https://<region>.console.aws.amazon.com/securityhub/home?region=<region>#/findings?search=Id%3D%255Coperator%255C%253AEQUALS%255C%253A<id>",
    "observed": "<observed-at>",
    "product-name": "<product-name>",
    "severity": "<severity>"
  },
  "detail-type": "<description>",
  "id": "<id>",
  "region": "<resource-region>",
  "resources": ["<resources>"],
  "source": "SecurityHub",
  "time": "<time>"
}
EOF
  }
}
