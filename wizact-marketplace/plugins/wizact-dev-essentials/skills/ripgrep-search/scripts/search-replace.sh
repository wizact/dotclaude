#!/bin/bash

# Find and replace patterns with preview using ripgrep
# Usage: search-replace.sh <pattern> <replacement> [directory] [options]

set -e

show_help() {
    cat << EOF
Find and replace patterns with preview using ripgrep

Usage: $0 <pattern> <replacement> [directory] [options]

Arguments:
    pattern       The pattern to search for (required)
    replacement   The replacement text (required)
    directory     Directory to search in (default: current directory)

Examples:
    $0 "old_name" "new_name"                    # Simple text replacement
    $0 "function (\w+)" "fn \$1"                # Regex with capture groups
    $0 "TODO" "DONE" --type=py                  # Replace in Python files only
    $0 "console.log" "logger.info" --preview    # Show changes without applying

Replacement Patterns:
    Literal text:       "new_text"
    Capture groups:     "\$1", "\$2", etc. (use single quotes or escape \$)
    Named groups:       "\$name" (when using named captures)
    Full match:         "\$0"

Options:
    --help, -h              Show this help message
    --preview, -p           Show what would be replaced (default mode)
    --apply, -a             Actually perform the replacement
    --backup, -b            Create backup files before replacement (.bak)
    --type=TYPE, -t TYPE    Limit to specific file type
    --glob=PATTERN, -g      Include files matching glob pattern
    --case-sensitive        Force case-sensitive search
    --literal, -F           Use literal/fixed string mode
    --word, -w              Match whole words only
    --context=N, -C N       Show N lines of context around matches
    --max-files=N           Limit number of files to process
    --exclude-glob=PATTERN  Exclude files matching pattern
    --dry-run               Same as --preview

Regex Capture Examples:
    Pattern: "(\w+)_old"  Replacement: "\$1_new"     # prefix_old -> prefix_new
    Pattern: "fn (\w+)"   Replacement: "function \$1" # fn name -> function name
    Pattern: "(\d+)-(\d+)" Replacement: "\$2-\$1"     # 123-456 -> 456-123

Safety Features:
    - Preview mode is default (no changes made)
    - Use --apply to actually perform replacements
    - Use --backup to create .bak files before changes
    - Respects .gitignore by default
EOF
}

# Default values
PATTERN=""
REPLACEMENT=""
DIRECTORY="."
PREVIEW_MODE=true
CREATE_BACKUP=false
FILE_TYPE=""
GLOB_PATTERN=""
EXCLUDE_GLOB=""
CASE_SENSITIVE=false
LITERAL_MODE=false
WORD_MATCH=false
CONTEXT="0"
MAX_FILES=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            exit 0
            ;;
        --preview|-p|--dry-run)
            PREVIEW_MODE=true
            shift
            ;;
        --apply|-a)
            PREVIEW_MODE=false
            shift
            ;;
        --backup|-b)
            CREATE_BACKUP=true
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
        --exclude-glob=*)
            EXCLUDE_GLOB="${1#*=}"
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
        --word|-w)
            WORD_MATCH=true
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
        --max-files=*)
            MAX_FILES="${1#*=}"
            shift
            ;;
        -*)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
        *)
            if [[ -z "$PATTERN" ]]; then
                PATTERN="$1"
            elif [[ -z "$REPLACEMENT" ]]; then
                REPLACEMENT="$1"
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

if [[ -z "$REPLACEMENT" ]]; then
    echo "Error: Replacement text is required" >&2
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

# Function to show preview
show_preview() {
    echo "=== PREVIEW MODE ===" >&2
    echo "Pattern: $PATTERN" >&2
    echo "Replacement: $REPLACEMENT" >&2
    echo "Directory: $DIRECTORY" >&2
    echo "" >&2

    # Build ripgrep command for preview
    local RG_CMD=("rg" "--replace" "$REPLACEMENT")

    # Add pattern
    RG_CMD+=("$PATTERN")

    # Add options
    if [[ -n "$FILE_TYPE" ]]; then
        RG_CMD+=("-t" "$FILE_TYPE")
    fi

    if [[ -n "$GLOB_PATTERN" ]]; then
        RG_CMD+=("-g" "$GLOB_PATTERN")
    fi

    if [[ -n "$EXCLUDE_GLOB" ]]; then
        RG_CMD+=("-g" "!$EXCLUDE_GLOB")
    fi

    if [[ "$CASE_SENSITIVE" == true ]]; then
        RG_CMD+=("-s")
    fi

    if [[ "$LITERAL_MODE" == true ]]; then
        RG_CMD+=("-F")
    fi

    if [[ "$WORD_MATCH" == true ]]; then
        RG_CMD+=("-w")
    fi

    # Add context and formatting
    RG_CMD+=("-C" "$CONTEXT" "-n" "--color=always")

    # Add directory
    RG_CMD+=("$DIRECTORY")

    # Execute preview
    "${RG_CMD[@]}" || {
        echo "No matches found for pattern: $PATTERN" >&2
        return 1
    }

    echo "" >&2
    echo "Use --apply to perform actual replacement" >&2
    echo "Use --backup to create backup files before replacement" >&2
}

# Function to perform actual replacement
perform_replacement() {
    echo "=== APPLYING REPLACEMENTS ===" >&2
    echo "Pattern: $PATTERN" >&2
    echo "Replacement: $REPLACEMENT" >&2
    echo "Directory: $DIRECTORY" >&2
    echo "" >&2

    # Get list of files that contain the pattern
    local RG_CMD=("rg" "-l")

    # Add pattern
    RG_CMD+=("$PATTERN")

    # Add options
    if [[ -n "$FILE_TYPE" ]]; then
        RG_CMD+=("-t" "$FILE_TYPE")
    fi

    if [[ -n "$GLOB_PATTERN" ]]; then
        RG_CMD+=("-g" "$GLOB_PATTERN")
    fi

    if [[ -n "$EXCLUDE_GLOB" ]]; then
        RG_CMD+=("-g" "!$EXCLUDE_GLOB")
    fi

    if [[ "$CASE_SENSITIVE" == true ]]; then
        RG_CMD+=("-s")
    fi

    if [[ "$LITERAL_MODE" == true ]]; then
        RG_CMD+=("-F")
    fi

    if [[ "$WORD_MATCH" == true ]]; then
        RG_CMD+=("-w")
    fi

    # Add directory
    RG_CMD+=("$DIRECTORY")

    # Get files to process
    local files
    if ! files=$("${RG_CMD[@]}" 2>/dev/null); then
        echo "No files found containing the pattern" >&2
        return 1
    fi

    # Limit files if requested
    if [[ -n "$MAX_FILES" ]]; then
        files=$(echo "$files" | head -n "$MAX_FILES")
    fi

    local count=0
    local total=$(echo "$files" | wc -l)

    echo "Found $total file(s) to process:" >&2

    # Process each file
    while IFS= read -r file; do
        [[ -z "$file" ]] && continue

        count=$((count + 1))
        echo "[$count/$total] Processing: $file" >&2

        # Create backup if requested
        if [[ "$CREATE_BACKUP" == true ]]; then
            cp "$file" "$file.bak"
            echo "  Created backup: $file.bak" >&2
        fi

        # Perform replacement using sed or perl
        if [[ "$LITERAL_MODE" == true ]]; then
            # Use sed for literal replacement
            if command -v gsed &> /dev/null; then
                gsed -i "s/$(printf '%s\n' "$PATTERN" | sed 's/[[\.*^$()+?{|]/\\&/g')/$(printf '%s\n' "$REPLACEMENT" | sed 's/[[\.*^$(){}|/]/\\&/g')/g" "$file"
            else
                sed -i.tmp "s/$(printf '%s\n' "$PATTERN" | sed 's/[[\.*^$()+?{|]/\\&/g')/$(printf '%s\n' "$REPLACEMENT" | sed 's/[[\.*^$(){}|/]/\\&/g')/g" "$file" && rm "$file.tmp"
            fi
        else
            # Use perl for regex replacement
            if command -v perl &> /dev/null; then
                local perl_flags=""
                if [[ "$CASE_SENSITIVE" != true ]]; then
                    perl_flags="i"
                fi
                if [[ "$WORD_MATCH" == true ]]; then
                    PATTERN="\\b$PATTERN\\b"
                fi
                perl -i -pe "s/$PATTERN/$REPLACEMENT/g$perl_flags" "$file"
            else
                echo "  Warning: perl not available, skipping regex replacement for $file" >&2
                continue
            fi
        fi

        echo "  Replacement completed" >&2
    done <<< "$files"

    echo "" >&2
    echo "Replacement completed for $count file(s)" >&2
    if [[ "$CREATE_BACKUP" == true ]]; then
        echo "Backup files created with .bak extension" >&2
    fi
}

# Main execution
if [[ "$PREVIEW_MODE" == true ]]; then
    show_preview
else
    # Confirm before applying changes
    echo "About to replace '$PATTERN' with '$REPLACEMENT' in $DIRECTORY" >&2
    if [[ "$CREATE_BACKUP" == true ]]; then
        echo "Backup files will be created" >&2
    fi
    read -p "Continue? [y/N] " -n 1 -r >&2
    echo >&2
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        perform_replacement
    else
        echo "Operation cancelled" >&2
        exit 1
    fi
fi