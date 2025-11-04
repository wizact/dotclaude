# Ripgrep Search Skill - Complete Reference Guide

This comprehensive reference provides detailed examples, advanced techniques, and troubleshooting information for the ripgrep-search skill.

## Table of Contents

1. [Quick Reference](#quick-reference)
2. [Script Documentation](#script-documentation)
3. [Advanced Patterns](#advanced-patterns)
4. [Performance Optimization](#performance-optimization)
5. [Integration Examples](#integration-examples)
6. [Troubleshooting](#troubleshooting)
7. [Best Practices](#best-practices)

## Quick Reference

### Basic Commands
```bash
# Simple text search
rg "pattern"
rg "error" /var/log

# Case insensitive search
rg -i "Error"

# Whole word search
rg -w "function"

# Literal string (no regex)
rg -F "exact.string"

# File type filtering
rg "pattern" -t py
rg "pattern" -t js -t ts

# Context lines
rg "pattern" -C 3
rg "pattern" -A 2 -B 1
```

### Script Quick Start
```bash
# Search in source code
.claude/skills/ripgrep-search/scripts/search-code.sh "TODO" rust src/

# Search logs with filters
.claude/skills/ripgrep-search/scripts/search-logs.sh "error" /var/log --level=error

# Multiline patterns
.claude/skills/ripgrep-search/scripts/search-multiline.sh "function.*?\n.*return"

# Find and replace preview
.claude/skills/ripgrep-search/scripts/search-replace.sh "old_name" "new_name" --preview

# Search with context
.claude/skills/ripgrep-search/scripts/search-context.sh "pattern" 5

# Generate statistics
.claude/skills/ripgrep-search/scripts/search-stats.sh "TODO" --detailed
```

## Script Documentation

### 1. search-code.sh - Source Code Search

**Purpose**: Specialized search for source code with smart file type detection and developer-focused options.

**Syntax**: `search-code.sh <pattern> [file-type] [directory] [options]`

**Examples**:
```bash
# Basic function search
search-code.sh "function" js

# Search TODO comments in Rust code
search-code.sh "TODO|FIXME|HACK" rust --regex

# Find unsafe code patterns
search-code.sh "panic!|unwrap\(\)" rust --word

# Search with context for better understanding
search-code.sh "async fn" rust --context=2

# Count occurrences only
search-code.sh "console.log" js --count

# Export results to JSON for processing
search-code.sh "import" py --json > imports.json
```

**File Types Supported**:
- `rust` - .rs, .toml files
- `py` - .py, .pyx, .pyi files
- `js` - .js, .jsx, .mjs files
- `ts` - .ts, .tsx files
- `cpp` - .cpp, .cxx, .hpp, .hxx files
- `java` - .java files
- `go` - .go files
- `php` - .php files
- `rb` - .rb, .rake files

### 2. search-logs.sh - Log File Analysis

**Purpose**: Advanced log file searching with timestamp awareness and severity filtering.

**Syntax**: `search-logs.sh <pattern> [log-directory] [options]`

**Examples**:
```bash
# Basic error search
search-logs.sh "error" /var/log

# Search with minimum log level
search-logs.sh "timeout" --level=warn

# Recent logs only (if supported)
search-logs.sh "failed" --since="1 hour ago"

# Search compressed logs
search-logs.sh "exception" --include-archived

# Count errors per file
search-logs.sh "ERROR" --count

# Get files with critical issues
search-logs.sh "CRITICAL|FATAL" --files-only

# JSON output for processing
search-logs.sh "404" --json | jq '.data.lines.text'
```

**Log Levels**: debug < info < warn < error < fatal

### 3. search-multiline.sh - Multi-line Pattern Matching

**Purpose**: Search for patterns that span multiple lines using ripgrep's multiline mode.

**Syntax**: `search-multiline.sh <pattern> [directory] [options]`

**Examples**:
```bash
# Function definitions with bodies
search-multiline.sh "fn \w+\([^{]*\{[^}]*\}" --type=rust

# Try-catch blocks
search-multiline.sh "try\s*\{.*?\}\s*catch" --type=js

# Python class definitions with methods
search-multiline.sh "class \w+:.*?\n.*def" --type=py

# Multi-line comments
search-multiline.sh "/\*.*?\*/" --type=js

# Import statements
search-multiline.sh "import.*\nfrom.*import" --type=py

# Complex regex with PCRE2
search-multiline.sh "(?<=Error: )\w+" --pcre2

# Configuration blocks
search-multiline.sh "server\s*\{[^}]*\}" --glob="*.conf"
```

**Pattern Tips**:
- Use `.*?` for non-greedy matching
- Use `\s` for whitespace including newlines
- Use `[^}]*` to match until specific character
- Use `(?s)` flag for dotall mode in PCRE2

### 4. search-replace.sh - Find and Replace

**Purpose**: Safe find and replace operations with preview mode.

**Syntax**: `search-replace.sh <pattern> <replacement> [directory] [options]`

**Examples**:
```bash
# Preview replacement (default mode)
search-replace.sh "old_function" "new_function"

# Simple text replacement with backup
search-replace.sh "deprecated_api" "new_api" --apply --backup

# Regex replacement with capture groups
search-replace.sh "console\.log\(([^)]+)\)" "logger.info(\$1)" --apply

# Replace in specific file types
search-replace.sh "var " "let " --type=js --preview

# Case-sensitive replacement
search-replace.sh "Error" "Warning" --case-sensitive --apply

# Literal replacement (no regex)
search-replace.sh "special$chars" "normal_chars" --literal --apply

# Word boundary replacement
search-replace.sh "log" "logger" --word --preview
```

**Safety Features**:
- Preview mode by default
- Confirmation prompt for apply mode
- Backup file creation option
- Regex validation

### 5. search-context.sh - Context-Aware Search

**Purpose**: Search with configurable context lines and advanced display options.

**Syntax**: `search-context.sh <pattern> [context-lines] [directory] [options]`

**Examples**:
```bash
# Basic context search
search-context.sh "error" 3

# Different before/after context
search-context.sh "function" 5 --before=2 --after=3

# No context (line only)
search-context.sh "import" 0 --type=py

# Show all lines with highlights
search-context.sh "TODO" 0 --passthru

# Custom separator between groups
search-context.sh "class" 2 --separator="---"

# Include hidden files
search-context.sh "secret" 1 --hidden

# Limit file size
search-context.sh "pattern" 2 --max-filesize=1M

# Show statistics
search-context.sh "function" 1 --stats --type=rust
```

### 6. search-stats.sh - Statistics and Reports

**Purpose**: Generate comprehensive search statistics and analysis reports.

**Syntax**: `search-stats.sh <pattern> [directory] [options]`

**Examples**:
```bash
# Basic statistics summary
search-stats.sh "TODO"

# Detailed file breakdown
search-stats.sh "error" --detailed

# Group by file extension
search-stats.sh "import" --by-extension

# Top files with most matches
search-stats.sh "console.log" --top-files=10

# Directory-based statistics
search-stats.sh "function" --by-directory

# Timeline analysis
search-stats.sh "bug" --timeline

# With sample matches
search-stats.sh "error" --detailed --sample-matches=3

# Performance analysis
search-stats.sh "pattern" --performance

# CSV output for spreadsheets
search-stats.sh "TODO" --csv > todo_stats.csv
```

## Advanced Patterns

### Regular Expression Examples

**Character Classes**:
```bash
# Digits
rg "\d+"                    # One or more digits
rg "\d{3}-\d{3}-\d{4}"     # Phone number format

# Word characters
rg "\w+"                    # Word characters
rg "[A-Za-z_]\w*"          # Valid identifier

# Whitespace
rg "\s+"                    # Any whitespace
rg "[ \t]+"                # Spaces and tabs only
```

**Anchors and Boundaries**:
```bash
# Line anchors
rg "^ERROR"                 # Lines starting with ERROR
rg "failed$"               # Lines ending with failed

# Word boundaries
rg "\bclass\b"             # Whole word 'class'
rg "\bfn\s+\w+"           # Function definitions
```

**Quantifiers**:
```bash
# Greedy vs non-greedy
rg "<!--.*-->"             # Greedy (matches longest)
rg "<!--.*?-->"            # Non-greedy (matches shortest)

# Specific counts
rg "\w{3,10}"              # 3 to 10 word characters
rg "a{5}"                  # Exactly 5 'a' characters
```

### PCRE2 Advanced Features

**Lookahead and Lookbehind**:
```bash
# Positive lookahead
rg -P "function(?=\s*\()"          # 'function' followed by '('

# Negative lookahead
rg -P "import(?!\s+\*)"            # 'import' not followed by ' *'

# Positive lookbehind
rg -P "(?<=Error:\s)\w+"           # Word after 'Error: '

# Negative lookbehind
rg -P "(?<!test_)\w+\.py"          # .py files not prefixed with test_
```

**Named Groups**:
```bash
# Define named groups
rg -P "(?P<func>\w+)\s*\((?P<args>[^)]*)\)" --replace "Function: $func, Args: $args"
```

### Multiline Patterns

**Function Definitions**:
```bash
# Simple functions
rg -U "fn \w+\([^{]*\{[^}]*\}"

# Complex functions with error handling
rg -U "fn \w+.*?\{[^}]*(?:Result|Option)[^}]*\}"

# Python class methods
rg -U "class \w+:.*?\n\s*def \w+"
```

**Configuration Blocks**:
```bash
# Server blocks in nginx
rg -U "server\s*\{[^}]*listen[^}]*\}"

# JSON objects with specific fields
rg -U '\{[^}]*"error"[^}]*\}'
```

## Performance Optimization

### File Type Filtering
```bash
# Use specific types instead of globs
rg "pattern" -t py          # Faster
rg "pattern" -g "*.py"      # Slower

# Multiple types
rg "pattern" -t py -t js -t rust  # Efficient
```

### Directory Limiting
```bash
# Limit search depth
rg "pattern" --max-depth 3

# Exclude large directories
rg "pattern" -g "!node_modules" -g "!target"

# Search specific directories only
rg "pattern" src/ tests/
```

### Memory Management
```bash
# Force memory mapping for large files
rg "pattern" --mmap

# Limit file size to avoid huge files
rg "pattern" --max-filesize 10M

# Control parallel processing
rg "pattern" -j 4           # Use 4 threads
```

### Pattern Optimization
```bash
# Use literal search when possible
rg -F "exact.string"        # Faster than regex

# Use word boundaries
rg -w "function"            # Faster than "\bfunction\b"

# Limit matches per file
rg "pattern" --max-count 5  # Stop after 5 matches per file
```

## Integration Examples

### With Shell Scripts
```bash
#!/bin/bash
# Find files with TODOs and open in editor
files=$(rg -l "TODO" --type py)
if [[ -n "$files" ]]; then
    echo "$files" | xargs code
fi

# Count different types of comments
echo "TODOs: $(rg -c "TODO" --type py | awk -F: '{sum += $2} END {print sum}')"
echo "FIXMEs: $(rg -c "FIXME" --type py | awk -F: '{sum += $2} END {print sum}')"
```

### With JSON Processing
```bash
# Extract error messages to JSON
rg "error" --json /var/log | jq -r '.data.lines.text'

# Count matches by file
rg "pattern" --json | jq -r 'select(.type=="match") | .data.path.text' | sort | uniq -c
```

### With Git Workflows
```bash
# Search only tracked files
git ls-files | rg --files-from - "pattern"

# Search in modified files only
rg "pattern" $(git diff --name-only)

# Search in specific commit
git show HEAD:file.py | rg "pattern"
```

### Pipeline Integration
```bash
# Find and process matches
rg "error" -l | while read file; do
    echo "Processing errors in $file"
    rg "error" "$file" -C 2
done

# Complex filtering pipeline
rg "function" --json | \
jq -r 'select(.type=="match") | .data' | \
jq -r '"\(.path.text):\(.line_number):\(.lines.text)"'
```

## Troubleshooting

### Common Issues

**Pattern Not Found**:
```bash
# Check case sensitivity
rg -i "pattern"             # Case insensitive

# Check if pattern is being interpreted as regex
rg -F "pattern"             # Literal search

# Check hidden files
rg --hidden "pattern"       # Include hidden files

# Check ignored files
rg --no-ignore "pattern"    # Ignore .gitignore rules
```

**Performance Issues**:
```bash
# Limit search scope
rg "pattern" --max-depth 2
rg "pattern" --max-filesize 1M

# Use file type filters
rg "pattern" -t py          # Instead of searching all files

# Check if pattern is too broad
rg -c "pattern"             # Count first
```

**Regex Issues**:
```bash
# Escape special characters
rg "file\.txt"              # Literal dot
rg "price\$"                # Literal dollar sign

# Use raw strings in shell
rg 'pattern\with\backslashes'

# Test regex with simple cases first
rg "simple" | head -5       # Test basic search first
```

**Output Issues**:
```bash
# Force color output
rg "pattern" --color always

# Control line numbers
rg "pattern" -n             # Show line numbers
rg "pattern" --no-line-number  # Hide line numbers

# Handle binary files
rg "pattern" --text         # Force text mode
rg "pattern" -a             # Search binary files as text
```

### Debugging Commands

**Check Configuration**:
```bash
# List available file types
rg --type-list

# Show current configuration
rg --debug "pattern" 2>&1 | head -10

# Test pattern matching
echo "test string" | rg "pattern"
```

**Performance Analysis**:
```bash
# Show statistics
rg --stats "pattern"

# Time the search
time rg "pattern"

# Show files being searched
rg --debug "pattern" 2>&1 | grep "searching"
```

## Best Practices

### Pattern Design
1. **Start simple**: Begin with literal searches, add regex complexity as needed
2. **Use appropriate anchors**: `^` for line start, `$` for line end, `\b` for word boundaries
3. **Test patterns**: Validate regex patterns on small datasets first
4. **Consider performance**: Literal searches are faster than complex regex

### File Filtering
1. **Use file types**: `-t py` is more efficient than `-g "*.py"`
2. **Exclude irrelevant directories**: Use `-g "!node_modules"` for better performance
3. **Limit scope**: Use `--max-depth` in large directory trees
4. **Filter by size**: Use `--max-filesize` to skip huge files

### Output Management
1. **Use context appropriately**: More context provides better understanding but larger output
2. **Consider JSON output**: For programmatic processing, use `--json`
3. **Limit results**: Use `--max-count` for exploratory searches
4. **Use color**: Enable color for better visual parsing

### Script Usage
1. **Combine scripts**: Use multiple scripts in pipelines for complex workflows
2. **Save common patterns**: Create aliases for frequently used search patterns
3. **Document custom patterns**: Comment complex regex patterns for future reference
4. **Test before applying**: Always preview replacements before applying changes

### Integration Guidelines
1. **Error handling**: Check ripgrep exit codes in scripts
2. **Input validation**: Validate patterns and file paths in automation
3. **Performance monitoring**: Monitor search times for large codebases
4. **Version compatibility**: Test with your specific ripgrep version

This reference guide covers the essential aspects of using the ripgrep-search skill effectively. For the most up-to-date information, always refer to `rg --help` and the official ripgrep documentation.