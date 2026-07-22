#!/bin/bash

set -euo pipefail

# ============================================================
# Input configuration
# ============================================================

# Source and destination must use absolute paths
SOURCE="/absolute/path/to/source/"
DESTINATION="/absolute/path/to/target/"

# Transfer operation: "copy" or "move"
TRANSFER_MODE="move"

# Execution mode: "preview" or "execute"
RUN_MODE="preview"

# Cleanup mode after moving:
# "delete_source"    Delete empty subdirectories and the source root if empty
# "keep_directories" Keep the source directory structure
MOVE_CLEANUP="delete_source"

# ============================================================
# Validate configuration
# ============================================================

# Check whether the source directory exists
if [[ ! -d "$SOURCE" ]]; then
  echo "Error: Source directory does not exist: $SOURCE" >&2
  exit 1
fi

# Validate the transfer mode
if [[ "$TRANSFER_MODE" != "copy" &&
      "$TRANSFER_MODE" != "move" ]]; then
  echo "Error: TRANSFER_MODE must be 'copy' or 'move'." >&2
  exit 1
fi

# Validate the execution mode
if [[ "$RUN_MODE" != "preview" &&
      "$RUN_MODE" != "execute" ]]; then
  echo "Error: RUN_MODE must be 'preview' or 'execute'." >&2
  exit 1
fi

# Validate the cleanup mode
if [[ "$MOVE_CLEANUP" != "delete_source" &&
      "$MOVE_CLEANUP" != "keep_directories" ]]; then
  echo "Error: MOVE_CLEANUP must be 'delete_source' or 'keep_directories'." >&2
  exit 1
fi

# ============================================================
# Resolve paths
# ============================================================

# Resolve the canonical source path
SOURCE="$(
  cd -- "$SOURCE"
  /bin/pwd -P
)"

# Preserve the trailing slash so rsync transfers the contents
# of the source directory rather than the directory itself
SOURCE="${SOURCE%/}/"

# Refuse to operate on the filesystem root
if [[ "$SOURCE" == "/" ]]; then
  echo "Error: Refusing to use the filesystem root as SOURCE." >&2
  exit 1
fi

if [[ "$RUN_MODE" == "execute" ]]; then
  # Create the destination only during actual execution
  mkdir -p -- "$DESTINATION"

  # Resolve the canonical destination path
  DESTINATION="$(
    cd -- "$DESTINATION"
    /bin/pwd -P
  )"

  DESTINATION="${DESTINATION%/}/"
fi

# Refuse identical source and destination paths
if [[ "$SOURCE" == "$DESTINATION" ]]; then
  echo "Error: SOURCE and DESTINATION must be different." >&2
  exit 1
fi

# Refuse a destination located inside the source directory
if [[ "$DESTINATION" == "$SOURCE"* ]]; then
  echo "Error: DESTINATION must not be inside SOURCE." >&2
  echo "Source:      $SOURCE" >&2
  echo "Destination: $DESTINATION" >&2
  exit 1
fi

# ============================================================
# Configure rsync
# ============================================================

COMMON_OPTIONS=(
  -avh
  --progress
  --exclude=/rawdata/
  --exclude=.git/
  --exclude=._*
  --exclude=.DS_Store
)

# Prevent all filesystem changes during preview
if [[ "$RUN_MODE" == "preview" ]]; then
  COMMON_OPTIONS+=(--dry-run)
fi

# ============================================================
# Display configuration
# ============================================================

echo "Source:         $SOURCE"
echo "Destination:    $DESTINATION"
echo "Transfer mode:  $TRANSFER_MODE"
echo "Run mode:       $RUN_MODE"

if [[ "$TRANSFER_MODE" == "move" ]]; then
  echo "Cleanup mode:   $MOVE_CLEANUP"
fi

echo

if [[ "$RUN_MODE" == "preview" ]]; then
  echo "Preview mode enabled."
  echo "No files or directories will be changed."
  echo
fi

# ============================================================
# Run the transfer
# ============================================================

if [[ "$TRANSFER_MODE" == "copy" ]]; then
  if [[ "$RUN_MODE" == "preview" ]]; then
    echo "Previewing files that would be copied..."
  else
    echo "Copying files..."
  fi

  rsync \
    "${COMMON_OPTIONS[@]}" \
    "$SOURCE" \
    "$DESTINATION"

elif [[ "$TRANSFER_MODE" == "move" ]]; then
  if [[ "$RUN_MODE" == "preview" ]]; then
    echo "Previewing files that would be moved..."
  else
    echo "Moving files..."
  fi

  rsync \
    "${COMMON_OPTIONS[@]}" \
    --remove-source-files \
    "$SOURCE" \
    "$DESTINATION"

  # Do not perform cleanup during preview
  if [[ "$RUN_MODE" == "preview" ]]; then
    echo
    echo "Preview only. Source files and directories were not removed."

  elif [[ "$MOVE_CLEANUP" == "delete_source" ]]; then
    # Delete empty source subdirectories
    find "$SOURCE" \
      -mindepth 1 \
      -depth \
      -type d \
      -empty \
      -delete

    # Delete the source root only if it is empty
    if rmdir -- "$SOURCE"; then
      echo "Source directory removed: $SOURCE"
    else
      echo "Source directory was not removed because it still contains excluded files."
    fi

  elif [[ "$MOVE_CLEANUP" == "keep_directories" ]]; then
    echo "Source directory structure retained."
  fi
fi

# ============================================================
# Completion message
# ============================================================

echo

if [[ "$RUN_MODE" == "preview" ]]; then
  echo "Preview completed. No files were changed."
  echo "Set RUN_MODE=\"execute\" to perform the transfer."
else
  echo "File transfer completed."
fi