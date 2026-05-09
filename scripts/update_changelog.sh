#!/bin/bash

# Script to run git cliff and prepend unreleased changes to CHANGELOG.md files

if [ -z "$1" ]; then
  echo "Error: No version provided."
  echo "Usage: ./update_changelog.sh <new_version> (e.g. 1.0.0-dev11)"
  exit 1
fi

NEW_VERSION=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Updating changelogs to version $NEW_VERSION..."

CHANGELOGS=(
  "$ROOT_DIR/CHANGELOG.md"
  "$ROOT_DIR/dart_network_layer_core/CHANGELOG.md"
  "$ROOT_DIR/dart_network_layer_dio/CHANGELOG.md"
)

# Move to the root directory so git cliff runs in the workspace context
cd "$ROOT_DIR" || exit 1

for CHANGELOG in "${CHANGELOGS[@]}"; do
  if [ -f "$CHANGELOG" ]; then
    echo "Updating $CHANGELOG"
    # Execute git cliff, specifying the unreleased changes, setting the tag, and prepending to the file
    git cliff --unreleased --tag "$NEW_VERSION" --prepend "$CHANGELOG"
  else
    echo "Warning: $CHANGELOG not found."
  fi
done

echo "Changelogs updated successfully!"
