#!/usr/bin/env bash

# Find large files - common cleanup use case
# Usage: ./find-large-files.sh [size] [path]
# Examples:
#   ./find-large-files.sh           # Files > 100MB
#   ./find-large-files.sh 1g        # Files > 1GB
#   ./find-large-files.sh 50m ~/Downloads

set -eo pipefail

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    cat << 'EOF'
Find Large Files

Usage: find-large-files.sh [size] [path]

Arguments:
  size    Minimum size (default: 100m)
          Examples: 10m, 1g, 500k
  path    Search directory (default: current)

Examples:
  find-large-files.sh              # Files > 100MB
  find-large-files.sh 1g           # Files > 1GB
  find-large-files.sh 50m ~/Downloads
EOF
    exit 0
fi

size="${1:-100m}"
path="${2:-.}"

echo "Finding files larger than $size in $path..."
fd -S "+$size" -t f "$path" -x ls -lh