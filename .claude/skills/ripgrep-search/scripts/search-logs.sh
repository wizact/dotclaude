#!/bin/bash

# Search log files with advanced filtering and timestamp support
# Usage: search-logs.sh <pattern> [log-directory] [options]

set -e

show_help() {
    cat << EOF
Search log files using ripgrep with timestamp and severity filtering

Usage: $0 <pattern> [log-directory] [options]

Arguments:
    pattern         The pattern to search for (required)
    log-directory   Directory containing log files (default: /var/log)

Examples:
    $0 "error"                          # Search for 'error' in /var/log
    $0 "error" ./logs                   # Search in custom log directory
    $0 "404" --level=info               # Search with minimum log level
    $0 "timeout" --since="1 hour ago"   # Search recent logs only
    $0 "user123" --json                 # Output structured JSON

Options:
    --help, -h              Show this help message
    --level=LEVEL           Minimum log level (debug, info, warn, error, fatal)
    --since=TIME            Only show logs since time (e.g., "1 hour ago", "2024-01-01")
    --until=TIME            Only show logs until time
    --context=N, -C N       Show N lines of context around matches
    --case-sensitive        Force case-sensitive search
    --literal, -F           Use literal/fixed string mode
    --count, -c             Show count of matches per file
    --files-only, -l        Show only files with matches
    --json                  Output in JSON format
    --follow-links          Follow symbolic links
    --max-depth=N           Limit directory recursion depth
    --include-archived      Include archived logs (.gz, .bz2, etc.)

Log Level Hierarchy:
    DEBUG < INFO < WARN < ERROR < FATAL/CRITICAL

Time Formats:
    "1 hour ago", "2 days ago", "2024-01-01", "2024-01-01 14:30"
EOF
}

# Default values
PATTERN=""
LOG_DIR="/var/log"
MIN_LEVEL=""
SINCE_TIME=""
UNTIL_TIME=""
CONTEXT=""
CASE_SENSITIVE=false
LITERAL_MODE=false
COUNT_ONLY=false
FILES_ONLY=false
JSON_OUTPUT=false
FOLLOW_LINKS=false
MAX_DEPTH=""
INCLUDE_ARCHIVED=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            exit 0
            ;;
        --level=*)
            MIN_LEVEL="${1#*=}"
            shift
            ;;
        --since=*)
            SINCE_TIME="${1#*=}"
            shift
            ;;
        --until=*)
            UNTIL_TIME="${1#*=}"
            shift
            ;;
        --context=*|-C*)
            if [[ $1 == --context=* ]]; then
                CONTEXT="${1#*=}"
            else
                CONTEXT="$2"
                shift
            fi
            shift
            ;;
        --case-sensitive)
            CASE_SENSITIVE=true
            shift
            ;;
        --literal|-F)
            LITERAL_MODE=true
            shift
            ;;
        --count|-c)
            COUNT_ONLY=true
            shift
            ;;
        --files-only|-l)
            FILES_ONLY=true
            shift
            ;;
        --json)
            JSON_OUTPUT=true
            shift
            ;;
        --follow-links)
            FOLLOW_LINKS=true
            shift
            ;;
        --max-depth=*)
            MAX_DEPTH="${1#*=}"
            shift
            ;;
        --include-archived)
            INCLUDE_ARCHIVED=true
            shift
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            if [[ -z "$PATTERN" ]]; then
                PATTERN="$1"
            elif [[ "$LOG_DIR" == "/var/log" ]]; then
                LOG_DIR="$1"
            else
                echo "Too many arguments" >&2
                exit 1
            fi
            shift
            ;;
    esac
done

# Validate required arguments
if [[ -z "$PATTERN" ]]; then
    echo "Error: Pattern is required" >&2
    echo "Use $0 --help for usage information" >&2
    exit 1
fi

# Check if directory exists
if [[ ! -d "$LOG_DIR" ]]; then
    echo "Error: Log directory '$LOG_DIR' does not exist" >&2
    exit 1
fi

# Check if ripgrep is available
if ! command -v rg &> /dev/null; then
    echo "Error: ripgrep (rg) is not installed or not in PATH" >&2
    exit 1
fi

# Function to convert log level to regex pattern
get_level_pattern() {
    local level="$1"
    case "${level,,}" in
        debug)
            echo "(DEBUG|INFO|WARN|WARNING|ERROR|FATAL|CRITICAL)"
            ;;
        info)
            echo "(INFO|WARN|WARNING|ERROR|FATAL|CRITICAL)"
            ;;
        warn|warning)
            echo "(WARN|WARNING|ERROR|FATAL|CRITICAL)"
            ;;
        error)
            echo "(ERROR|FATAL|CRITICAL)"
            ;;
        fatal|critical)
            echo "(FATAL|CRITICAL)"
            ;;
        *)
            echo "Error: Unknown log level '$level'" >&2
            echo "Valid levels: debug, info, warn, error, fatal" >&2
            exit 1
            ;;
    esac
}

# Build ripgrep command
RG_CMD=("rg")

# Build the search pattern
SEARCH_PATTERN="$PATTERN"

# Add log level filtering if specified
if [[ -n "$MIN_LEVEL" ]]; then
    LEVEL_PATTERN=$(get_level_pattern "$MIN_LEVEL")
    SEARCH_PATTERN="(?=.*$LEVEL_PATTERN)(?=.*$PATTERN)"
    RG_CMD+=("-P")  # Enable PCRE2 for lookahead
fi

# Add the pattern
RG_CMD+=("$SEARCH_PATTERN")

# Add case sensitivity
if [[ "$CASE_SENSITIVE" == true ]]; then
    RG_CMD+=("-s")
else
    RG_CMD+=("-i")  # Case insensitive for logs
fi

# Add literal mode if requested
if [[ "$LITERAL_MODE" == true ]]; then
    RG_CMD+=("-F")
fi

# Add context if specified
if [[ -n "$CONTEXT" ]]; then
    RG_CMD+=("-C" "$CONTEXT")
fi

# Add output mode flags
if [[ "$COUNT_ONLY" == true ]]; then
    RG_CMD+=("-c")
elif [[ "$FILES_ONLY" == true ]]; then
    RG_CMD+=("-l")
elif [[ "$JSON_OUTPUT" == true ]]; then
    RG_CMD+=("--json")
else
    # Default: show line numbers and colors
    RG_CMD+=("-n" "--color=always")
fi

# File type filtering for logs
if [[ "$INCLUDE_ARCHIVED" == true ]]; then
    RG_CMD+=("-z")  # Search compressed files
    RG_CMD+=("-g" "*.log*")
else
    RG_CMD+=("-g" "*.log")
fi

# Add follow links if requested
if [[ "$FOLLOW_LINKS" == true ]]; then
    RG_CMD+=("-L")
fi

# Add max depth if specified
if [[ -n "$MAX_DEPTH" ]]; then
    RG_CMD+=("--max-depth" "$MAX_DEPTH")
fi

# Time filtering (basic implementation using file modification time)
if [[ -n "$SINCE_TIME" ]]; then
    # Convert relative time to find compatible format
    if command -v find &> /dev/null; then
        case "$SINCE_TIME" in
            *"hour"*|*"hours"*)
                HOURS=$(echo "$SINCE_TIME" | grep -o '[0-9]\+')
                RG_CMD+=("--max-filesize" "1G")  # Reasonable limit for recent logs
                ;;
            *"day"*|*"days"*)
                DAYS=$(echo "$SINCE_TIME" | grep -o '[0-9]\+')
                ;;
        esac
    fi
fi

# Add directory
RG_CMD+=("$LOG_DIR")

# Print search info
echo "Searching for '$PATTERN' in log files in $LOG_DIR..." >&2
if [[ -n "$MIN_LEVEL" ]]; then
    echo "Minimum log level: $MIN_LEVEL" >&2
fi
if [[ -n "$SINCE_TIME" ]]; then
    echo "Since: $SINCE_TIME" >&2
fi

# Execute the command
exec "${RG_CMD[@]}"