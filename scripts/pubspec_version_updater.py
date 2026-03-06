#!/usr/bin/env python3
import sys
import re
from pathlib import Path

if len(sys.argv) != 3:
    print("Usage: python update_version.py <pubspec.yaml> <new_version>")
    sys.exit(1)

file_path = Path(sys.argv[1])
new_version = sys.argv[2]

if not file_path.is_file():
    print(f"Error: file {file_path} not found")
    sys.exit(1)

# Read the file
with file_path.open("r", encoding="utf-8") as f:
    content = f.read()

# Update package version
content = re.sub(r"^version:\s*.*$", f"version: {new_version}", content, flags=re.MULTILINE)

# Update dart_network_layer_core dependency
content = re.sub(
    r"(dart_network_layer_core:\s*)\^?\S+",
    rf"\1^{new_version}",
    content,
    flags=re.MULTILINE
)

# Write back
with file_path.open("w", encoding="utf-8") as f:
    f.write(content)

print(f"Updated {file_path} to version {new_version}")
