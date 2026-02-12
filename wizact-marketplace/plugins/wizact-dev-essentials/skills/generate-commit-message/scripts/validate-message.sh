#!/bin/bash

# Validate commit message format against Conventional Commits spec
# Usage: validate-message.sh [file | -]

set -e

show_help() {
    cat << EOF
Validate commit message format against Conventional Commits specification

Usage: $0 [file]

Arguments:
    file            Path to file containing commit message (optional)
                    If not provided, reads from stdin

Options:
    --help, -h      Show this help message

Examples:
    $0 commit.txt                           # Validate from file
    echo "feat: add feature" | $0           # Validate from stdin
    $0 < .git/COMMIT_EDITMSG                # Validate from file via stdin
    $0 <<< "feat(auth): add JWT support"    # Validate from heredoc

Exit Codes:
    0 - Valid commit message
    1 - Invalid format
    2 - Invalid arguments

Validation Rules:
    - Type must be one of: feat, fix, docs, style, refactor, perf, test, build, ci, chore
    - Subject line must be ≤ 50 characters (warning if exceeded)
    - Body lines must be ≤ 72 characters
    - Blank line required between subject and body
    - Description should use imperative mood (basic check)
    - Description should not start with capital letter
    - Description should not end with period
EOF
}

# Valid commit types
VALID_TYPES=("feat" "fix" "docs" "style" "refactor" "perf" "test" "build" "ci" "chore")

# Parse arguments
if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    show_help
    exit 0
fi

# Read commit message
if [[ -n "$1" ]]; then
    # Read from file
    if [[ ! -f "$1" ]]; then
        echo "Error: File not found: $1" >&2
        exit 2
    fi
    MESSAGE=$(cat "$1")
else
    # Read from stdin
    MESSAGE=$(cat)
fi

# Remove comment lines (lines starting with #) while preserving blank lines
FILTERED_MESSAGE=""
while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ ! "$line" =~ ^# ]]; then
        FILTERED_MESSAGE="${FILTERED_MESSAGE}${line}"$'\n'
    fi
done <<< "$MESSAGE"
MESSAGE="${FILTERED_MESSAGE%$'\n'}"  # Remove trailing newline

# Check if message is empty
if [[ -z "$MESSAGE" ]]; then
    echo "Error: Commit message is empty" >&2
    exit 1
fi

# Split message into lines (preserving blank lines)
LINES=()
while IFS= read -r line || [[ -n "$line" ]]; do
    LINES+=("$line")
done <<< "$MESSAGE"

# Get subject line (first non-empty line)
SUBJECT=""
for line in "${LINES[@]}"; do
    if [[ -n "$line" ]]; then
        SUBJECT="$line"
        break
    fi
done

if [[ -z "$SUBJECT" ]]; then
    echo "Error: No subject line found" >&2
    exit 1
fi

# Parse subject line
# Format: <type>[optional scope]: <description>
# or:     <type>[optional scope]!: <description>

if ! [[ "$SUBJECT" =~ ^([a-z]+)(\([a-zA-Z0-9_-]+\))?(!)?:\ (.+)$ ]]; then
    echo "Error: Subject line does not match Conventional Commits format" >&2
    echo "Expected: <type>[scope]: <description>" >&2
    echo "Got: $SUBJECT" >&2
    exit 1
fi

TYPE="${BASH_REMATCH[1]}"
SCOPE="${BASH_REMATCH[2]}"
BREAKING_INDICATOR="${BASH_REMATCH[3]}"
DESCRIPTION="${BASH_REMATCH[4]}"

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
if [[ "$DESCRIPTION" =~ ^[A-Z] ]]; then
    echo "Error: Description should not start with capital letter" >&2
    echo "Got: $DESCRIPTION" >&2
    exit 1
fi

if [[ "$DESCRIPTION" =~ \.$  ]]; then
    echo "Error: Description should not end with period" >&2
    echo "Got: $DESCRIPTION" >&2
    exit 1
fi

# Check for past tense (basic check)
if [[ "$DESCRIPTION" =~ (added|fixed|changed|updated|removed|deleted|created)[[:space:]] ]]; then
    echo "Warning: Description may be in past tense (use imperative mood)" >&2
    echo "Example: 'add' not 'added', 'fix' not 'fixed'" >&2
fi

# Check subject line length
SUBJECT_LEN=${#SUBJECT}
if [[ $SUBJECT_LEN -gt 50 ]]; then
    echo "Warning: Subject line is $SUBJECT_LEN characters (recommended max: 50)" >&2
fi

# Validate body if present
if [[ ${#LINES[@]} -gt 1 ]]; then
    # Check for blank line after subject
    if [[ -n "${LINES[1]}" ]]; then
        echo "Error: Missing blank line between subject and body" >&2
        exit 1
    fi

    # Check body line lengths (skip first two lines: subject and blank)
    line_num=1
    for line in "${LINES[@]:2}"; do
        ((line_num++))
        line_len=${#line}

        # Skip footers (lines starting with recognized footer tokens)
        if [[ "$line" =~ ^(BREAKING\ CHANGE:|Fixes|Closes|Refs|Co-authored-by): ]]; then
            continue
        fi

        # Skip empty lines
        if [[ -z "$line" ]]; then
            continue
        fi

        if [[ $line_len -gt 72 ]]; then
            echo "Warning: Line $line_num is $line_len characters (recommended max: 72)" >&2
            echo "Line: ${line:0:50}..." >&2
        fi
    done
fi

echo "✓ Valid Conventional Commit message" >&2
exit 0
