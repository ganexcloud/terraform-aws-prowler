resource "aws_iam_role" "this" {
  name                  = "Prowler"
  managed_policy_arns   = [aws_iam_policy.codebuild.arn, "arn:aws:iam::aws:policy/SecurityAudit", "arn:aws:iam::aws:policy/job-function/ViewOnlyAccess"]
  force_detach_policies = true
  assume_role_policy    = data.aws_iam_policy_document.codebuild_assume_role_policy.json
}

resource "aws_iam_role" "trigger" {
  name                = "Prowler-trigger"
  managed_policy_arns = [aws_iam_policy.this.arn]
  assume_role_policy  = data.aws_iam_policy_document.codebuild_trigger_assume_role_policy.json
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
          "Action" : [
            "account:Get*",
            "appstream:Describe*",
            "appstream:List*",
            "backup:List*",
            "cloudtrail:GetInsightSelectors",
            "codeartifact:List*",
            "codebuild:BatchGet*",
            "dlm:Get*",
            "drs:Describe*",
            "ds:Get*",
            "ds:Describe*",
            "ds:List*",
            "ec2:GetEbsEncryptionByDefault",
            "ecr:Describe*",
            "ecr:GetRegistryScanningConfiguration",
            "elasticfilesystem:DescribeBackupPolicy",
            "glue:GetConnections",
            "glue:GetSecurityConfiguration*",
            "glue:SearchTables",
            "lambda:GetFunction*",
            "logs:FilterLogEvents",
            "macie2:GetMacieSession",
            "s3:GetAccountPublicAccessBlock",
            "shield:DescribeProtection",
            "shield:GetSubscriptionState",
            "securityhub:BatchImportFindings",
            "securityhub:GetFindings",
            "ssm:GetDocument",
            "ssm-incidents:List*",
            "support:Describe*",
            "tag:GetTagKeys",
            "wellarchitected:List*"
          ],
          "Resource" : "*",
          "Effect" : "Allow",
          "Sid" : "AllowMoreReadForProwler"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "apigateway:GET"
          ],
          "Resource" : [
            "arn:aws:apigateway:*::/restapis/*",
            "arn:aws:apigateway:*::/apis/*"
          ]
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
          "Action" : ["s3:GetObject"],
          "Resource" : "${aws_s3_bucket.this.arn}/files/*",
          "Effect" : "Allow"
        },
        {
          "Action" : ["s3:PutObject", "s3:GetObject", "s3:GetObjectVersion", "s3:GetBucketAcl", "s3:GetBucketLocation"],
          "Resource" : "${aws_s3_bucket.this.arn}/reports/*",
          "Effect" : "Allow"
        }
      ]
    }
  )
}
