#!/bin/bash

# Script to update versions in pubspec.yaml files

if [ -z "$1" ]; then
  echo "Error: No version provided."
  echo "Usage: ./update_version.sh <new_version> (e.g. 1.0.0-dev11)"
  exit 1
fi

NEW_VERSION=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo "Updating versions to $NEW_VERSION..."

PUBSPECS=(
  "$ROOT_DIR/pubspec.yaml"
  "$ROOT_DIR/dart_network_layer_core/pubspec.yaml"
  "$ROOT_DIR/dart_network_layer_dio/pubspec.yaml"
)

for PUBSPEC in "${PUBSPECS[@]}"; do
  if [ -f "$PUBSPEC" ]; then
    echo "Updating $PUBSPEC"

    # Update the "version:" field
    sed -i '' -e "s/^version: .*/version: $NEW_VERSION/" "$PUBSPEC"

    # Update dependency versions (caret matching)
    sed -i '' -e "s/dart_network_layer_core: \^.*/dart_network_layer_core: ^$NEW_VERSION/" "$PUBSPEC"
    sed -i '' -e "s/dart_network_layer_dio: \^.*/dart_network_layer_dio: ^$NEW_VERSION/" "$PUBSPEC"
  else
    echo "Warning: $PUBSPEC not found."
  fi
done

echo "Versions updated successfully!"

