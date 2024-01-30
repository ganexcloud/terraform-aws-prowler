provider "aws" {
  region = "us-east-1"
}

module "eventbridge" {
  source                     = "terraform-aws-modules/eventbridge/aws"
  version                    = "1.17.3"
  create_bus                 = false
  create_role                = false
  create_connections         = true
  create_api_destinations    = true
  append_connection_postfix  = false
  append_destination_postfix = false
  connections = {
    squadcast = {
      authorization_type = "API_KEY"
      auth_parameters = {
        api_key = {
          key   = "Squadcast"
          value = "true"
        }
      }
    }
  }
  api_destinations = {
    squadcast = {
      invocation_endpoint              = "https://api.squadcast.com/v1/incidents/amazon-eventbridge/xxxxxx"
      http_method                      = "POST"
      invocation_rate_limit_per_second = 200
    }
  }
}

module "prowler" {
  source                           = "../../"
  enable_security_hub_subscription = true
  prowler_schedule                 = "cron(0 12 ? * * *)"
  codebuild_timeout                = 300
  create_cloudwatch_event_rule     = true
  create_cloudwatch_event_target   = true
  cloudwatch_event_target_arn      = lookup(module.eventbridge.eventbridge_api_destination_arns, "squadcast")
}
