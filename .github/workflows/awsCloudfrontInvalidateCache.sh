#!/bin/bash

# Check if domain name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <domain-name>"
  exit 1
fi

DOMAIN_NAME=$1

# Find the CloudFront Distribution ID for the given domain name in Aliases
DISTRIBUTION_ID=$(aws cloudfront list-distributions \
  --query "DistributionList.Items[?contains(Aliases.Items, '$DOMAIN_NAME')].Id | [0]" \
  --output text)

# Check if a distribution ID was found
if [ "$DISTRIBUTION_ID" == "None" ]; then
  echo "No CloudFront distribution found for domain: $DOMAIN_NAME"
  exit 1
fi

# Create a cache invalidation for all paths
INVALIDATION_ID=$(aws cloudfront create-invalidation \
  --distribution-id "$DISTRIBUTION_ID" \
  --paths "/*" \
  --query "Invalidation.Id" \
  --output text)

# Check if invalidation was successful
if [ "$INVALIDATION_ID" == "None" ]; then
  echo "Failed to create cache invalidation for domain: $DOMAIN_NAME"
  exit 1
fi

echo "Cache invalidation successfully created for domain: $DOMAIN_NAME"

exit 0