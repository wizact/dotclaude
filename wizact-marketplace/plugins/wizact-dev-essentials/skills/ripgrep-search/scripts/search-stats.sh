#!/bin/bash

# Generate search statistics and reports using ripgrep
# Usage: search-stats.sh <pattern> [directory] [options]

set -e

show_help() {
    cat << EOF
Generate comprehensive search statistics and reports using ripgrep

Usage: $0 <pattern> [directory] [options]

Arguments:
    pattern     The pattern to search for (required)
    directory   Directory to search in (default: current directory)

Examples:
    $0 "TODO"                           # Basic TODO statistics
    $0 "error" --type=log               # Error statistics in log files
    $0 "function" --detailed            # Detailed function analysis
    $0 "import" --by-extension          # Group results by file extension
    $0 "console.log" --top-files=10     # Top 10 files with console.log

Report Types:
    --summary           Basic statistics summary (default)
    --detailed          Detailed statistics with file breakdown
    --by-extension      Group statistics by file extension
    --by-directory      Group statistics by directory
    --top-files=N       Show top N files with most matches
    --timeline          Group by file modification time (if available)

Options:
    --help, -h              Show this help message
    --type=TYPE, -t TYPE    Limit to specific file type
    --glob=PATTERN, -g      Include files matching glob pattern
    --case-sensitive        Force case-sensitive search
    --literal, -F           Use literal/fixed string mode
    --word, -w              Match whole words only
    --json                  Output in JSON format
    --csv                   Output in CSV format
    --include-hidden        Include hidden files
    --max-depth=N           Limit directory recursion depth
    --min-matches=N         Only show files with at least N matches
    --sort=FIELD            Sort by: matches, files, lines (default: matches)

Advanced Options:
    --context=N             Include context for sample matches
    --sample-matches=N      Show N sample matches per file
    --exclude-dirs=PATTERN  Exclude directories matching pattern
    --size-stats            Include file size statistics
    --performance           Show performance timing information
EOF
}

# Default values
PATTERN=""
DIRECTORY="."
REPORT_TYPE="summary"
FILE_TYPE=""
GLOB_PATTERN=""
CASE_SENSITIVE=false
LITERAL_MODE=false
WORD_MATCH=false
JSON_OUTPUT=false
CSV_OUTPUT=false
INCLUDE_HIDDEN=false
MAX_DEPTH=""
MIN_MATCHES="1"
SORT_FIELD="matches"
CONTEXT=""
SAMPLE_MATCHES=""
EXCLUDE_DIRS=""
SIZE_STATS=false
PERFORMANCE=false
TOP_FILES_COUNT=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --help|-h)
            show_help
            exit 0
            ;;
        --summary)
            REPORT_TYPE="summary"
            shift
            ;;
        --detailed)
            REPORT_TYPE="detailed"
            shift
            ;;
        --by-extension)
            REPORT_TYPE="by-extension"
            shift
            ;;
        --by-directory)
            REPORT_TYPE="by-directory"
            shift
            ;;
        --top-files=*)
            REPORT_TYPE="top-files"
            TOP_FILES_COUNT="${1#*=}"
            shift
            ;;
        --timeline)
            REPORT_TYPE="timeline"
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
        --json)
            JSON_OUTPUT=true
            shift
            ;;
        --csv)
            CSV_OUTPUT=true
            shift
            ;;
        --include-hidden)
            INCLUDE_HIDDEN=true
            shift
            ;;
        --max-depth=*)
            MAX_DEPTH="${1#*=}"
            shift
            ;;
        --min-matches=*)
            MIN_MATCHES="${1#*=}"
            shift
            ;;
        --sort=*)
            SORT_FIELD="${1#*=}"
            shift
            ;;
        --context=*)
            CONTEXT="${1#*=}"
            shift
            ;;
        --sample-matches=*)
            SAMPLE_MATCHES="${1#*=}"
            shift
            ;;
        --exclude-dirs=*)
            EXCLUDE_DIRS="${1#*=}"
            shift
            ;;
        --size-stats)
            SIZE_STATS=true
            shift
            ;;
        --performance)
            PERFORMANCE=true
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

# Function to build base ripgrep command
build_base_command() {
    local RG_CMD=("rg")

    # Add pattern
    RG_CMD+=("$PATTERN")

    # Add file type if specified
    if [[ -n "$FILE_TYPE" ]]; then
        RG_CMD+=("-t" "$FILE_TYPE")
    fi

    # Add glob pattern if specified
    if [[ -n "$GLOB_PATTERN" ]]; then
        RG_CMD+=("-g" "$GLOB_PATTERN")
    fi

    # Add exclude directories if specified
    if [[ -n "$EXCLUDE_DIRS" ]]; then
        RG_CMD+=("-g" "!$EXCLUDE_DIRS")
    fi

    # Add case sensitivity
    if [[ "$CASE_SENSITIVE" == true ]]; then
        RG_CMD+=("-s")
    fi

    # Add literal mode if requested
    if [[ "$LITERAL_MODE" == true ]]; then
        RG_CMD+=("-F")
    fi

    # Add word match if requested
    if [[ "$WORD_MATCH" == true ]]; then
        RG_CMD+=("-w")
    fi

    # Add hidden files if requested
    if [[ "$INCLUDE_HIDDEN" == true ]]; then
        RG_CMD+=("--hidden")
    fi

    # Add max depth if specified
    if [[ -n "$MAX_DEPTH" ]]; then
        RG_CMD+=("--max-depth" "$MAX_DEPTH")
    fi

    # Add directory
    RG_CMD+=("$DIRECTORY")

    echo "${RG_CMD[@]}"
}

# Function to get match counts per file
get_file_counts() {
    local base_cmd
    base_cmd=($(build_base_command))
    "${base_cmd[@]}" -c | grep -v ":0$" | sort -t: -k2 -nr
}

# Function to get total statistics
get_total_stats() {
    local base_cmd
    base_cmd=($(build_base_command))

    local total_matches total_files
    total_matches=$("${base_cmd[@]}" --count-matches | awk '{sum += $1} END {print sum}')
    total_files=$("${base_cmd[@]}" -l | wc -l)

    echo "$total_matches $total_files"
}

# Start timing if performance mode
if [[ "$PERFORMANCE" == true ]]; then
    START_TIME=$(date +%s.%N)
fi

# Generate the appropriate report
case "$REPORT_TYPE" in
    "summary")
        echo "=== Search Statistics Summary ==="
        echo "Pattern: $PATTERN"
        echo "Directory: $DIRECTORY"
        if [[ -n "$FILE_TYPE" ]]; then
            echo "File Type: $FILE_TYPE"
        fi
        echo ""

        read -r total_matches total_files <<< "$(get_total_stats)"

        echo "Total Matches: $total_matches"
        echo "Files with Matches: $total_files"
        if [[ $total_files -gt 0 ]]; then
            echo "Average Matches per File: $((total_matches / total_files))"
        fi

        echo ""
        echo "Top 5 Files with Most Matches:"
        get_file_counts | head -5 | while IFS=: read -r file count; do
            echo "  $count matches: $file"
        done
        ;;

    "detailed")
        echo "=== Detailed Search Statistics ==="
        echo "Pattern: $PATTERN"
        echo "Directory: $DIRECTORY"
        echo ""

        get_file_counts | while IFS=: read -r file count; do
            if [[ $count -ge $MIN_MATCHES ]]; then
                echo "File: $file"
                echo "Matches: $count"

                if [[ "$SIZE_STATS" == true && -f "$file" ]]; then
                    echo "Size: $(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null) bytes"
                fi

                if [[ -n "$SAMPLE_MATCHES" ]]; then
                    echo "Sample matches:"
                    local base_cmd
                    base_cmd=($(build_base_command))
                    "${base_cmd[@]}" -n --max-count="$SAMPLE_MATCHES" "$file" | head -"$SAMPLE_MATCHES" | sed 's/^/  /'
                fi
                echo ""
            fi
        done
        ;;

    "by-extension")
        echo "=== Statistics by File Extension ==="
        echo "Pattern: $PATTERN"
        echo ""

        declare -A ext_stats
        get_file_counts | while IFS=: read -r file count; do
            ext="${file##*.}"
            [[ "$ext" == "$file" ]] && ext="(no extension)"
            echo "$ext:$count"
        done | sort | awk -F: '
        {
            ext = $1
            count = $2
            stats[ext] += count
            files[ext]++
        }
        END {
            for (ext in stats) {
                printf "%-20s %d matches in %d files\n", ext, stats[ext], files[ext]
            }
        }' | sort -k2 -nr
        ;;

    "by-directory")
        echo "=== Statistics by Directory ==="
        echo "Pattern: $PATTERN"
        echo ""

        get_file_counts | while IFS=: read -r file count; do
            dir=$(dirname "$file")
            echo "$dir:$count"
        done | sort | awk -F: '
        {
            dir = $1
            count = $2
            stats[dir] += count
            files[dir]++
        }
        END {
            for (dir in stats) {
                printf "%-50s %d matches in %d files\n", dir, stats[dir], files[dir]
            }
        }' | sort -k2 -nr
        ;;

    "top-files")
        local limit=${TOP_FILES_COUNT:-10}
        echo "=== Top $limit Files with Most Matches ==="
        echo "Pattern: $PATTERN"
        echo ""

        get_file_counts | head -"$limit" | while IFS=: read -r file count; do
            echo "$count matches: $file"

            if [[ -n "$CONTEXT" ]]; then
                echo "  Sample with context:"
                local base_cmd
                base_cmd=($(build_base_command))
                "${base_cmd[@]}" -C "$CONTEXT" --max-count=1 "$file" | sed 's/^/    /'
                echo ""
            fi
        done
        ;;

    "timeline")
        echo "=== Timeline Analysis ==="
        echo "Pattern: $PATTERN"
        echo ""

        get_file_counts | while IFS=: read -r file count; do
            if [[ -f "$file" ]]; then
                mod_time=$(stat -f%m "$file" 2>/dev/null || stat -c%Y "$file" 2>/dev/null)
                mod_date=$(date -r "$mod_time" "+%Y-%m-%d" 2>/dev/null || date -d "@$mod_time" "+%Y-%m-%d" 2>/dev/null)
                echo "$mod_date:$count:$file"
            fi
        done | sort | awk -F: '
        {
            date = $1
            count = $2
            file = $3
            stats[date] += count
            files[date]++
        }
        END {
            for (date in stats) {
                printf "%s: %d matches in %d files\n", date, stats[date], files[date]
            }
        }' | sort
        ;;
esac

# Show performance timing if requested
if [[ "$PERFORMANCE" == true ]]; then
    END_TIME=$(date +%s.%N)
    DURATION=$(echo "$END_TIME - $START_TIME" | bc)
    echo ""
    echo "Performance: Search completed in ${DURATION}s"
fi