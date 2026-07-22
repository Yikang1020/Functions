#!/bin/bash

set -euo pipefail

# input
TARGET_DIR="/path/to/target" # Absolute directory path to search
EXTENSIONS=(
  ".log"
  “.txt”
) # File extensions to delete
MODE="delete" # Mode: "preview" or "delete"

# Require an absolute target path
if [[ "$TARGET_DIR" != /* ]]; then
  echo "Error: TARGET_DIR must be an absolute path." >&2
  exit 1
fi

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

# Refuse unsafe target directories
if [[ "$TARGET_DIR" == "/" || "$TARGET_DIR" == "$HOME" ]]; then
  echo "Error: Refusing to operate on unsafe directory: $TARGET_DIR" >&2
  exit 1
fi

# Validate the selected mode
if [[ "$MODE" != "preview" && "$MODE" != "delete" ]]; then
  echo "Error: MODE must be 'preview' or 'delete'." >&2
  exit 1
fi

matched_count=0
deleted_count=0

for extension in "${EXTENSIONS[@]}"; do
  # Add a leading dot if necessary
  if [[ "$extension" != .* ]]; then
    extension=".$extension"
  fi

  while IFS= read -r -d '' absolute_file_path; do
    ((matched_count += 1))

    if [[ "$MODE" == "preview" ]]; then
      printf 'Would delete: %s\n' "$absolute_file_path"
    else
      /bin/rm -- "$absolute_file_path"
      printf 'Deleted: %s\n' "$absolute_file_path"
      ((deleted_count += 1))
    fi
  done < <(
    /usr/bin/find "$TARGET_DIR" \
      -type f \
      -iname "*${extension}" \
      -print0
  )
done

echo
echo "Target directory: $TARGET_DIR"
echo "Matched files: $matched_count"

if [[ "$MODE" == "preview" ]]; then
  echo "Preview only. No files were deleted."
  echo "Set MODE=\"delete\" after confirming the file list."
else
  echo "Deleted files: $deleted_count"
fi