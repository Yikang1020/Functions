#!/bin/bash

# Source and destination paths
SOURCE="/source/"
DESTINATION="./target/"

# Mode: "copy" or "move"
MODE="move"

COMMON_OPTIONS=(
  -avh
  --progress
  --exclude=/rawdata/
  --exclude=.git/
  --exclude=._*
  --exclude=.DS_Store
)

# Check whether the source directory exists
if [ ! -d "$SOURCE" ]; then
  echo "Error: Source directory does not exist: $SOURCE"
  exit 1
fi

# Create the destination directory if it does not exist
mkdir -p "$DESTINATION"

if [ "$MODE" = "copy" ]; then
  echo "Copying files..."
  rsync "${COMMON_OPTIONS[@]}" "$SOURCE" "$DESTINATION"

elif [ "$MODE" = "move" ]; then
  echo "Moving files..."
  rsync "${COMMON_OPTIONS[@]}" \
    --remove-source-files \
    "$SOURCE" "$DESTINATION"
    # Remove empty source directories, but keep the source root directory
    find "$SOURCE" -mindepth 1 -depth -type d -empty -delete
else
  echo "Invalid mode. Use 'copy' or 'move'."
  exit 1
fi

echo "File transfer completed."