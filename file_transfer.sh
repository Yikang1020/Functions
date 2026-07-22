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
  if [ "$MOVE_CLEANUP" = "delete_source" ]; then
    # Delete empty subdirectories
    find "$SOURCE" -mindepth 1 -depth -type d -empty -delete

    # Delete the source root only if it is empty
    if rmdir "$SOURCE"; then
      echo "Source directory removed: $SOURCE"
    else
      echo "Source directory was not removed because it still contains excluded files."
    fi

  elif [ "$MOVE_CLEANUP" = "keep_directories" ]; then
    echo "Source directory structure retained."
  else
    echo "Invalid MOVE_CLEANUP. Use 'delete_source' or 'keep_directories'."
    exit 1
  fi
else
  echo "Invalid mode. Use 'copy' or 'move'."
  exit 1
fi

echo "File transfer completed."