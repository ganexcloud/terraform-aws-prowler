variable "prowler_version" {
  description = "(Required) Prowler version"
  type        = string
  default     = "3.8.0"
}

variable "prowler_schedule" {
  description = "(Required) Prowler based on cron schedule"
  default     = "cron(0 0 ? * * *)"
  type        = string
}

variable "prowler_cli_options" {
  description = "(Required) Run Prowler With The Following Command"
  type        = string
  default     = "-S -f us-east-1 --compliance aws_foundational_security_best_practices_aws cis_1.5_aws --output-modes html json --quiet --no-banner --ignore-exit-code-3"
}

variable "prowler_allowlist" {
  description = "(Required) Prowler allowlist `https://docs.prowler.cloud/en/latest/tutorials/allowlist/`"
  default     = null
  type        = string
}

variable "enable_security_hub_subscription" {
  description = "(Required) Enable a Prowler Subscription."
  type        = bool
  default     = true
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
  default     = "aws/codebuild/amazonlinux2-x86_64-standard:4.0"
  type        = string
}

variable "codebuild_buildspec" {
  description = "(Required) The build spec declaration to use for this build project's related builds."
  default     = <<EOF
version: 0.2
phases:
  install:
    runtime-versions:
      python: 3.9
    commands:
      - echo "Installing Prowler and dependencies..."
      - pip3 install detect-secrets==1.4.0 prowler==$PROWLER_VERSION --quiet
      - yum install -y jq --quiet
  build:
    commands:
      - echo "Running Prowler as prowler $PROWLER_OPTIONS"
      - aws --region us-east-1 ssm get-parameter --name /prowler/allowlist --with-decryption --output text --query Parameter.Value > allowlist.yaml
      - prowler -w allowlist.yaml $PROWLER_OPTIONS
  post_build:
    commands:
      - echo "Scan Complete"
      - aws s3 cp --no-progress --sse AES256 output/ s3://$BUCKET_REPORT/`date +%d-%m-%Y`-`date +%H-%M-%S` --recursive
      - echo "Done!"
EOF
  type        = string
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to all resources"
  default     = {}
  type        = map(string)
}

variable "s3_delete_objects_after" {
  description = "(Required) Retention period in days to store Prowler reports"
  default     = 30
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
      "Severity": { "Label": ["HIGH", "CRITICAL"] },
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
    "link": "https://us-east-1.console.aws.amazon.com/securityhub/home?region=<region>#/findings?search=Id%3D%255Coperator%255C%253AEQUALS%255C%253A<id>",
    "observed": "<observed-at>",
    "product-name": "<product-name>",
    "severity": "<severity>"
  },
  "detail-type": "<description>",
  "id": "<id>",
  "region": "<region>",
  "resources": ["<resources>"],
  "source": "SecurityHub",
  "time": "<time>"
}
EOF
  }
}
