#!/bin/bash
## this is the config loaded into aws accounts and cfn installed
## Ensure aws/iam.cfn.yml is in the same folder as this script

# Function to set or update a parameter in AWS Parameter Store
set_parameter() {
    local PARAM_NAME=$1
    local PARAM_VALUE=$2
    local IS_SECRET=${3:-false}  # Default false, set to true for secret (encrypted) parameters

    # Determine the parameter type
    if [ "$IS_SECRET" = true ]; then
        PARAM_TYPE="SecureString"
    else
        PARAM_TYPE="String"
    fi

    # Create or update the parameter
    echo "Setting parameter $PARAM_NAME..."
    aws ssm put-parameter --name "$PARAM_NAME" --value "$PARAM_VALUE" --type "$PARAM_TYPE" --overwrite

}

deploy_stack() {
  local ENV=$1
  local STACK_NAME="site-myqldgovau-$ENV"
  local S3_BUCKET_NAME="/config/site-myqldgovau/$ENV/S3BucketName"
  local S3_BUCKET_PATH="/config/site-myqldgovau/$ENV/S3BucketPath"

  aws cloudformation deploy \
    --template-file iam.cfn.yml \
    --stack-name $STACK_NAME \
    --capabilities CAPABILITY_IAM \
    --parameter-overrides \
      Environment=$ENV \
      GitHubOIDCProviderARN=/config/GitHubOIDCProviderARN \
      GitHubOrg=qld-gov-au \
      RepoName=site-myqldgovau \
      S3BucketName=$S3_BUCKET_NAME \
      S3BucketPath=$S3_BUCKET_PATH
}

ENVIRONMENT=$1

if [ "DEV" == "$ENVIRONMENT"]; then
set_parameter "/config/site-myqldgovau/DEV/GtmId" "xxxx"
set_parameter "/config/site-myqldgovau/DEV/S3BucketName" "xxxx"
set_parameter "/config/site-myqldgovau/DEV/Public_TLD" "xxxx"
set_parameter "/config/site-myqldgovau/DEV/PublicStackZoneTLD" "xxxx"
set_parameter "/config/GitHubOIDCProviderARN" "arn:aws:iam::xxxx:oidc-provider/token.actions.githubusercontent.com"
deploy_stack DEV
elif [ "TEST" == "$ENVIRONMENT"]; then
set_parameter "/config/site-myqldgovau/TEST/GtmId" "xxxx"
set_parameter "/config/site-myqldgovau/TEST/S3BucketName" "xxx"
set_parameter "/config/site-myqldgovau/TEST/Public_TLD" "xxx"
set_parameter "/config/site-myqldgovau/TEST/PublicStackZoneTLD" "xxxx"
set_parameter "/config/GitHubOIDCProviderARN" "arn:aws:iam::xxxx:oidc-provider/token.actions.githubusercontent.com"
deploy_stack TEST
elif [ "STAGING" == "$ENVIRONMENT"]; then
set_parameter "/config/site-myqldgovau/STAGING/GtmId" "xxxx"
set_parameter "/config/site-myqldgovau/STAGING/S3BucketName" "xxx"
set_parameter "/config/site-myqldgovau/STAGING/Public_TLD" "xxx"
set_parameter "/config/site-myqldgovau/STAGING/PublicStackZoneTLD" "xxx"
set_parameter "/config/GitHubOIDCProviderARN" "arn:aws:iam::xxx:oidc-provider/token.actions.githubusercontent.com"
deploy_stack STAGING
elif [ "PROD" == "$ENVIRONMENT"]; then
set_parameter "/config/site-myqldgovau/PROD/GtmId" "xxx"
set_parameter "/config/site-myqldgovau/PROD/S3BucketName" "xxxx"
set_parameter "/config/site-myqldgovau/PROD/Public_TLD" "xxx"
set_parameter "/config/site-myqldgovau/PROD/PublicStackZoneTLD" "xxx"
set_parameter "/config/GitHubOIDCProviderARN" "arn:aws:iam::xxx:oidc-provider/token.actions.githubusercontent.com"
deploy_stack PROD
fi
