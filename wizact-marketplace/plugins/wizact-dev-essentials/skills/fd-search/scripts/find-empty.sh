#!/usr/bin/env bash

# Find empty files and directories
# Usage: ./find-empty.sh [type] [path]
# Examples:
#   ./find-empty.sh           # Both files and dirs
#   ./find-empty.sh files     # Only empty files
#   ./find-empty.sh dirs      # Only empty directories

set -eo pipefail

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    cat << 'EOF'
Find Empty Files and Directories

Usage: find-empty.sh [type] [path]

Arguments:
  type    What to find: files, dirs, or both (default: both)
  path    Search directory (default: current)

Examples:
  find-empty.sh              # Both empty files and dirs
  find-empty.sh files        # Only empty files
  find-empty.sh dirs         # Only empty directories
  find-empty.sh both ~/project
EOF
    exit 0
fi

type="${1:-both}"
path="${2:-.}"

case "$type" in
    files|file|f)
        echo "Finding empty files in $path..."
        fd -t e -t f "$path"
        ;;
    dirs|directories|dir|d)
        echo "Finding empty directories in $path..."
        fd -t e -t d "$path"
        ;;
    both|all|*)
        echo "Finding empty files and directories in $path..."
        echo "Empty files:"
        fd -t e -t f "$path" || echo "  (none)"
        echo ""
        echo "Empty directories:"
        fd -t e -t d "$path" || echo "  (none)"
        ;;
esac