#!/usr/bin/env bash

# Find files by extension - most common fd use case
# Usage: ./find-by-extension.sh <extension> [path]
# Examples:
#   ./find-by-extension.sh js
#   ./find-by-extension.sh py ~/project

set -eo pipefail

if [[ $# -eq 0 ]] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    cat << 'EOF'
Find Files by Extension

Usage: find-by-extension.sh <extension> [path]

Examples:
  find-by-extension.sh js                    # All .js files in current dir
  find-by-extension.sh py ~/project          # All .py files in project
  find-by-extension.sh "js,ts,jsx"           # Multiple extensions

Options:
  -h, --help    Show this help
EOF
    exit 0
fi

extension="$1"
path="${2:-.}"

# Handle multiple extensions (comma-separated)
if [[ "$extension" == *","* ]]; then
    IFS=',' read -ra exts <<< "$extension"
    cmd="fd"
    for ext in "${exts[@]}"; do
        cmd="$cmd -e ${ext// /}"  # Remove spaces
    done
    cmd="$cmd \"$path\""
else
    cmd="fd -e $extension \"$path\""
fi

echo "Searching for .$extension files in $path..."
eval "$cmd"