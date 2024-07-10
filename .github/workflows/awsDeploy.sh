#!/bin/bash
# Usage: ./awsDeploy.sh s3bucket=<S3BUCKET> version=<VERSION>

set -ex

# Default values
UPDATE_LATEST=false
DRY_RUN=false
REPO_ROOT="."
domain=""

# Parse command line arguments
for arg in "$@"; do
    case "$arg" in
        dry_run=*)
            DRY_RUN="${arg#*=}"
            ;;
        s3bucket=*)
            S3BUCKET="${arg#*=}"
            ;;
        version=*)
            VERSION="${arg#*=}"
            ;;
        repo_root=*)
            REPO_ROOT="${arg#*=}"
            ;;
        domain=*)
            DOMAIN="${arg#*=}"
            ;;
        *)
            echo "Ignoring unknown argument: $arg"
            ;;
    esac
done

aws_dry_run=""
if [[ "$DRY_RUN" == "true" ]]; then
    echo "Dry Run enabled"
    aws_dry_run=" --dryrun "
fi


echo "Environment Name: $ENVIRONMENT_NAME"
echo "S3 Bucket: $S3BUCKET"


# Create a working directory
WORK_DIR="${INPUT_WORKDIR:-$(mktemp -d "${HOME}/gitrepo.XXXXXX")}"
[ -z "$WORK_DIR" ] && echo >&2 "::error::Failed to create temporary working directory" && exit 1
git config --global --add safe.directory "$WORK_DIR" || exit 1
cd "$WORK_DIR" || exit 1

aws s3 sync $aws_dry_run --sse AES256 --delete "${REPO_ROOT}/dist" "${S3BUCKET}" --exclude '*.svg'
aws s3 sync $aws_dry_run --sse AES256 --delete "${REPO_ROOT}/dist" "${S3BUCKET}" --exclude '*' --include '*.svg' --content-type 'image/svg+xml'


echo "Deployment $VERSION completed" >> $GITHUB_STEP_SUMMARY
