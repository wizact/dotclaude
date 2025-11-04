#!/bin/bash

# Search in source code files with smart filtering
# Usage: search-code.sh <pattern> [file-type] [directory]

set -e

show_help() {
    cat << EOF
Search in source code files using ripgrep with smart filtering

Usage: $0 <pattern> [file-type] [directory]

Arguments:
    pattern     The pattern to search for (required)
    file-type   File type to search (optional: rust, py, js, cpp, etc.)
    directory   Directory to search in (default: current directory)

Examples:
    $0 "function"                    # Search for 'function' in all code files
    $0 "TODO" rust                   # Search for TODO in Rust files
    $0 "error" py src/               # Search for 'error' in Python files in src/
    $0 "panic!" rust --word          # Search for whole word 'panic!' in Rust
    $0 "fn \w+\(" rust --regex       # Search with regex pattern

Options:
    --help, -h          Show this help message
    --word, -w          Match whole words only
    --case-sensitive    Force case-sensitive search
    --regex, -r         Use regex mode (default)
    --literal, -F       Use literal/fixed string mode
    --context=N, -C N   Show N lines of context around matches
    --count, -c         Show count of matches per file
    --files-only, -l    Show only files with matches
    --json              Output in JSON format

File types (use with -t flag):
    rust, py, js, ts, cpp, c, java, go, php, rb, swift, kotlin, etc.
    Run 'rg --type-list' to see all available types.
EOF
}

# Default values
PATTERN=""
FILE_TYPE=""
DIRECTORY="."
WORD_MATCH=false
CASE_SENSITIVE=false
LITERAL_MODE=false
CONTEXT=""
COUNT_ONLY=false
FILES_ONLY=false
JSON_OUTPUT=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            exit 0
            ;;
        --word|-w)
            WORD_MATCH=true
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
        --regex|-r)
            LITERAL_MODE=false
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
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            if [[ -z "$PATTERN" ]]; then
                PATTERN="$1"
            elif [[ -z "$FILE_TYPE" ]]; then
                FILE_TYPE="$1"
            elif [[ -z "$DIRECTORY" || "$DIRECTORY" == "." ]]; then
                DIRECTORY="$1"
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

# Check if ripgrep is available
if ! command -v rg &> /dev/null; then
    echo "Error: ripgrep (rg) is not installed or not in PATH" >&2
    echo "Install it with: brew install ripgrep (macOS) or apt install ripgrep (Ubuntu)" >&2
    exit 1
fi

# Build ripgrep command
RG_CMD=("rg")

# Add pattern
RG_CMD+=("$PATTERN")

# Add file type if specified
if [[ -n "$FILE_TYPE" ]]; then
    RG_CMD+=("-t" "$FILE_TYPE")
fi

# Add word match if requested
if [[ "$WORD_MATCH" == true ]]; then
    RG_CMD+=("-w")
fi

# Add case sensitivity
if [[ "$CASE_SENSITIVE" == true ]]; then
    RG_CMD+=("-s")
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

# Add directory
RG_CMD+=("$DIRECTORY")

# Execute the command
echo "Searching for '$PATTERN' in $FILE_TYPE files in $DIRECTORY..." >&2
exec "${RG_CMD[@]}"