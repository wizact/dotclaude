#!/bin/bash

# Interactive commit message builder
# Usage: commit-interactive.sh [options]

set -e

show_help() {
    cat << EOF
Interactive commit message builder with guided prompts

Usage: $0 [options]

Options:
    --help, -h          Show this help message
    --type=TYPE         Pre-fill commit type
    --no-analyze        Skip git change analysis
    --preview           Preview only (don't write to file)

Examples:
    $0                  # Interactive builder with all prompts
    $0 --type=feat      # Pre-select 'feat' type
    $0 --no-analyze     # Skip change analysis step
    $0 --preview        # Show preview without saving

Workflow:
    1. Shows git change analysis (unless --no-analyze)
    2. Select commit type from menu
    3. Prompt for optional scope
    4. Enter description
    5. Optionally add body
    6. Optionally add footers
    7. Show preview
    8. Confirm and save to commit.txt
EOF
}

# Default values
PRESET_TYPE=""
SKIP_ANALYZE=false
PREVIEW_ONLY=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            exit 0
            ;;
        --type=*)
            PRESET_TYPE="${1#*=}"
            shift
            ;;
        --no-analyze)
            SKIP_ANALYZE=true
            shift
            ;;
        --preview)
            PREVIEW_ONLY=true
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

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Show analysis if not skipped
if [[ "$SKIP_ANALYZE" == false ]]; then
    echo "═══════════════════════════════════════════════════════"
    echo "Git Change Analysis"
    echo "═══════════════════════════════════════════════════════"
    "$SCRIPT_DIR/analyze-changes.sh" || true
    echo ""
fi

# Commit types
TYPES=("feat" "fix" "docs" "style" "refactor" "perf" "test" "build" "ci" "chore")
TYPE_LABELS=(
    "feat      - New feature"
    "fix       - Bug fix"
    "docs      - Documentation only"
    "style     - Code style (formatting)"
    "refactor  - Code refactoring"
    "perf      - Performance improvement"
    "test      - Add or update tests"
    "build     - Build system or dependencies"
    "ci        - CI/CD configuration"
    "chore     - Maintenance tasks"
)

# Select commit type
if [[ -n "$PRESET_TYPE" ]]; then
    TYPE="$PRESET_TYPE"
    echo "Using preset type: $TYPE"
else
    echo "═══════════════════════════════════════════════════════"
    echo "Select Commit Type"
    echo "═══════════════════════════════════════════════════════"
    PS3="Enter number (1-10): "
    select type_label in "${TYPE_LABELS[@]}"; do
        if [[ -n "$type_label" ]]; then
            TYPE="${TYPES[$((REPLY-1))]}"
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done
fi

echo ""

# Prompt for scope
echo "═══════════════════════════════════════════════════════"
echo "Scope (Optional)"
echo "═══════════════════════════════════════════════════════"
echo "Examples: api, ui, auth, database, parser, cli"
read -p "Enter scope (or press Enter to skip): " SCOPE
echo ""

# Prompt for description
echo "═══════════════════════════════════════════════════════"
echo "Description (Required)"
echo "═══════════════════════════════════════════════════════"
echo "Use imperative mood: 'add' not 'added'"
echo "Keep under 50 characters"
echo "Don't capitalize first letter"
echo "Don't end with period"
while true; do
    read -p "Enter description: " DESCRIPTION
    if [[ -n "$DESCRIPTION" ]]; then
        break
    else
        echo "Description is required. Please try again."
    fi
done
echo ""

# Prompt for body
echo "═══════════════════════════════════════════════════════"
echo "Body (Optional)"
echo "═══════════════════════════════════════════════════════"
echo "Explain what and why, not how"
echo "Wrap lines at 72 characters"
echo "Enter multiple lines, end with empty line"
read -p "Add body? (y/N): " add_body
BODY=""
if [[ "$add_body" =~ ^[Yy]$ ]]; then
    echo "Enter body (empty line to finish):"
    while IFS= read -r line; do
        [[ -z "$line" ]] && break
        BODY="${BODY}${line}"$'\n'
    done
fi
echo ""

# Prompt for footers
echo "═══════════════════════════════════════════════════════"
echo "Footers (Optional)"
echo "═══════════════════════════════════════════════════════"
echo "Examples: Fixes #123, Refs #456, Co-authored-by: Name <email>"
FOOTERS=()
read -p "Add footers? (y/N): " add_footers
if [[ "$add_footers" =~ ^[Yy]$ ]]; then
    echo "Enter footers (empty line to finish):"
    while IFS= read -r line; do
        [[ -z "$line" ]] && break
        FOOTERS+=("$line")
    done
fi
echo ""

# Prompt for breaking change
echo "═══════════════════════════════════════════════════════"
echo "Breaking Change (Optional)"
echo "═══════════════════════════════════════════════════════"
read -p "Is this a breaking change? (y/N): " is_breaking
BREAKING=""
BREAKING_INDICATOR=""
if [[ "$is_breaking" =~ ^[Yy]$ ]]; then
    BREAKING_INDICATOR="--breaking-indicator"
    echo "Enter breaking change description:"
    read -r BREAKING
fi
echo ""

# Build generate-message.sh command
CMD=("$SCRIPT_DIR/generate-message.sh" "$TYPE")

if [[ -n "$SCOPE" ]]; then
    CMD+=("$SCOPE")
fi

CMD+=("$DESCRIPTION")

if [[ -n "$BODY" ]]; then
    CMD+=("--body" "$BODY")
fi

for footer in "${FOOTERS[@]}"; do
    CMD+=("--footer" "$footer")
done

if [[ -n "$BREAKING" ]]; then
    CMD+=($BREAKING_INDICATOR "--breaking" "$BREAKING")
fi

# Generate message
MESSAGE=$("${CMD[@]}" 2>&1)

# Show preview
echo "═══════════════════════════════════════════════════════"
echo "Preview"
echo "═══════════════════════════════════════════════════════"
echo "$MESSAGE"
echo "═══════════════════════════════════════════════════════"
echo ""

# Save or preview only
if [[ "$PREVIEW_ONLY" == true ]]; then
    echo "Preview mode - not saving to file"
    exit 0
fi

# Confirm and save
read -p "Save to commit.txt? (Y/n): " confirm
if [[ ! "$confirm" =~ ^[Nn]$ ]]; then
    echo "$MESSAGE" > commit.txt
    echo "✓ Commit message saved to commit.txt"
    echo ""
    echo "To commit with this message:"
    echo "  git commit -F commit.txt"
    echo ""
    echo "Or copy the message manually and commit:"
    echo "  git commit"
else
    echo "Cancelled - message not saved"
fi
