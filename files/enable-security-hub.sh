#!/bin/bash
region=$1
subscription_name=$2
role_arn=$3

# Assume role
if [ ! -z "$role_arn" ]; then
  OUTPUT=`aws sts assume-role --role-arn "${role_arn}"`
  if [ $? -gt 0 ]; then
    echo
    echo "Error assuming role \"${role_arn}\""
  else
    export AWS_ACCESS_KEY_ID=`echo $OUTPUT | jq -r .Credentials.AccessKeyId`
    export AWS_SECRET_ACCESS_KEY=`echo $OUTPUT | jq -r .Credentials.SecretAccessKey`
    export AWS_SESSION_TOKEN=`echo $OUTPUT | jq -r .Credentials.SessionToken`
  fi
fi

# Check if Security Hub is enabled in the specified region
hub_result=$(aws securityhub describe-hub --region $region 2>&1)
if [[ $hub_result == *"HubArn"* ]]; then
  echo "Security Hub is enabled in the region $region."
else
  echo "Security Hub is not enabled in the region $region. Enabling..."
  aws securityhub enable-security-hub --region $region --no-enable-default-standards
fi

# Check if the specified subscription is active in the region
subscription_result=$(aws --region $region securityhub describe-products --product-arn "arn:aws:securityhub:$region::product/$subscription_name" 2>&1)
if [[ $subscription_result == *"SubscriptionNotFound"* ]]; then
  echo "The Security Hub subscription is not active in the region $region. Adding..."
  aws --region $region securityhub enable-import-findings-for-product --product-arn "arn:aws:securityhub:$region::product/$subscription_name"
else
  echo "The Security Hub subscription is active in the region $region."
fi
