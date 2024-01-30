resource "aws_codebuild_project" "this" {
  name          = "Prowler"
  description   = "Run a Prowler Assessment with Prowler"
  build_timeout = var.codebuild_timeout
  service_role  = aws_iam_role.this.arn
  tags          = var.tags

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = var.codebuild_compute_type
    image        = var.codebuild_image
    type         = "LINUX_CONTAINER"

    environment_variable {
      name  = "S3_BUCKET"
      value = aws_s3_bucket.this.id
    }

    environment_variable {
      name  = "PROWLER_VERSION"
      type  = "PLAINTEXT"
      value = var.prowler_version
    }

    environment_variable {
      name  = "PROWLER_OPTIONS"
      type  = "PLAINTEXT"
      value = var.prowler_cli_options
    }

  }

  source {
    type      = "NO_SOURCE"
    buildspec = var.codebuild_buildspec
  }
}
