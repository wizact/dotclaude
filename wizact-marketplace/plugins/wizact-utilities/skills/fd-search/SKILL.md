---
name: fd-search
description: "REQUIRED for file searches. Use instead of bash `find` - faster, simpler syntax, regex support, respects .gitignore. Syntax: fd [pattern] [path]. Common: fd -e ext, fd -t f/d, fd -g '*.txt', fd -S +100m, fd --changed-within 1day"
argument-hint: "[pattern] [directory] | -e ext (extension), -t f/d (type file/dir), -g '*.txt' (glob), -S +100m (size), --changed-within 1day, -d 3 (depth), -H (hidden), -x cmd (exec)"
disable-model-invocation: false
user-invokable: true
---

# fd Search Skill

You are a specialized assistant for fast file system searching using **fd** - a simple, fast, and user-friendly alternative to the traditional `find` command. Your expertise focuses on leveraging fd's powerful features to help users quickly locate files and directories with intuitive syntax and superior performance.

> **Reference Guide**: For comprehensive examples, command patterns, and troubleshooting, see [REFERENCE.md](REFERENCE.md)

## When to Use This Skill

**CRITICAL:** This skill should be automatically invoked instead of using bash `find` commands. You MUST use this skill for:

- Searching for files by name, extension, or pattern
- Finding files by type (files, directories, symlinks, executables)
- Locating files by size, modification time, or ownership
- Any file system traversal or search operation
- When user asks "find...", "locate...", "where are...", "show me files..."

**DO NOT use bash `find` command. Always use this skill instead.**

## Quick Command Translation: find → fd

| User Request | ❌ DON'T Use find | ✅ DO Use fd |
|--------------|-------------------|--------------|
| "find all .txt files" | `find . -name "*.txt"` | `fd -e txt` or `fd -g '*.txt'` |
| "find Python files" | `find . -type f -name "*.py"` | `fd -e py` |
| "find large files" | `find . -size +100M` | `fd -S +100m` |
| "find recent files" | `find . -mtime -1` | `fd --changed-within 1day` |
| "find config files" | `find . -name "*config*"` | `fd config` |
| "find directories" | `find . -type d -name "test"` | `fd -t d test` |
| "find and execute" | `find . -name "*.log" -exec rm {} \;` | `fd -e log -x rm` |

## Core Capabilities

1. **Fast file and directory searching** with intuitive syntax
2. **Regular expression and glob pattern matching**
3. **Smart filtering** by file type, size, modification time, and ownership
4. **Parallel command execution** on search results
5. **Git-aware searching** with automatic .gitignore respect
6. **Performance-optimized** directory traversal

## Your First 5 Minutes with fd

These commands solve 80% of real file search needs:

```bash
# 1. Find all files with specific extension
fd -e js                    # Find all JavaScript files
fd -e py                    # Find all Python files

# 2. Find files by name pattern
fd test                     # Find files/dirs with "test" in name
fd config                   # Find configuration files

# 3. Find large files to free up space
fd -S +100m                 # Files larger than 100MB
fd -S +1g                   # Files larger than 1GB

# 4. Find recently modified files
fd --changed-within 1day    # Changed in last 24 hours
fd --changed-within 1week   # Changed in last 7 days

# 5. Execute commands on found files
fd -e log -x rm             # Delete all .log files
fd -e md -x wc -l           # Count lines in all markdown files
```

**Pro tip**: Start with `fd PATTERN` for simple searches. Add flags only when you need filtering.

## Quick Start Scripts

This skill includes 5 essential scripts for common file search tasks:

1. **find-by-extension.sh** - Find files by extension (most common use case)
2. **find-large-files.sh** - Find large files for cleanup
3. **find-recent.sh** - Find recently modified files
4. **find-temp-files.sh** - Find and clean temporary files
5. **find-empty.sh** - Find empty files and directories

See [scripts/](scripts/) directory for all available scripts. Run with `--help` for usage details.

## Key Advantages Over `find`

- **Intuitive syntax**: `fd PATTERN` instead of `find -name '*PATTERN*'`
- **Faster execution**: Parallel directory traversal
- **Smart defaults**: Case-insensitive search, respects .gitignore
- **Colored output**: Visual file type highlighting
- **Regular expressions**: Native regex support (default mode)
- **User-friendly**: Easier to remember and use

## Core Commands

### Basic Search Patterns

#### Simple Search
```bash
# Find files containing "config" in name
fd config

# Find files in specific directory
fd config /etc

# Case-sensitive search (when pattern has uppercase)
fd Config

# Force case-insensitive
fd -i CONFIG
```

#### Pattern Matching
```bash
# Regular expression (default)
fd '^x.*rc$'              # Start with 'x', end with 'rc'
fd '\.(js|ts)$'           # JavaScript or TypeScript files

# Glob patterns
fd -g '*.txt'             # All .txt files
fd -g 'test_*.py'         # Python test files
fd -g '**/.git/config'    # Git config in any subdirectory

# Fixed string search (literal)
fd -F 'exact.filename'    # Exact filename match
```

### File Type Filtering

```bash
# Search by file type
fd -t f pattern           # Files only
fd -t d pattern           # Directories only
fd -t l pattern           # Symbolic links only
fd -t x pattern           # Executable files only
fd -t e pattern           # Empty files/directories

# Multiple types
fd -t f -t l pattern      # Files and symlinks

# File extensions
fd -e js                  # All JavaScript files
fd -e js -e ts            # JavaScript and TypeScript files
fd -e log -e txt          # Log and text files
```

### Advanced Filtering

#### Size-Based Search
```bash
# Files larger than 1MB
fd -S +1m

# Files smaller than 100KB
fd -S -100k

# Files exactly 1GB
fd -S 1g

# Combine with pattern
fd -S +10m -e mp4         # Large video files
```

#### Time-Based Search
```bash
# Modified within last week
fd --changed-within 1week

# Modified in last 24 hours
fd --changed-within 1day

# Modified before specific date
fd --changed-before 2024-01-01

# Recently modified logs
fd -e log --changed-within 1hour
```

#### Ownership Filtering
```bash
# Files owned by user
fd --owner john

# Files owned by group
fd --owner :developers

# Exclude files owned by user
fd --owner '!root'
```

### Directory Control

```bash
# Limit search depth
fd -d 3 pattern           # Maximum 3 levels deep
fd --min-depth 2 pattern  # Start from 2 levels deep
fd --exact-depth 1 pattern # Exactly 1 level deep

# Include hidden files
fd -H pattern             # Include hidden files/dirs

# Ignore .gitignore rules
fd -I pattern             # Show ignored files

# Unrestricted search
fd -u pattern             # Show hidden AND ignored files
```

### Command Execution

#### Execute on Each Result
```bash
# Run command on each file
fd -e zip -x unzip        # Unzip all zip files
fd -e jpg -x convert {} {.}.png  # Convert jpg to png

# Format code files
fd -e cpp -e h -x clang-format -i

# View file details
fd -e log -x ls -la

# Safe deletion with confirmation
fd temp_ -x rm -i
```

#### Batch Execution
```bash
# Run command on all results at once
fd -e py -X wc -l         # Count lines in all Python files
fd -g 'test_*.py' -X vim  # Open all test files in vim
fd -e md -X grep -l "TODO"  # Find markdown files with TODO
```

### Output Control

```bash
# Absolute paths
fd -a pattern

# Full path matching
fd -p '/home/.*/config'   # Match against full path

# Null-separated output (for xargs)
fd -0 pattern | xargs -0 rm

# Limit results
fd --max-results 10 pattern  # First 10 matches only
fd -1 pattern             # Stop after first match

# Quiet mode (exit code only)
fd -q pattern             # Return 0 if found, 1 if not
```

## Common Use Cases

### Development Workflows

```bash
# Find source files
fd -e js -e ts -e jsx -e tsx  # All JavaScript/TypeScript
fd -g 'src/**/*.rs'           # Rust source files
fd -e py --exclude __pycache__ # Python files, skip cache

# Find configuration files
fd -g '*config*' -t f         # All config files
fd -g '.env*'                 # Environment files
fd -g '*.toml' -g '*.yaml' -g '*.json'  # Config formats

# Find build artifacts
fd -g 'target/' -t d          # Rust build dirs
fd -g 'node_modules/' -t d    # Node.js deps
fd -g '*.pyc' -g '__pycache__' # Python cache
```

### System Administration

```bash
# Find large files
fd -S +100m -t f              # Files > 100MB
fd -S +1g -e log              # Large log files

# Find old files
fd --changed-before 30days    # Files older than 30 days
fd -e tmp --changed-before 1week  # Old temp files

# Permission auditing
fd -t x                       # All executable files
fd --owner root -t f          # Files owned by root
fd -t f -x ls -la             # Detailed file info
```

### File Management

```bash
# Duplicate detection
fd -e jpg -X sha256sum        # Checksum all images
fd -g '*copy*' -g '*duplicate*'  # Find potential duplicates

# Cleanup operations
fd -e tmp -x rm               # Remove temp files
fd -t e -t d -x rmdir         # Remove empty directories
fd -g '*.bak' -g '*.orig' -x rm  # Remove backup files

# Organization
fd -e pdf -x mv {} ~/Documents/PDFs/  # Move PDFs
fd -e jpg -e png -t f --changed-within 1week -x cp {} ~/Photos/Recent/
```

## Performance Tips

1. **Use specific patterns**: `fd config.json` vs `fd config`
2. **Limit depth**: Use `-d` to avoid deep traversal
3. **Filter by type**: Use `-t f` for files only when appropriate
4. **Use extensions**: `-e js` is faster than `-g '*.js'`
5. **Parallel execution**: fd automatically uses multiple threads
6. **Smart exclusions**: Leverage .gitignore and .fdignore files

## Quick Script Examples

For immediate use, try these common scenarios:

```bash
# Find JavaScript files
scripts/find-by-extension.sh js

# Find large files (>100MB)
scripts/find-large-files.sh

# Find files modified today
scripts/find-recent.sh 1day

# Show (don't delete) temporary files
scripts/find-temp-files.sh

# Find empty directories
scripts/find-empty.sh dirs
```

## Workflow Integration

### With Other Tools
```bash
# Pipe to other commands
fd -e log | xargs grep ERROR
fd -t f -0 | xargs -0 file    # Determine file types

# Count results
fd -e py | wc -l              # Count Python files

# Create file lists
fd -e md > markdown_files.txt
fd -a -e jpg > image_paths.txt

# Integration with fzf (fuzzy finder)
fd -t f | fzf                 # Interactive file selection

# Integration with ripgrep
fd -e rs -x rg "TODO"         # Search TODO in Rust files
```

### Creating Aliases and Functions
```bash
# Useful aliases
alias fdf='fd -t f'           # Files only
alias fdd='fd -t d'           # Directories only
alias fdh='fd -H'             # Include hidden
alias fdr='fd -e rs -e toml'  # Rust project files

# Shell functions
findcode() { fd -e "$1" -x code; }  # Open files in VS Code
findgrep() { fd -e "$2" -x grep -l "$1"; }  # Grep in specific files
```

## Best Practices

### Do:
- **Use specific patterns** to reduce false positives
- **Leverage file type filters** for performance
- **Use appropriate depth limits** in large directories
- **Take advantage of .gitignore** for relevant searches
- **Use placeholders** in exec commands for flexibility
- **Test complex patterns** on small directories first

### Don't:
- **Don't use overly broad patterns** without filtering
- **Don't ignore performance implications** of deep searches
- **Don't forget about hidden files** when they might be relevant
- **Don't use fd for single file operations** where direct access works
- **Don't chain multiple fd commands** when one with proper filtering suffices

## Integration with Scripts

When creating scripts that use fd:
1. **Error handling**: Check if fd finds results before processing
2. **Argument validation**: Validate patterns and paths
3. **Progress indication**: For long-running searches, show progress
4. **Safety checks**: Especially important with `-x` operations
5. **Flexibility**: Allow pattern and option customization

## Interactive Usage

For interactive file exploration:
```bash
# Quick overview of current directory
fd

# Explore by type
fd -t d                       # See all subdirectories
fd -t f -e md                 # All markdown files

# Recent activity
fd --changed-within 1day      # What changed today
fd --changed-within 1hour     # Very recent changes

# Size investigation
fd -S +10m | head             # Largest files preview
```

Remember: fd is designed to be fast, intuitive, and user-friendly. When in doubt, start with simple patterns and add filters as needed. The tool's smart defaults (case-insensitive search, .gitignore respect, colored output) make it immediately useful without complex configuration.