#!/bin/bash

# Source and destination paths
SOURCE="/source/"
DESTINATION="./target/"

# Mode: "copy" or "move"
MODE="copy"

COMMON_OPTIONS=(
  -avh
  --progress
  --exclude=/rawdata/
  --exclude=.git/
  --exclude=._*
  --exclude=.DS_Store
)

if [ "$MODE" = "copy" ]; then
  echo "Copying files..."
  rsync "${COMMON_OPTIONS[@]}" "$SOURCE" "$DESTINATION"

elif [ "$MODE" = "move" ]; then
  echo "Moving files..."
  rsync "${COMMON_OPTIONS[@]}" \
    --remove-source-files \
    "$SOURCE" "$DESTINATION"

else
  echo "Invalid mode. Use 'copy' or 'move'."
  exit 1
fi

echo "File transfer completed."