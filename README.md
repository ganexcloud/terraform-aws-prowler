<!-- BEGIN_TF_DOCS -->

Terraform module that creates a collection of resources at AWS to run Prowler reports.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_metric_alarm.codebuild_failure_alarm](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_codebuild_project.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_iam_policy.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_object.allowlist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_s3_object.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_securityhub_product_subscription.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_product_subscription) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_account_alias.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_account_alias) | data source |
| [aws_iam_policy_document.codebuild_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.codebuild_trigger_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.notifications_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_event_pattern"></a> [cloudwatch\_event\_pattern](#input\_cloudwatch\_event\_pattern) | (Optional) Required if create\_cloudwatch\_event\_rule = true. The event pattern described a JSON object. | `string` | `"{\n  \"source\": [\"aws.securityhub\"],\n  \"detail\": {\n    \"findings\": {\n      \"ProductName\": [\"Prowler\"],\n      \"Compliance\": { \"Status\": [\"FAILED\"] },\n      \"Severity\": { \"Label\": [\"HIGH\", \"CRITICAL\", \"MEDIUM\", \"LOW\"] },\n      \"RecordState\": [\"ACTIVE\"]\n    }\n  }\n}\n"` | no |
| <a name="input_cloudwatch_event_role_policy"></a> [cloudwatch\_event\_role\_policy](#input\_cloudwatch\_event\_role\_policy) | (Optional) IAM policy used by Cloudwatch Event Role. | `string` | `"{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Action\": [\n        \"events:InvokeApiDestination\"\n      ],\n      \"Resource\": \"*\"\n    }\n  ]\n}\n"` | no |
| <a name="input_cloudwatch_event_target_arn"></a> [cloudwatch\_event\_target\_arn](#input\_cloudwatch\_event\_target\_arn) | (Optional) CloudWatch Event target ARN. | `string` | `null` | no |
| <a name="input_cloudwatch_event_target_transformer"></a> [cloudwatch\_event\_target\_transformer](#input\_cloudwatch\_event\_target\_transformer) | (Required) CloudWatch event target transformer rule. | `any` | <pre>{<br/>  "input_paths": {<br/>    "account": "$.account",<br/>    "compliance-status": "$.detail.findings[0].Compliance.Status",<br/>    "created-at": "$.detail.findings[0].FirstObservedAt",<br/>    "description": "$.detail.findings[0].Description",<br/>    "id": "$.detail.findings[0].Id",<br/>    "observed-at": "$.detail.findings[0].CreatedAt",<br/>    "product-name": "$.detail.findings[0].ProductName",<br/>    "region": "$.region",<br/>    "resource-region": "$.detail.findings[0].Resources[0].Region",<br/>    "resources": "$.detail.findings[0].Resources[0].Id",<br/>    "severity": "$.detail.findings[0].FindingProviderFields.Severity.Label",<br/>    "source": "$.source",<br/>    "time": "$.time"<br/>  },<br/>  "input_template": "{\n  \"account\": \"<account>\",\n  \"detail\": {\n    \"compliance-status\": \"<compliance-status>\",\n    \"created\": \"<created-at>\",\n    \"link\": \"https://<region>.console.aws.amazon.com/securityhub/home?region=<region>#/findings?search=Id%3D%255Coperator%255C%253AEQUALS%255C%253A<id>\",\n    \"observed\": \"<observed-at>\",\n    \"product-name\": \"<product-name>\",\n    \"severity\": \"<severity>\"\n  },\n  \"detail-type\": \"<description>\",\n  \"id\": \"<id>\",\n  \"region\": \"<resource-region>\",\n  \"resources\": [\"<resources>\"],\n  \"source\": \"SecurityHub\",\n  \"time\": \"<time>\"\n}\n"<br/>}</pre> | no |
| <a name="input_codebuild_buildspec"></a> [codebuild\_buildspec](#input\_codebuild\_buildspec) | (Required) The build spec declaration to use for this build project's related builds. | `string` | `"version: 0.2\nphases:\n  install:\n    runtime-versions:\n      python: 3.12\n    commands:\n      - echo \"Installing Prowler and dependencies...\"\n      - pip3 install detect-secrets==1.4.0 prowler==$PROWLER_VERSION --quiet\n      - yum install -y jq --quiet\n  build:\n    commands:\n      - echo \"Running Prowler as prowler $PROWLER_OPTIONS\"\n      - aws s3 cp s3://$S3_BUCKET/files/allowlist.yaml .\n      - aws s3 cp s3://$S3_BUCKET/files/config.yaml .\n      - prowler --allowlist-file allowlist.yaml --config-file config.yaml $PROWLER_OPTIONS\n  post_build:\n    commands:\n      - echo \"Scan Complete\"\n      - aws s3 cp --no-progress --sse AES256 output/ s3://$S3_BUCKET/reports/`date +%d-%m-%Y`-`date +%H-%M-%S` --recursive\n      - echo \"Done!\"\n"` | no |
| <a name="input_codebuild_compute_type"></a> [codebuild\_compute\_type](#input\_codebuild\_compute\_type) | (Required) Information about the compute resources the build project will use. | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| <a name="input_codebuild_image"></a> [codebuild\_image](#input\_codebuild\_image) | (Required) Docker image to use for this build project. | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:5.0"` | no |
| <a name="input_codebuild_notification_sns_topic_arn"></a> [codebuild\_notification\_sns\_topic\_arn](#input\_codebuild\_notification\_sns\_topic\_arn) | (Optional) CloudWatch Event target ARN to Codebuild notifications. | `list(string)` | `[]` | no |
| <a name="input_codebuild_timeout"></a> [codebuild\_timeout](#input\_codebuild\_timeout) | (Required) Number of minutes, from 5 to 480 (8 hours), for AWS CodeBuild to wait until timing out any related build that does not get marked as completed. | `number` | `300` | no |
| <a name="input_create_cloudwatch_event_rule"></a> [create\_cloudwatch\_event\_rule](#input\_create\_cloudwatch\_event\_rule) | (Required) Create CloudWatch Event Rule to automatically start pipeline when a change occurs. | `bool` | `false` | no |
| <a name="input_create_cloudwatch_event_target"></a> [create\_cloudwatch\_event\_target](#input\_create\_cloudwatch\_event\_target) | (Required) Create CloudWatch Event Target with API Destination. | `bool` | `false` | no |
| <a name="input_create_codebuild_cloudwatch_alarm"></a> [create\_codebuild\_cloudwatch\_alarm](#input\_create\_codebuild\_cloudwatch\_alarm) | (Required) Create CloudWatch Alarm to notify sns topic when build fail. | `bool` | `true` | no |
| <a name="input_enable_security_hub_subscription"></a> [enable\_security\_hub\_subscription](#input\_enable\_security\_hub\_subscription) | (Required) Enable a Prowler Subscription. | `bool` | `false` | no |
| <a name="input_prowler_allowlist_file"></a> [prowler\_allowlist\_file](#input\_prowler\_allowlist\_file) | (Required) Prowler allowlist file `https://docs.prowler.cloud/en/latest/tutorials/allowlist/` | `string` | `null` | no |
| <a name="input_prowler_cli_options"></a> [prowler\_cli\_options](#input\_prowler\_cli\_options) | (Required) Run Prowler With The Following Command | `string` | `"-S --compliance aws_foundational_security_best_practices_aws aws_well_architected_framework_security_pillar_aws cis_3.0_aws aws_audit_manager_control_tower_guardrails_aws aws_well_architected_framework_reliability_pillar_aws soc2_aws mitre_attack_aws --output-modes html json --send-sh-only-fails --no-banner --ignore-exit-code-3"` | no |
| <a name="input_prowler_config_file"></a> [prowler\_config\_file](#input\_prowler\_config\_file) | (Required) Prowler configuration file `https://docs.prowler.cloud/en/latest/tutorials/configuration_file/` | `string` | `null` | no |
| <a name="input_prowler_schedule"></a> [prowler\_schedule](#input\_prowler\_schedule) | (Required) Prowler based on cron schedule | `string` | `"cron(0 12 ? * * *)"` | no |
| <a name="input_prowler_version"></a> [prowler\_version](#input\_prowler\_version) | (Required) Prowler version | `string` | `"3.15.0"` | no |
| <a name="input_s3_bucket_name_prefix"></a> [s3\_bucket\_name\_prefix](#input\_s3\_bucket\_name\_prefix) | (Optional) Bucket name prefix. Current account alias if used if none provied. | `string` | `null` | no |
| <a name="input_s3_delete_objects_after"></a> [s3\_delete\_objects\_after](#input\_s3\_delete\_objects\_after) | (Required) Retention period in days to store Prowler Reports. | `number` | `90` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to all resources | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->