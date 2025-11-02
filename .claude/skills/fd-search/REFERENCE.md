# fd Search Reference Guide

This comprehensive reference provides detailed examples, troubleshooting tips, and advanced usage patterns for the fd file search tool.

## Quick Reference

### Command Structure
```
fd [OPTIONS] [pattern] [path]...
```

### Most Common Options
| Option | Short | Description | Example |
|--------|-------|-------------|---------|
| `--type` | `-t` | Filter by file type | `fd -t f` (files only) |
| `--extension` | `-e` | Filter by extension | `fd -e js` |
| `--glob` | `-g` | Use glob patterns | `fd -g '*.txt'` |
| `--hidden` | `-H` | Include hidden files | `fd -H config` |
| `--no-ignore` | `-I` | Ignore .gitignore | `fd -I temp` |
| `--case-sensitive` | `-s` | Force case-sensitive | `fd -s Config` |
| `--max-depth` | `-d` | Limit depth | `fd -d 2 config` |
| `--exec` | `-x` | Execute command | `fd -e log -x rm` |
| `--size` | `-S` | Filter by size | `fd -S +1m` |

## Detailed Examples

### Basic Patterns

#### File Name Searching
```bash
# Simple substring search
fd readme                     # Files containing "readme"
fd README                     # Case-sensitive if uppercase present
fd -i readme                  # Force case-insensitive

# Exact filename (with glob)
fd -g readme.txt              # Exact match using glob
fd -F readme.txt              # Exact match using fixed strings

# Multiple patterns
fd --and config --and json    # Files containing both "config" AND "json"
```

#### Regular Expression Patterns
```bash
# Basic regex
fd '^[Cc]onfig'               # Start with Config or config
fd '\.(json|yaml|toml)$'      # Configuration file extensions
fd '^test.*\.py$'             # Python test files

# Complex patterns
fd '^\d{4}-\d{2}-\d{2}'       # Date-like filenames (YYYY-MM-DD)
fd '[Bb]ackup.*\.(sql|db)$'   # Database backup files
fd '^\..*rc$'                 # Hidden rc files (.bashrc, .vimrc, etc.)
```

#### Glob Patterns
```bash
# Simple globs
fd -g '*.log'                 # All log files
fd -g 'test_*'                # Files starting with test_
fd -g '*config*'              # Files containing config

# Complex globs
fd -g '**/*.rs'               # Rust files anywhere
fd -g 'src/**/*test*.rs'      # Test files in src tree
fd -g '{*.json,*.yaml,*.toml}' # Multiple extensions
```

### File Type Filtering

#### Basic Types
```bash
# Standard types
fd -t f pattern               # Regular files only
fd -t d pattern               # Directories only
fd -t l pattern               # Symbolic links only

# Special types
fd -t x                       # Executable files
fd -t e                       # Empty files and directories
fd -t s                       # Sockets
fd -t p                       # Named pipes (FIFOs)
```

#### Combining Types
```bash
# Multiple file types
fd -t f -t l config           # Files AND symlinks containing "config"
fd -t e -t f                  # Empty files (not directories)
fd -t e -t d                  # Empty directories (not files)

# Extension filtering
fd -e js -e ts -e jsx         # JavaScript family files
fd -e log -e out -e err       # Common log extensions
fd -e md -e txt -e rst        # Documentation files
```

### Advanced Filtering

#### Size-Based Searches
```bash
# Size comparisons
fd -S +100m                   # Files larger than 100MB
fd -S -1k                     # Files smaller than 1KB
fd -S 1g                      # Files exactly 1GB (rare)

# Size with patterns
fd -S +50m -e mp4             # Large video files
fd -S -10k -e txt             # Small text files
fd -S +1g -t f | head -5      # 5 largest files

# Human-readable sizes
fd -S +1.5gi                  # Larger than 1.5 GiB (binary)
fd -S -500k                   # Smaller than 500KB (decimal)
```

#### Time-Based Searches
```bash
# Relative time
fd --changed-within 1hour     # Last hour
fd --changed-within 3days     # Last 3 days
fd --changed-within 2weeks    # Last 2 weeks
fd --changed-within 6months   # Last 6 months

# Absolute time
fd --changed-within '2024-01-01 10:00:00'  # Since specific datetime
fd --changed-before '2023-12-31'           # Before specific date

# Time with other filters
fd -e log --changed-within 1day            # Recent log files
fd -S +10m --changed-before 30days         # Large old files
```

#### Ownership Filtering
```bash
# User ownership
fd --owner john               # Files owned by user "john"
fd --owner 1000               # Files owned by UID 1000

# Group ownership
fd --owner :developers        # Files owned by group "developers"
fd --owner :100               # Files owned by GID 100

# Combined ownership
fd --owner john:developers    # User john, group developers

# Exclusion
fd --owner '!root'            # NOT owned by root
fd --owner '!:wheel'          # NOT owned by wheel group
```

### Directory Control

#### Depth Control
```bash
# Maximum depth
fd -d 1                       # Current directory only
fd -d 3 config                # Maximum 3 levels deep

# Minimum depth
fd --min-depth 2 config       # Start searching 2 levels down

# Exact depth
fd --exact-depth 1            # Exactly 1 level (same as -d 1 --min-depth 1)

# Practical examples
fd -d 2 -t d                  # Subdirectories, max 2 levels
fd --min-depth 3 -e js        # JS files, skip top 2 levels
```

#### Include/Exclude Control
```bash
# Hidden files
fd -H                         # Include hidden files
fd -H config                  # Find hidden config files
fd --no-hidden config         # Explicitly exclude hidden (default)

# Ignore files
fd -I                         # Ignore .gitignore rules
fd -I node_modules            # Find node_modules (usually ignored)
fd --no-ignore-vcs            # Ignore only .gitignore, not other ignore files

# Unrestricted
fd -u pattern                 # Same as -H -I (show everything)

# Custom exclusions
fd -E node_modules            # Exclude node_modules directories
fd -E '*.tmp' -E '*.temp'     # Exclude temporary files
fd -E '.git' -E '.svn'        # Exclude version control
```

### Command Execution

#### Single Command per File
```bash
# Basic execution
fd -e jpg -x ls -la           # List details of all JPEG files
fd -e py -x python -m py_compile  # Compile all Python files

# Using placeholders
fd -e txt -x cp {} {}.backup  # Backup all text files
fd -e jpg -x convert {} {.}.png   # Convert JPG to PNG

# Directory operations
fd -t d -x du -sh             # Show size of each directory
fd -t d empty -x rmdir        # Remove empty directories named "empty"

# Complex commands
fd -e log -x sh -c 'echo "Processing: {}"; gzip {}'  # Compress logs with message
```

#### Batch Execution
```bash
# Process all at once
fd -e py -X wc -l             # Total line count of all Python files
fd -e md -X cat               # Concatenate all markdown files

# Editor operations
fd -g 'test_*.py' -X code     # Open all test files in VS Code
fd -e rs -X vim               # Open all Rust files in vim

# Archive operations
fd -e jpg -X tar czf photos.tar.gz  # Archive all photos
fd -d 1 -t d -X zip -r backup.zip   # Zip all subdirectories
```

### Output Control

#### Path Formatting
```bash
# Absolute paths
fd -a config                  # Show full paths from root
fd --absolute-path config     # Same as above

# Relative paths (default)
fd config                     # Relative to current directory

# Full path matching
fd -p '/home/.*/\.bashrc'     # Match against full path with regex
fd -p -g '/home/*/.bashrc'    # Match against full path with glob
```

#### Output Format
```bash
# Null separation (for xargs)
fd -0 -e txt                  # Null-separated output
fd -0 -e txt | xargs -0 wc -l # Safe with filenames containing spaces

# Detailed listing
fd -l config                  # Like 'ls -l' output
fd -l -e log                  # Detailed log file listing

# Color control
fd --color always config      # Always colorize
fd --color never config       # Never colorize
fd --color auto config        # Auto-detect terminal (default)
```

#### Result Limits
```bash
# Limit number of results
fd --max-results 5 config     # First 5 matches only
fd -1 config                  # Stop after first match (fast check)

# Quiet mode
fd -q config                  # No output, exit code 0 if found
fd --quiet important-file     # Check existence silently
```

## Practical Workflows

### Development Scenarios

#### Code Analysis
```bash
# Find source files
fd -e c -e cpp -e h -e hpp | wc -l        # Count C/C++ files
fd -e js -e ts -X wc -l                   # Line count of JS/TS files
fd -e py -x grep -l "TODO"                # Python files with TODOs

# Find configuration
fd -g '*config*' -t f                     # All config files
fd -g '.env*'                             # Environment files
fd -e json -e yaml -e toml                # Common config formats

# Find tests
fd -g '*test*' -e py                      # Python test files
fd -g 'test_*' -e js                      # JavaScript test files
fd -g '*_test.go'                         # Go test files
```

#### Build System Investigation
```bash
# Find build files
fd -g 'Makefile*' -g '*.mk'               # Make files
fd -g 'package.json' -g 'yarn.lock'       # Node.js projects
fd -g 'Cargo.toml' -g 'Cargo.lock'        # Rust projects
fd -g 'pom.xml' -g 'build.gradle'         # Java projects

# Find artifacts
fd -g 'target/' -t d                      # Rust build directories
fd -g 'node_modules/' -t d                # Node.js dependencies
fd -g '__pycache__/' -t d                 # Python cache
fd -g '*.o' -g '*.so' -g '*.dll'          # Compiled objects
```

#### Version Control
```bash
# Git repository analysis
fd -g '.git/' -t d                        # Find all git repos
fd -g '.gitignore' -t f                   # All gitignore files
fd -g 'README*' -t f                      # All readme files

# Find uncommitted changes areas
fd -H -g '.git/hooks/*'                   # Git hooks
fd -g '*.orig' -g '*.rej'                 # Merge conflict files
```

### System Administration

#### Log Analysis
```bash
# Find logs
fd -e log                                 # All log files
fd -e log --changed-within 1day          # Recent log files
fd -S +100m -e log                        # Large log files

# Log processing
fd -e log -x grep -l "ERROR"              # Logs with errors
fd -e log --changed-within 1hour -x tail -n 50  # Recent log tails
```

#### Cleanup Operations
```bash
# Find temporary files
fd -g '*.tmp' -g '*.temp'                 # Temporary files
fd -g '*~' -g '.#*'                       # Editor backup files
fd -e pyc -e pyo                          # Python bytecode

# Cleanup execution
fd -g '*.tmp' -x rm                       # Remove temp files
fd -t e -t d -x rmdir                     # Remove empty directories
fd -g '*.log' --changed-before 30days -x gzip  # Compress old logs
```

#### Security Auditing
```bash
# Find executables
fd -t x                                   # All executable files
fd -t x --owner root                      # Root-owned executables
fd -t f -x file | grep -i 'setuid'        # Find setuid binaries

# Permission auditing
fd -t f -x ls -la | grep '^-rw-rw-rw-'    # World-writable files
fd -t d -x ls -ld | grep '^drwxrwxrwx'    # World-writable directories
```

### File Management

#### Organization
```bash
# Sort by type
fd -e jpg -e png -e gif -X mv {} ~/Pictures/   # Move images
fd -e pdf -X mv {} ~/Documents/                # Move PDFs
fd -e mp3 -e mp4 -e avi -X mv {} ~/Media/      # Move media files

# Backup operations
fd -e doc -e docx -e pdf -X cp {} ~/Backup/    # Backup documents
fd --changed-within 1week -X cp {} ~/Recent/   # Backup recent files
```

#### Duplicate Detection
```bash
# Generate checksums
fd -e jpg -X md5sum > image_checksums.txt     # Checksum all images
fd -e pdf -X sha256sum > document_hashes.txt  # Hash all PDFs

# Find potential duplicates by name
fd -g '*copy*' -g '*duplicate*'               # Files with copy/duplicate in name
fd -g '* (1)*' -g '* (2)*'                    # Files with parenthetical numbers
```

## Integration Examples

### With fzf (Fuzzy Finder)
```bash
# Interactive file selection
fd -t f | fzf                              # Choose any file
fd -e md | fzf | xargs code                # Edit markdown file in VS Code
fd -t d | fzf | cd                         # Change to directory (in function)

# Multi-selection
fd -e py | fzf -m | xargs code             # Select multiple Python files
```

### With ripgrep
```bash
# Search content in specific files
fd -e rs -x rg "TODO"                      # Find TODOs in Rust files
fd -e py -x rg -l "class.*Test"            # Python files with test classes
fd -e md -x rg -i "fixme"                  # Case-insensitive FIXME in markdown
```

### With xargs
```bash
# Safe processing with null separation
fd -0 -e txt | xargs -0 wc -l              # Count lines safely
fd -0 -g '*.backup' | xargs -0 rm          # Remove backups safely

# Parallel processing
fd -e jpg | xargs -P 4 -I {} convert {} {.}.png  # Parallel image conversion
```

## Shell Integration

### Useful Aliases
```bash
# Add to ~/.bashrc or ~/.zshrc
alias fdf='fd -t f'                        # Files only
alias fdd='fd -t d'                        # Directories only
alias fdh='fd -H'                          # Include hidden
alias fdr='fd -t f -e rs -e toml'          # Rust files
alias fdj='fd -t f -e js -e ts -e jsx -e tsx'  # JavaScript files
alias fdc='fd -t f -e c -e cpp -e h -e hpp'    # C/C++ files
```

### Shell Functions
```bash
# Open files in editor
fde() {
    local editor="${EDITOR:-code}"
    fd -e "$1" | fzf | xargs "$editor"
}

# Find and grep
fdg() {
    local pattern="$1"
    local ext="$2"
    fd -e "$ext" -x grep -l "$pattern"
}

# Recent files
fdr() {
    local days="${1:-1}"
    fd --changed-within "${days}days" -t f
}

# Large files
fdl() {
    local size="${1:-100m}"
    fd -S "+${size}" -t f | sort -k5 -hr
}
```

## Performance Optimization

### Best Practices
1. **Use specific patterns**: `fd config.json` vs `fd config`
2. **Filter by type early**: `-t f` when only files needed
3. **Limit depth**: Use `-d` in deep directory structures
4. **Use extensions**: `-e js` is faster than `-g '*.js'`
5. **Leverage .gitignore**: Don't use `-I` unless necessary

### Benchmarking
```bash
# Compare with find
time fd -e py
time find . -name "*.py" -type f

# Profile large searches
fd -e log --stats                          # Show search statistics
fd -e js --threads 1                       # Single-threaded for comparison
```

## Troubleshooting

### Common Issues

#### No Results Found
```bash
# Check if pattern is too specific
fd config                                  # Broader search
fd -H config                               # Include hidden files
fd -I config                               # Include ignored files
fd -u config                               # Include everything

# Check depth limits
fd -d 5 config                             # Increase depth limit
fd --min-depth 0 config                    # Start from current level
```

#### Permission Errors
```bash
# Show errors
fd --show-errors config                    # Display permission errors

# Skip problematic directories
fd -E '/proc' -E '/sys' config             # Exclude system directories
```

#### Performance Issues
```bash
# Reduce scope
fd -d 3 config                             # Limit depth
fd -t f config                             # Files only
fd config ~/specific/path                  # Search specific directory

# Check .fdignore
echo "large_directory/" >> .fdignore       # Ignore large directories
```

### Debug Mode
```bash
# Verbose output (not built-in, but useful pattern)
fd --show-errors --color always config 2>&1 | tee search.log

# Test patterns
fd -1 your-pattern                         # Quick test with first match only
```

## Comparison with find

### Syntax Comparison
| Task | find | fd |
|------|------|-----|
| Find by name | `find . -name "*.txt"` | `fd -g '*.txt'` or `fd -e txt` |
| Case-insensitive | `find . -iname "config"` | `fd -i config` |
| Files only | `find . -type f -name "*.py"` | `fd -t f -e py` |
| Execute command | `find . -name "*.log" -exec rm {} \;` | `fd -e log -x rm` |
| Size filter | `find . -size +100M` | `fd -S +100m` |
| Modified time | `find . -mtime -1` | `fd --changed-within 1day` |

### Performance Comparison
```bash
# Benchmark both tools
hyperfine 'find . -name "*.rs" -type f' 'fd -e rs'
hyperfine 'find . -type f | wc -l' 'fd -t f | wc -l'
```

### Migration Tips
1. **Start simple**: Begin with basic `fd pattern` searches
2. **Add filters gradually**: Use `-t`, `-e`, `-d` as needed
3. **Leverage defaults**: fd's smart defaults often eliminate options
4. **Use placeholders**: fd's `{}` placeholders are more intuitive than find's
5. **Embrace regex**: fd uses regex by default, unlike find's shell patterns

## Advanced Use Cases

### Custom Ignore Files
```bash
# Create .fdignore file
echo "node_modules/" >> .fdignore
echo "*.tmp" >> .fdignore
echo ".cache/" >> .fdignore

# Use custom ignore file
fd --ignore-file my-custom.ignore pattern
```

### Complex Workflows
```bash
# Multi-step processing
fd -e md | \
  xargs grep -l "TODO" | \
  fzf -m | \
  xargs code

# Conditional execution
fd -e log --changed-within 1hour | \
  while read file; do
    if [[ $(wc -l < "$file") -gt 1000 ]]; then
      echo "Large log: $file"
      gzip "$file"
    fi
  done
```

### Integration with Git
```bash
# Find files not in git
comm -23 <(fd -t f | sort) <(git ls-files | sort)

# Find large files for .gitignore
fd -S +10m -t f | sed 's|^\./||' >> .gitignore

# Clean untracked files
fd -I -t f | grep -v "$(git ls-files)" | xargs rm
```

This reference guide covers the most common and advanced usage patterns for fd. Remember that fd's strength lies in its intuitive syntax and smart defaults, making most file searching tasks simpler and faster than traditional tools.