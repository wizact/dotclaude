#!/usr/bin/env bash

# Find temporary/backup files for cleanup
# Usage: ./find-temp-files.sh [path] [--delete]
# Examples:
#   ./find-temp-files.sh           # Show temp files
#   ./find-temp-files.sh --delete  # Delete temp files

set -eo pipefail

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    cat << 'EOF'
Find Temporary Files

Usage: find-temp-files.sh [path] [--delete]

Arguments:
  path      Search directory (default: current)
  --delete  Actually delete the files (default: just show)

Examples:
  find-temp-files.sh              # Show temp files
  find-temp-files.sh ~/Downloads  # Show temp files in Downloads
  find-temp-files.sh --delete     # Delete temp files in current dir
  find-temp-files.sh ~/Downloads --delete
EOF
    exit 0
fi

delete_mode=false
path="."

# Parse arguments
for arg in "$@"; do
    case $arg in
        --delete) delete_mode=true ;;
        -*) echo "Unknown option: $arg" >&2; exit 1 ;;
        *) path="$arg" ;;
    esac
done

echo "Searching for temporary files in $path..."

# Find temp files
temp_files=$(fd -g '*.tmp' -g '*.temp' -g '*~' -g '.#*' -g '*.bak' -g '*.backup' -g '*.orig' "$path")

if [[ -z "$temp_files" ]]; then
    echo "No temporary files found."
    exit 0
fi

echo "Found temporary files:"
echo "$temp_files"

if [[ "$delete_mode" == true ]]; then
    echo ""
    echo -n "Delete these files? (y/N): "
    read -r response
    if [[ "$response" == "y" || "$response" == "Y" ]]; then
        echo "$temp_files" | xargs rm -f
        echo "Files deleted."
    else
        echo "Cancelled."
    fi
else
    echo ""
    echo "To delete these files, run with --delete flag"
fi