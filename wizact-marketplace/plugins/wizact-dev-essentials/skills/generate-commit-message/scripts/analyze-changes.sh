#!/bin/bash

# Analyze staged and unstaged git changes with file statistics
# Usage: analyze-changes.sh [options]

set -e

show_help() {
    cat << EOF
Analyze git changes with detailed statistics

Usage: $0 [options]

Options:
    --help, -h              Show this help message
    --include-unstaged      Include unstaged changes in analysis
    --detailed              Show detailed per-file statistics
    --json                  Output in JSON format
    --suggest               Suggest commit type based on changes (brief output)

Examples:
    $0                      # Analyze staged changes
    $0 --include-unstaged   # Include unstaged changes
    $0 --detailed           # Show file-by-file breakdown
    $0 --json               # JSON output for tooling
    $0 --suggest            # Get commit type suggestion

Output:
    - Staged/unstaged file counts
    - Changed file types (code/test/docs/config)
    - Lines added/deleted
    - Binary files changed
    - Suggested commit type (with --suggest)
EOF
}

# Default values
INCLUDE_UNSTAGED=false
DETAILED=false
JSON_OUTPUT=false
SUGGEST_ONLY=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            exit 0
            ;;
        --include-unstaged)
            INCLUDE_UNSTAGED=true
            shift
            ;;
        --detailed)
            DETAILED=true
            shift
            ;;
        --json)
            JSON_OUTPUT=true
            shift
            ;;
        --suggest)
            SUGGEST_ONLY=true
            shift
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            echo "Unexpected argument: $1" >&2
            exit 1
            ;;
    esac
done

# Check if git is available
if ! command -v git &> /dev/null; then
    echo "Error: git is not installed or not in PATH" >&2
    exit 1
fi

# Check if in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "Error: Not in a git repository" >&2
    exit 1
fi

# Get staged files
STAGED_FILES=$(git diff --cached --name-only)
if [[ -n "$STAGED_FILES" ]]; then
    STAGED_COUNT=$(echo "$STAGED_FILES" | wc -l | tr -d ' ')
else
    STAGED_COUNT=0
fi

# Get unstaged files if requested
if [[ "$INCLUDE_UNSTAGED" == true ]]; then
    UNSTAGED_FILES=$(git diff --name-only)
    if [[ -n "$UNSTAGED_FILES" ]]; then
        UNSTAGED_COUNT=$(echo "$UNSTAGED_FILES" | wc -l | tr -d ' ')
    else
        UNSTAGED_COUNT=0
    fi
else
    UNSTAGED_FILES=""
    UNSTAGED_COUNT=0
fi

# Analyze file types
analyze_file_types() {
    local files="$1"
    local code_count=0
    local test_count=0
    local doc_count=0
    local config_count=0
    local other_count=0

    while IFS= read -r file; do
        [[ -z "$file" ]] && continue

        # Test files
        if [[ "$file" =~ test|spec|_test\.|\.test\. ]]; then
            ((test_count++))
        # Documentation
        elif [[ "$file" =~ \.(md|txt|rst|adoc)$ ]] || [[ "$file" =~ ^docs/ ]]; then
            ((doc_count++))
        # Config files
        elif [[ "$file" =~ \.(json|yaml|yml|toml|ini|conf|config)$ ]] || [[ "$file" =~ Makefile|Dockerfile|\.env ]]; then
            ((config_count++))
        # Code files
        elif [[ "$file" =~ \.(rs|py|js|ts|jsx|tsx|go|java|c|cpp|h|hpp|rb|php|swift|kt)$ ]]; then
            ((code_count++))
        else
            ((other_count++))
        fi
    done <<< "$files"

    echo "$code_count $test_count $doc_count $config_count $other_count"
}

# Get file type counts for staged files
if [[ ${STAGED_COUNT} -gt 0 ]]; then
    read -r CODE_COUNT TEST_COUNT DOC_COUNT CONFIG_COUNT OTHER_COUNT <<< $(analyze_file_types "$STAGED_FILES")
else
    CODE_COUNT=0
    TEST_COUNT=0
    DOC_COUNT=0
    CONFIG_COUNT=0
    OTHER_COUNT=0
fi

# Get diff stats
if [[ ${STAGED_COUNT} -gt 0 ]]; then
    DIFF_STATS=$(git diff --cached --numstat)
    ADDED_LINES=$(echo "$DIFF_STATS" | awk '{sum += $1} END {print sum}')
    DELETED_LINES=$(echo "$DIFF_STATS" | awk '{sum += $2} END {print sum}')
    BINARY_COUNT=$(echo "$DIFF_STATS" | grep -c "^-" || echo "0")
else
    ADDED_LINES=0
    DELETED_LINES=0
    BINARY_COUNT=0
fi

# Suggest commit type based on changes
suggest_type() {
    if [[ $TEST_COUNT -gt 0 ]] && [[ $CODE_COUNT -eq 0 ]] && [[ $DOC_COUNT -eq 0 ]]; then
        echo "test"
    elif [[ $DOC_COUNT -gt 0 ]] && [[ $CODE_COUNT -eq 0 ]] && [[ $TEST_COUNT -eq 0 ]]; then
        echo "docs"
    elif [[ $CONFIG_COUNT -gt 0 ]] && [[ $CODE_COUNT -eq 0 ]]; then
        if [[ "$STAGED_FILES" =~ \.github/workflows|\.travis|\.circleci ]]; then
            echo "ci"
        else
            echo "build"
        fi
    elif [[ $CODE_COUNT -gt 0 ]]; then
        # Check commit messages or file content for clues
        if [[ $ADDED_LINES -gt $DELETED_LINES ]] && [[ $((ADDED_LINES - DELETED_LINES)) -gt 50 ]]; then
            echo "feat"
        elif [[ "$STAGED_FILES" =~ fix|bug|issue ]]; then
            echo "fix"
        else
            echo "feat"  # Default to feat for code changes
        fi
    else
        echo "chore"
    fi
}

SUGGESTED_TYPE=$(suggest_type)

# Output results
if [[ "$SUGGEST_ONLY" == true ]]; then
    echo "$SUGGESTED_TYPE"
    exit 0
fi

if [[ "$JSON_OUTPUT" == true ]]; then
    cat << EOF
{
  "staged": {
    "total": ${STAGED_COUNT},
    "code": ${CODE_COUNT},
    "test": ${TEST_COUNT},
    "docs": ${DOC_COUNT},
    "config": ${CONFIG_COUNT},
    "other": ${OTHER_COUNT}
  },
  "unstaged": {
    "total": ${UNSTAGED_COUNT}
  },
  "stats": {
    "added_lines": ${ADDED_LINES},
    "deleted_lines": ${DELETED_LINES},
    "binary_files": ${BINARY_COUNT}
  },
  "suggested_type": "${SUGGESTED_TYPE}"
}
EOF
else
    cat << EOF
Git Change Analysis
===================

Staged Changes: ${STAGED_COUNT} file(s)
  Code files:   ${CODE_COUNT}
  Test files:   ${TEST_COUNT}
  Docs:         ${DOC_COUNT}
  Config:       ${CONFIG_COUNT}
  Other:        ${OTHER_COUNT}

Diff Statistics:
  Lines added:     +${ADDED_LINES}
  Lines deleted:   -${DELETED_LINES}
  Binary files:    ${BINARY_COUNT}

Suggested Type: ${SUGGESTED_TYPE}
EOF

    if [[ "$INCLUDE_UNSTAGED" == true ]]; then
        echo ""
        echo "Unstaged Changes: ${UNSTAGED_COUNT} file(s)"
    fi

    if [[ "$DETAILED" == true ]] && [[ ${STAGED_COUNT} -gt 0 ]]; then
        echo ""
        echo "Staged Files:"
        echo "$STAGED_FILES" | nl -w3 -s'. '
    fi
fi
