#!/bin/bash
set -e

BASE_DIR=$1
ENVIRONMENT=$2

CONFIG_DIR="$BASE_DIR/src/.config"
SUFFIX=".$ENVIRONMENT"

# Loop through each file in the .config directory
for FILE in "$CONFIG_DIR"/*"$SUFFIX"; do
  # Check if the file exists
  if [ -f "$FILE" ]; then
     # Get the base name of the file (without the directory part)
     BASENAME=$(basename "$FILE")
     # Remove the suffix from the base name
     NEW_NAME="${BASENAME%$SUFFIX}"
     # Copy the file to the destination directory with the new name
     cp "$FILE" "$BASE_DIR/dist/$NEW_NAME"

     echo "Copied $FILE to $BASE_DIR/dist/$NEW_NAME"
  fi
done

echo "Files processed and moved."
