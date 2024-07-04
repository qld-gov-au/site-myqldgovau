## AWS Environment connectivity for cdn deployment.

This iam config is required to allow github Actions to deploy to
aws for an environment release.

```shell
aws iam create-open-id-connect-provider \
    --url https://token.actions.githubusercontent.com \
    --client-id-list sts.amazonaws.com \
    --thumbprint-list 1b511abead59c6ce207077c0bf0e0043b1382612
```

```shell
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

# Example usage:

set_parameter "/config/site-myqldgovau/PROD/S3BucketName" "mybucket123"
set_parameter "/config/site-myqldgovau/PROD/Public_TLD" "publicTLdomain"
set_parameter "/config/site-myqldgovau/PROD/PublicStackZoneTLD" "r53zoneDomain"

deploy_stack DEV
deploy_stack TEST
deploy_stack STAGING
deploy_stack PROD
```


## GitHub Environments
 1. Setup one or more enviroments DEV|TEST|etc
 2. Add secrets: AWS_IAM_ROLE and S3BUCKET (i.e. s3://myBucket/folderPrefix) based on what is set in your aws param store configuration
 3. Add branch/tag restrictions
 4. deploy via github action script cdnAWSDeployment.yml

### Script to create environments

Prerequisites
Ensure you have the GitHub CLI (gh) installed.
https://cli.github.com/
i.e. for mac  ``brew install gh``

Authenticate gh to your GitHub account by running 
``gh auth login`` and following the prompts.

```shell
./setup_github_environment.sh qld-gov-au site-myqldgovau DEV "s3://your-s3-bucket-nam/folder" arn:aws:iam::00011122211:role/cfnCreatedRoleHere

```