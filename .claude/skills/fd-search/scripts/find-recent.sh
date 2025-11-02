#!/usr/bin/env bash

# Find recently modified files
# Usage: ./find-recent.sh [time] [path]
# Examples:
#   ./find-recent.sh           # Last 24 hours
#   ./find-recent.sh 1week     # Last week
#   ./find-recent.sh 3hours ~/project

set -eo pipefail

if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    cat << 'EOF'
Find Recent Files

Usage: find-recent.sh [time] [path]

Arguments:
  time    Time period (default: 1day)
          Examples: 1hour, 1day, 1week, 1month
  path    Search directory (default: current)

Examples:
  find-recent.sh                   # Last 24 hours
  find-recent.sh 1week             # Last week
  find-recent.sh 3hours ~/project  # Last 3 hours in project
EOF
    exit 0
fi

time="${1:-1day}"
path="${2:-.}"

echo "Finding files modified within the last $time in $path..."
fd --changed-within "$time" -t f "$path" -x ls -lt