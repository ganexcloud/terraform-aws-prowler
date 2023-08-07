<!-- BEGIN_TF_DOCS -->

Terraform module that creates a collection of resources at AWS to run Prowler reports.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.1 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.5.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.5.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_cloudwatch_event_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_codebuild_project.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codebuild_project) | resource |
| [aws_iam_policy.codebuild](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.trigger](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_ownership_controls.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_securityhub_product_subscription.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/securityhub_product_subscription) | resource |
| [aws_ssm_parameter.prowler_allowlist](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [random_string.this](https://registry.terraform.io/providers/hashicorp/random/3.5.1/docs/resources/string) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudwatch_event_pattern"></a> [cloudwatch\_event\_pattern](#input\_cloudwatch\_event\_pattern) | (Optional) Required if create\_cloudwatch\_event\_rule = true. The event pattern described a JSON object. | `string` | `"{\n  \"source\": [\"aws.securityhub\"],\n  \"detail\": {\n    \"findings\": {\n      \"ProductName\": [\"Prowler\"],\n      \"Compliance\": { \"Status\": [\"FAILED\"] },\n      \"Severity\": { \"Label\": [\"HIGH\", \"CRITICAL\"] },\n      \"RecordState\": [\"ACTIVE\"]\n    }\n  }\n}\n"` | no |
| <a name="input_cloudwatch_event_role_policy"></a> [cloudwatch\_event\_role\_policy](#input\_cloudwatch\_event\_role\_policy) | (Optional) IAM policy used by Cloudwatch Event Role. | `string` | `"{\n  \"Version\": \"2012-10-17\",\n  \"Statement\": [\n    {\n      \"Effect\": \"Allow\",\n      \"Action\": [\n        \"events:InvokeApiDestination\"\n      ],\n      \"Resource\": \"*\"\n      ]\n    }\n  ]\n}\n"` | no |
| <a name="input_cloudwatch_event_target_arn"></a> [cloudwatch\_event\_target\_arn](#input\_cloudwatch\_event\_target\_arn) | (Optional) CloudWatch Event target ARN. | `string` | `null` | no |
| <a name="input_cloudwatch_event_target_transformer"></a> [cloudwatch\_event\_target\_transformer](#input\_cloudwatch\_event\_target\_transformer) | (Required) CloudWatch event target transformer rule. | `any` | <pre>{<br>  "input_paths": {<br>    "account": "$.account",<br>    "compliance-status": "$.detail.findings[0].Compliance.Status",<br>    "created-at": "$.detail.findings[0].FirstObservedAt",<br>    "description": "$.detail.findings[0].Description",<br>    "id": "$.detail.findings[0].Id",<br>    "observed-at": "$.detail.findings[0].CreatedAt",<br>    "product-name": "$.detail.findings[0].ProductName",<br>    "region": "$.region",<br>    "resources": "$.detail.findings[0].Resources[0].Id",<br>    "severity": "$.detail.findings[0].FindingProviderFields.Severity.Label",<br>    "source": "$.source",<br>    "time": "$.time"<br>  },<br>  "input_template": "{\n  \"account\": \"<account>\",\n  \"detail\": {\n    \"compliance-status\": \"<compliance-status>\",\n    \"created\": \"<created-at>\",\n    \"link\": \"https://us-east-1.console.aws.amazon.com/securityhub/home?region=<region>#/findings?search=Id%3D%255Coperator%255C%253AEQUALS%255C%253A<id>\",\n    \"observed\": \"<observed-at>\",\n    \"product-name\": \"<product-name>\",\n    \"severity\": \"<severity>\"\n  },\n  \"detail-type\": \"<description>\",\n  \"id\": \"<id>\",\n  \"region\": \"<region>\",\n  \"resources\": [\"<resources>\"],\n  \"source\": \"SecurityHub\",\n  \"time\": \"<time>\"\n}\n"<br>}</pre> | no |
| <a name="input_codebuild_buildspec"></a> [codebuild\_buildspec](#input\_codebuild\_buildspec) | (Required) The build spec declaration to use for this build project's related builds. | `string` | `"version: 0.2\nphases:\n  install:\n    runtime-versions:\n      python: 3.9\n    commands:\n      - echo \"Installing Prowler and dependencies...\"\n      - pip3 install detect-secrets==1.4.0 prowler==$PROWLER_VERSION --quiet\n      - yum install -y jq --quiet\n  build:\n    commands:\n      - echo \"Running Prowler as prowler $PROWLER_OPTIONS\"\n      - aws --region us-east-1 ssm get-parameter --name /prowler/allowlist --with-decryption --output text --query Parameter.Value > allowlist.yaml\n      - prowler -w allowlist.yaml $PROWLER_OPTIONS\n  post_build:\n    commands:\n      - echo \"Scan Complete\"\n      - aws s3 cp --no-progress --sse AES256 output/ s3://$BUCKET_REPORT/`date +%d-%m-%Y`-`date +%H-%M-%S` --recursive\n      - echo \"Done!\"\n"` | no |
| <a name="input_codebuild_compute_type"></a> [codebuild\_compute\_type](#input\_codebuild\_compute\_type) | (Required) Information about the compute resources the build project will use. | `string` | `"BUILD_GENERAL1_SMALL"` | no |
| <a name="input_codebuild_image"></a> [codebuild\_image](#input\_codebuild\_image) | (Required) Docker image to use for this build project. | `string` | `"aws/codebuild/amazonlinux2-x86_64-standard:4.0"` | no |
| <a name="input_codebuild_timeout"></a> [codebuild\_timeout](#input\_codebuild\_timeout) | (Required) Number of minutes, from 5 to 480 (8 hours), for AWS CodeBuild to wait until timing out any related build that does not get marked as completed. | `number` | `300` | no |
| <a name="input_create_cloudwatch_event_rule"></a> [create\_cloudwatch\_event\_rule](#input\_create\_cloudwatch\_event\_rule) | (Required) Create CloudWatch Event Rule to automatically start pipeline when a change occurs. | `bool` | `false` | no |
| <a name="input_create_cloudwatch_event_target"></a> [create\_cloudwatch\_event\_target](#input\_create\_cloudwatch\_event\_target) | (Required) Create CloudWatch Event Target with API Destination. | `bool` | `false` | no |
| <a name="input_enable_security_hub_subscription"></a> [enable\_security\_hub\_subscription](#input\_enable\_security\_hub\_subscription) | (Required) Enable a Prowler Subscription. | `bool` | `true` | no |
| <a name="input_prowler_allowlist"></a> [prowler\_allowlist](#input\_prowler\_allowlist) | (Required) Prowler allowlist `https://docs.prowler.cloud/en/latest/tutorials/allowlist/` | `string` | `null` | no |
| <a name="input_prowler_cli_options"></a> [prowler\_cli\_options](#input\_prowler\_cli\_options) | (Required) Run Prowler With The Following Command | `string` | `"-S -f us-east-1 --compliance aws_foundational_security_best_practices_aws cis_1.5_aws --output-modes html json --quiet --no-banner --ignore-exit-code-3"` | no |
| <a name="input_prowler_schedule"></a> [prowler\_schedule](#input\_prowler\_schedule) | (Required) Prowler based on cron schedule | `string` | `"cron(0 0 ? * * *)"` | no |
| <a name="input_prowler_version"></a> [prowler\_version](#input\_prowler\_version) | (Required) Prowler version | `string` | `"3.8.0"` | no |
| <a name="input_s3_delete_objects_after"></a> [s3\_delete\_objects\_after](#input\_s3\_delete\_objects\_after) | (Required) Retention period in days to store Prowler reports | `number` | `30` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to all resources | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->