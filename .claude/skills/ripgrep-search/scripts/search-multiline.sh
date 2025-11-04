#!/bin/bash

# Multi-line pattern matching using ripgrep
# Usage: search-multiline.sh <pattern> [directory] [options]

set -e

show_help() {
    cat << EOF
Search for multi-line patterns using ripgrep's multiline mode

Usage: $0 <pattern> [directory] [options]

Arguments:
    pattern     The multi-line pattern to search for (required)
    directory   Directory to search in (default: current directory)

Examples:
    $0 "function.*?\n.*return"           # Function with return statement
    $0 "class \w+:.*?\n.*def"            # Python class with method
    $0 "try\s*\{.*?\}\s*catch"           # Try-catch blocks
    $0 "TODO.*?\n.*FIXME"                # TODO followed by FIXME
    $0 "import.*\nfrom.*import"          # Import statements

Multiline Pattern Examples:
    "start.*?\n.*end"                    # Lines with start...end pattern
    "if.*?\{[^}]*error[^}]*\}"          # If blocks containing 'error'
    "function \w+\([^)]*\)\s*\{[^}]*\}" # Complete function definitions
    "/\*.*?\*/"                          # Multi-line comments
    "<tag[^>]*>.*?</tag>"               # XML/HTML tags with content

Options:
    --help, -h              Show this help message
    --context=N, -C N       Show N lines of context around matches
    --case-sensitive        Force case-sensitive search
    --dotall                Make . match newlines (enables multiline)
    --literal, -F           Use literal/fixed string mode (disables multiline)
    --count, -c             Show count of matches per file
    --files-only, -l        Show only files with matches
    --json                  Output in JSON format
    --type=TYPE, -t TYPE    Limit to specific file type
    --glob=PATTERN, -g      Include files matching glob pattern
    --max-matches=N         Stop after N matches per file
    --pcre2, -P             Use PCRE2 engine for advanced regex features

PCRE2 Advanced Features (use with --pcre2):
    (?<=...)                Positive lookbehind
    (?<!...)                Negative lookbehind
    (?=...)                 Positive lookahead
    (?!...)                 Negative lookahead
    (?s)                    Dotall mode (. matches newlines)
    (?i)                    Case insensitive
    (?m)                    Multiline mode

Tips:
    - Use .*? for non-greedy matching
    - Use \s for whitespace including newlines
    - Use [^}]* to match until specific character
    - Combine with --context for better visibility
EOF
}

# Default values
PATTERN=""
DIRECTORY="."
CONTEXT=""
CASE_SENSITIVE=false
DOTALL_MODE=false
LITERAL_MODE=false
COUNT_ONLY=false
FILES_ONLY=false
JSON_OUTPUT=false
FILE_TYPE=""
GLOB_PATTERN=""
MAX_MATCHES=""
USE_PCRE2=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            exit 0
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
        --dotall)
            DOTALL_MODE=true
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
        --type=*|-t*)
            if [[ $1 == --type=* ]]; then
                FILE_TYPE="${1#*=}"
            else
                FILE_TYPE="$2"
                shift
            fi
            shift
            ;;
        --glob=*|-g*)
            if [[ $1 == --glob=* ]]; then
                GLOB_PATTERN="${1#*=}"
            else
                GLOB_PATTERN="$2"
                shift
            fi
            shift
            ;;
        --max-matches=*)
            MAX_MATCHES="${1#*=}"
            shift
            ;;
        --pcre2|-P)
            USE_PCRE2=true
            shift
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            if [[ -z "$PATTERN" ]]; then
                PATTERN="$1"
            elif [[ "$DIRECTORY" == "." ]]; then
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

# Check if directory exists
if [[ ! -d "$DIRECTORY" ]]; then
    echo "Error: Directory '$DIRECTORY' does not exist" >&2
    exit 1
fi

# Check if ripgrep is available
if ! command -v rg &> /dev/null; then
    echo "Error: ripgrep (rg) is not installed or not in PATH" >&2
    exit 1
fi

# Validate that multiline mode is possible
if [[ "$LITERAL_MODE" == true ]]; then
    echo "Warning: Literal mode (-F) disables multiline pattern matching" >&2
    echo "Consider removing --literal flag for multiline search" >&2
fi

# Build ripgrep command
RG_CMD=("rg")

# Enable multiline mode (unless using literal mode)
if [[ "$LITERAL_MODE" != true ]]; then
    RG_CMD+=("-U")  # Enable multiline mode
fi

# Use PCRE2 if requested or if pattern looks complex
if [[ "$USE_PCRE2" == true ]] || [[ "$PATTERN" =~ \(\?\<|\(\?\!|\(\?\= ]]; then
    RG_CMD+=("-P")
    echo "Using PCRE2 engine for advanced regex features" >&2
fi

# Add the pattern
RG_CMD+=("$PATTERN")

# Add case sensitivity
if [[ "$CASE_SENSITIVE" == true ]]; then
    RG_CMD+=("-s")
fi

# Add literal mode if requested
if [[ "$LITERAL_MODE" == true ]]; then
    RG_CMD+=("-F")
fi

# Add dotall mode for PCRE2 (makes . match newlines)
if [[ "$DOTALL_MODE" == true && "$USE_PCRE2" == true ]]; then
    # Pattern already includes dotall, or we can prepend (?s)
    if [[ ! "$PATTERN" =~ ^\(\?\[^\)]*s ]]; then
        RG_CMD[${#RG_CMD[@]}-1]="(?s)$PATTERN"
    fi
fi

# Add context if specified
if [[ -n "$CONTEXT" ]]; then
    RG_CMD+=("-C" "$CONTEXT")
fi

# Add file type if specified
if [[ -n "$FILE_TYPE" ]]; then
    RG_CMD+=("-t" "$FILE_TYPE")
fi

# Add glob pattern if specified
if [[ -n "$GLOB_PATTERN" ]]; then
    RG_CMD+=("-g" "$GLOB_PATTERN")
fi

# Add max matches if specified
if [[ -n "$MAX_MATCHES" ]]; then
    RG_CMD+=("--max-count" "$MAX_MATCHES")
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

# Print search info
echo "Searching for multiline pattern in $DIRECTORY..." >&2
echo "Pattern: $PATTERN" >&2
if [[ "$LITERAL_MODE" != true ]]; then
    echo "Multiline mode: enabled" >&2
fi
if [[ "$USE_PCRE2" == true ]]; then
    echo "PCRE2 engine: enabled" >&2
fi

# Execute the command
exec "${RG_CMD[@]}"