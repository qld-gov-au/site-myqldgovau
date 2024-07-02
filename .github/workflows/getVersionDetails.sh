#!/bin/bash

REF="${GITHUB_BASE_REF:-${GITHUB_REF}}"
TAG_VALUE=${GITHUB_REF/refs\/tags\//}

#If on a tag, use the tagged version as source of truth.
if [[ "$GITHUB_REF" == "${GITHUB_REF/refs\/tags\//}"  ]]; then
  echo "Is not a tag"
  version=v$(node -pe 'require("./package.json").version')
  echo "version=${version}" >> $GITHUB_ENV
else
#Second best case := package version.
  version=${TAG_VALUE}
  echo "version=${version}" >> $GITHUB_ENV
fi

# Input environment variable
ENVIRONMENT=$1

# Check the environment and echo the corresponding domain
if [ "$ENVIRONMENT" == "PROD" ]; then
    echo "url=www.my.qld.gov.au" >> $GITHUB_OUTPUT
elif [ "$ENVIRONMENT" == "STAGING" ]; then
    echo "url=www.myaccount.staging-services.qld.gov.au" >> $GITHUB_OUTPUT
elif [ "$ENVIRONMENT" == "TEST" ]; then
    echo "url=www.myaccount.test-services.qld.gov.au" >> $GITHUB_OUTPUT
elif [ "$ENVIRONMENT" == "DEV" ]; then
    echo "url=www.myaccount.devpit140cs.qgov.net.au" >> $GITHUB_OUTPUT
else
    echo "url=Unknown environment" >> $GITHUB_OUTPUT
fi