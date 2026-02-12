#!/bin/bash

# Generate Conventional Commit message from parameters
# Usage: generate-message.sh <type> [scope] <description> [options]

set -e

show_help() {
    cat << EOF
Generate Conventional Commit message from parameters

Usage: $0 <type> [scope] <description> [options]

Arguments:
    type            Commit type (feat, fix, docs, style, refactor, perf, test, build, ci, chore)
    scope           Optional scope in parentheses (e.g., auth, api, ui)
    description     Brief description in imperative mood

Options:
    --help, -h              Show this help message
    --body TEXT             Add body paragraph(s)
    --footer TEXT           Add footer (can be used multiple times)
    --breaking TEXT         Add BREAKING CHANGE footer
    --breaking-indicator    Add ! after type/scope for breaking change

Examples:
    $0 feat "add user authentication"
    $0 fix auth "handle null token case"
    $0 feat api "add pagination" --body "Implement cursor-based pagination"
    $0 refactor "simplify error handling" --body "Consolidate logic" --footer "Refs #123"
    $0 feat api "remove legacy endpoints" --breaking "Removed /v1 API"
    $0 feat api "change response format" --breaking-indicator --breaking "Changed to snake_case"

Output:
    Prints formatted commit message to stdout
EOF
}

# Valid commit types
VALID_TYPES=("feat" "fix" "docs" "style" "refactor" "perf" "test" "build" "ci" "chore")

# Default values
TYPE=""
SCOPE=""
DESCRIPTION=""
BODY=""
FOOTERS=()
BREAKING=""
BREAKING_INDICATOR=false

# Parse arguments
POSITIONAL_ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            exit 0
            ;;
        --body)
            BODY="$2"
            shift 2
            ;;
        --footer)
            FOOTERS+=("$2")
            shift 2
            ;;
        --breaking)
            BREAKING="$2"
            shift 2
            ;;
        --breaking-indicator)
            BREAKING_INDICATOR=true
            shift
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            POSITIONAL_ARGS+=("$1")
            shift
            ;;
    esac
done

# Restore positional parameters
set -- "${POSITIONAL_ARGS[@]}"

# Parse positional arguments
if [[ $# -lt 2 ]]; then
    echo "Error: Missing required arguments" >&2
    echo "Usage: $0 <type> [scope] <description>" >&2
    echo "Use $0 --help for more information" >&2
    exit 1
fi

TYPE="$1"
shift

# Check if next arg looks like a scope or description
if [[ $# -eq 1 ]]; then
    # Only description provided
    DESCRIPTION="$1"
elif [[ $# -ge 2 ]]; then
    # Could be scope + description
    # Simple heuristic: if first arg is a single word without spaces, it's likely a scope
    if [[ "$1" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        SCOPE="$1"
        shift
        DESCRIPTION="$*"
    else
        DESCRIPTION="$*"
    fi
fi

# Validate type
is_valid_type() {
    local type="$1"
    for valid_type in "${VALID_TYPES[@]}"; do
        if [[ "$type" == "$valid_type" ]]; then
            return 0
        fi
    done
    return 1
}

if ! is_valid_type "$TYPE"; then
    echo "Error: Invalid commit type '$TYPE'" >&2
    echo "Valid types: ${VALID_TYPES[*]}" >&2
    exit 1
fi

# Validate description
if [[ -z "$DESCRIPTION" ]]; then
    echo "Error: Description is required" >&2
    exit 1
fi

# Check description format
if [[ "$DESCRIPTION" =~ ^[A-Z] ]]; then
    echo "Warning: Description should not start with capital letter (use lowercase)" >&2
fi

if [[ "$DESCRIPTION" =~ \.$  ]]; then
    echo "Warning: Description should not end with period" >&2
fi

# Build subject line
SUBJECT="$TYPE"

if [[ -n "$SCOPE" ]]; then
    SUBJECT="${SUBJECT}(${SCOPE})"
fi

if [[ "$BREAKING_INDICATOR" == true ]]; then
    SUBJECT="${SUBJECT}!"
fi

SUBJECT="${SUBJECT}: ${DESCRIPTION}"

# Check subject line length
SUBJECT_LEN=${#SUBJECT}
if [[ $SUBJECT_LEN -gt 50 ]]; then
    echo "Warning: Subject line is $SUBJECT_LEN characters (recommended max: 50)" >&2
    echo "Consider moving details to the body" >&2
fi

# Build commit message
MESSAGE="$SUBJECT"

# Add body if provided
if [[ -n "$BODY" ]]; then
    MESSAGE="${MESSAGE}

${BODY}"
fi

# Add breaking change footer if provided
if [[ -n "$BREAKING" ]]; then
    MESSAGE="${MESSAGE}

BREAKING CHANGE: ${BREAKING}"
fi

# Add other footers
for footer in "${FOOTERS[@]}"; do
    MESSAGE="${MESSAGE}

${footer}"
done

# Output the message
echo "$MESSAGE"
