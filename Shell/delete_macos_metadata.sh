#!/bin/bash

set -euo pipefail

# Input
TARGET_DIR="/path/to/target"

# Mode: "preview" or "delete"
MODE="preview"

# Check whether the target directory exists
if [[ ! -d "$TARGET_DIR" ]]; then
  echo "Error: Target directory does not exist: $TARGET_DIR" >&2
  exit 1
fi

# Resolve the canonical absolute path
TARGET_DIR="$(
  cd -- "$TARGET_DIR"
  /bin/pwd -P
)"

# Refuse to operate on the filesystem root
if [[ "$TARGET_DIR" == "/" ]]; then
  echo "Error: Refusing to operate on the filesystem root." >&2
  exit 1
fi

if [[ "$MODE" == "preview" ]]; then
  echo "Previewing files that would be deleted from:"
  echo "$TARGET_DIR"
  echo

  find "$TARGET_DIR" \
    -type f \
    -name "._*" \
    -print

  echo
  echo "Preview completed. No files were deleted."

elif [[ "$MODE" == "delete" ]]; then
  echo "Deleting matching files from:"
  echo "$TARGET_DIR"
  echo

  find "$TARGET_DIR" \
    -type f \
    -name "._*" \
    -print \
    -exec rm -f -- {} +

  echo
  echo "All files beginning with '._' have been removed."

else
  echo "Error: MODE must be 'preview' or 'delete'." >&2
  exit 1
fi