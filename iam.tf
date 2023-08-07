resource "aws_iam_role" "this" {
  name                  = "Prowler"
  managed_policy_arns   = [aws_iam_policy.codebuild.arn, "arn:aws:iam::aws:policy/SecurityAudit", "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"]
  force_detach_policies = true
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action    = "sts:AssumeRole"
          Effect    = "Allow"
          Sid       = "CodeBuildProwler"
          Principal = { Service = "codebuild.amazonaws.com" }
        }
      ]
    }
  )
}

resource "aws_iam_role" "trigger" {
  name                = "Prowler-trigger"
  managed_policy_arns = [aws_iam_policy.this.arn]
  assume_role_policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action    = "sts:AssumeRole"
          Effect    = "Allow"
          Sid       = "TriggerCodeBuild"
          Principal = { Service = "events.amazonaws.com" }
        }
      ]
    }
  )
}

resource "aws_iam_policy" "this" {
  name        = "Prowler"
  path        = "/"
  description = "IAM Policy used to trigger the Prowler in AWS Codebuild"
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action   = ["codebuild:StartBuild"],
          Effect   = "Allow"
          Resource = "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:project/Prowler"
        }
      ]
    }
  )
}

resource "aws_iam_policy" "codebuild" {
  name        = "Prowler-Codebuild"
  path        = "/"
  description = "IAM Policy used to run prowler from codebuild"

  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "logs:PutLogEvents"
          ],
          Effect   = "Allow"
          Resource = "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:*:log-stream:*"
        },
        {
          Action = [
            "logs:CreateLogStream",
            "logs:CreateLogGroup"
          ],
          Effect   = "Allow"
          Resource = "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:log-group:*"
        },
        {
          Action   = ["sts:AssumeRole"],
          Effect   = "Allow"
          Resource = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/Prowler"
        },
        {
          Action = [
            "account:Get*",
            "appstream:Describe*",
            "appstream:List*",
            "codeartifact:List*",
            "codebuild:BatchGet*",
            "ds:Describe*",
            "ds:Get*",
            "ds:List*",
            "ec2:GetEbsEncryptionByDefault",
            "ecr:Describe*",
            "elasticfilesystem:DescribeBackupPolicy",
            "glue:GetConnections",
            "glue:GetSecurityConfiguration*",
            "glue:SearchTables",
            "lambda:GetFunction*",
            "macie2:GetMacieSession",
            "s3:GetAccountPublicAccessBlock",
            "shield:DescribeProtection",
            "shield:GetSubscriptionState",
            "ssm:GetDocument",
            "support:Describe*",
            "tag:GetTagKeys",
            "organizations:DescribeOrganization",
            "organizations:ListPolicies*",
            "organizations:DescribePolicy"
          ]
          Effect   = "Allow"
          Resource = "*"

        },
        {
          Action = [
            "codebuild:CreateReportGroup",
            "codebuild:CreateReport",
            "codebuild:UpdateReport",
            "codebuild:BatchPutTestCases",
            "codebuild:BatchPutCodeCoverages"
          ]
          Effect   = "Allow"
          Resource = "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:report-group/*"

        },
        {
          Action   = ["securityhub:BatchImportFindings", "securityhub:GetFindings"]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Action   = ["apigateway:GET"]
          Effect   = "Allow"
          Resource = "arn:aws:apigateway:*::/restapis/*"
        },
        {
          "Action" : "codebuild:StartBuild",
          "Resource" : "arn:aws:codebuild:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:project/*",
          "Effect" : "Allow"
        },
        {
          "Action" : ["s3:PutObject", "s3:GetObject", "s3:GetObjectVersion", "s3:GetBucketAcl", "s3:GetBucketLocation"],
          "Resource" : "arn:aws:s3:::prowler-reports-${random_string.this.result}/*",
          "Effect" : "Allow"
        },
        {
          Action   = ["ssm:GetParameter"],
          Effect   = "Allow"
          Resource = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/prowler/*"
        }
      ]
    }
  )
}
