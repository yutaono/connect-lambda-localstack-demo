#!/bin/bash

set -euo pipefail

# Disable AWS CLI output pager for all commands in this script.
export AWS_PAGER=""

ROLE_NAME="lambda-execution-role"
ENDPOINT="${ENDPOINT:-http://localhost:4566}"
FUNCTION_NAME="${FUNCTION_NAME:-demo-function}"
REGION="${REGION:-ap-northeast-1}"

# Create IAM role for Lambda
aws iam create-role \
  --endpoint-url="$ENDPOINT" \
  --role-name "$ROLE_NAME" \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [{
      "Effect": "Allow",
      "Principal": { "Service": "lambda.amazonaws.com" },
      "Action": "sts:AssumeRole"
    }]
  }'

# Deploy Lambda function
aws lambda create-function \
  --endpoint-url="$ENDPOINT" \
  --function-name "$FUNCTION_NAME" \
  --runtime "provided.al2023" \
  --handler "bootstrap" \
  --role "arn:aws:iam::000000000000:role/$ROLE_NAME" \
  --zip-file "fileb://function.zip"

# Create API Gateway
API_ID=$(aws apigateway create-rest-api \
  --endpoint-url="$ENDPOINT" \
  --name "DemoAPI" \
  --query 'id' \
  --output text)

# Get root resource ID
ROOT_RESOURCE_ID=$(aws apigateway get-resources \
  --endpoint-url="$ENDPOINT" \
  --rest-api-id "$API_ID" \
  --query 'items[0].id' \
  --output text)

# Get proxy resource ID
PROXY_RESOURCE_ID=$(aws apigateway create-resource \
  --endpoint-url="$ENDPOINT" \
  --rest-api-id "$API_ID" \
  --parent-id "$ROOT_RESOURCE_ID" \
  --path-part "{proxy+}" \
  --query 'id' \
  --output text)

# Create ANY method for the proxy resource
aws apigateway put-method \
  --endpoint-url="$ENDPOINT" \
  --rest-api-id "$API_ID" \
  --resource-id "$PROXY_RESOURCE_ID" \
  --http-method ANY \
  --authorization-type NONE

# Set up Lambda integration
aws apigateway put-integration \
  --endpoint-url="$ENDPOINT" \
  --rest-api-id "$API_ID" \
  --resource-id "$PROXY_RESOURCE_ID" \
  --http-method ANY \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri "arn:aws:apigateway:$REGION:lambda:path/2015-03-31/functions/arn:aws:lambda:$REGION:000000000000:function:$FUNCTION_NAME/invocations"

# Deploy the API to a stage
aws apigateway create-deployment \
  --endpoint-url="$ENDPOINT" \
  --rest-api-id "$API_ID" \
  --stage-name "dev"

# Output the API ID
echo "API_ID=$API_ID"
