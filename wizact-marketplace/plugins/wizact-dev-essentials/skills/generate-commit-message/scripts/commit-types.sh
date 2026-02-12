#!/bin/bash

# List and explain commit types with examples
# Usage: commit-types.sh [options]

set -e

show_help() {
    cat << EOF
List and explain Conventional Commit types with examples

Usage: $0 [options]

Options:
    --help, -h          Show this help message
    --json              Output in JSON format
    --type=TYPE         Show details for specific type only
    --examples          Include scope examples for each type

Examples:
    $0                  # Display all commit types
    $0 --json           # JSON output for tooling
    $0 --type=feat      # Show details for 'feat' type only
    $0 --examples       # Include scope examples
EOF
}

# Default values
JSON_OUTPUT=false
FILTER_TYPE=""
SHOW_EXAMPLES=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            exit 0
            ;;
        --json)
            JSON_OUTPUT=true
            shift
            ;;
        --type=*)
            FILTER_TYPE="${1#*=}"
            shift
            ;;
        --examples)
            SHOW_EXAMPLES=true
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

# Define commit types - use arrays instead of associative arrays for compatibility
TYPES=(
    "feat:Features:New feature for the user:feat(auth): add JWT token support:api, ui, auth, database, cli, parser"
    "fix:Bug Fixes:Bug fix for the user:fix(parser): handle empty input correctly:api, ui, auth, database, parser, validation"
    "docs:Documentation:Documentation only changes:docs: update installation guide:api, readme, guide, changelog"
    "style:Code Style:Changes that don't affect code meaning (formatting, whitespace):style: fix indentation in user module:formatting, linting"
    "refactor:Code Refactoring:Code change that neither fixes a bug nor adds a feature:refactor(api): simplify error handling:api, ui, database, utils, core"
    "perf:Performance:Code change that improves performance:perf(database): add indexes for user queries:database, api, ui, parser, cache"
    "test:Tests:Adding missing tests or correcting existing tests:test(auth): add edge cases for token validation:unit, integration, e2e"
    "build:Build System:Changes affecting build system or external dependencies:build: update dependencies to latest versions:deps, npm, cargo, gradle, webpack"
    "ci:CI/CD:Changes to CI configuration files and scripts:ci: parallelize test suite in GitHub Actions:github, travis, circle, jenkins"
    "chore:Chores:Other changes that don't modify src or test files:chore: update .gitignore patterns:tooling, scaffolding, config"
)

# Get type info from entry
get_field() {
    local entry="$1"
    local field="$2"
    echo "$entry" | cut -d: -f"$field"
}

# Filter types if specified
FILTERED_TYPES=()
if [[ -n "$FILTER_TYPE" ]]; then
    for type_entry in "${TYPES[@]}"; do
        type=$(get_field "$type_entry" 1)
        if [[ "$type" == "$FILTER_TYPE" ]]; then
            FILTERED_TYPES=("$type_entry")
            break
        fi
    done
    if [[ ${#FILTERED_TYPES[@]} -eq 0 ]]; then
        echo "Error: Unknown type '$FILTER_TYPE'" >&2
        echo "Valid types: feat, fix, docs, style, refactor, perf, test, build, ci, chore" >&2
        exit 1
    fi
else
    FILTERED_TYPES=("${TYPES[@]}")
fi

# JSON output
if [[ "$JSON_OUTPUT" == true ]]; then
    echo "{"
    echo "  \"types\": {"
    first=true
    for type_entry in "${FILTERED_TYPES[@]}"; do
        type=$(get_field "$type_entry" 1)
        name=$(get_field "$type_entry" 2)
        desc=$(get_field "$type_entry" 3)
        example=$(get_field "$type_entry" 4)
        scopes=$(get_field "$type_entry" 5)

        if [[ "$first" == false ]]; then
            echo ","
        fi
        first=false
        cat << EOF
    "$type": {
      "name": "$name",
      "description": "$desc",
      "example": "$example",
      "common_scopes": "$scopes"
    }
EOF
    done
    echo ""
    echo "  }"
    echo "}"
else
    # Human-readable output
    echo "Conventional Commit Types"
    echo "=========================="
    echo ""

    for type_entry in "${FILTERED_TYPES[@]}"; do
        type=$(get_field "$type_entry" 1)
        name=$(get_field "$type_entry" 2)
        desc=$(get_field "$type_entry" 3)
        example=$(get_field "$type_entry" 4)
        scopes=$(get_field "$type_entry" 5)

        echo "Type: $type"
        echo "Name: $name"
        echo "Description: $desc"
        echo "Example: $example"

        if [[ "$SHOW_EXAMPLES" == true ]]; then
            echo "Common Scopes: $scopes"
        fi

        echo ""
    done

    if [[ "$SHOW_EXAMPLES" == false ]]; then
        echo "Use --examples to see common scope examples for each type"
    fi
fi
