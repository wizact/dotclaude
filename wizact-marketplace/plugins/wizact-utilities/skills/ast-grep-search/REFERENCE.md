# ast-grep Reference Guide

Comprehensive reference for advanced ast-grep features, patterns, and workflows.

> **Quick Start**: See [SKILL.md](SKILL.md) for basic usage and common patterns.

## Table of Contents

- [CLI Commands Reference](#cli-commands-reference)
- [Advanced Pattern Syntax](#advanced-pattern-syntax)
- [Configuration & Rules](#configuration--rules)
- [Output Formats & Integration](#output-formats--integration)
- [Testing & Validation](#testing--validation)
- [Performance & Optimization](#performance--optimization)

---

## CLI Commands Reference

### `ast-grep run` - One-time Search/Rewrite

Default command (can omit `run`). Executes searches and rewrites on-demand.

**Pattern/Query Options:**

```bash
# Pattern matching
ast-grep -p 'PATTERN' [path]           # Match AST pattern
ast-grep --pattern 'PATTERN'

# Node kind matching (ESQuery selectors)
ast-grep -k function_declaration       # Match by node type
ast-grep --kind identifier

# Selector extraction
ast-grep --selector 'PATTERN'          # Target sub-parts of matches
```

**Strictness Levels:**

Control matching precision with `--strictness <MODE>`:

- `cst` - Concrete Syntax Tree (exact match including whitespace)
- `smart` - Default, ignores trivial differences
- `ast` - Abstract Syntax Tree (ignores all formatting)
- `relaxed` - Loose matching, more permissive
- `signature` - Match by signature/shape only
- `template` - Template-style matching

```bash
ast-grep -p '$A + $B' --strictness smart
ast-grep -p 'fn $NAME() {}' --strictness signature
```

**Rewrite Options:**

```bash
# Preview replacement
ast-grep -p 'OLD' -r 'NEW'

# Interactive mode (review each)
ast-grep -p 'OLD' -r 'NEW' -i
ast-grep -p 'OLD' -r 'NEW' --interactive

# Apply all changes
ast-grep -p 'OLD' -r 'NEW' -U
ast-grep -p 'OLD' -r 'NEW' --update-all
```

**Output Control:**

```bash
# Context lines
ast-grep -p 'PATTERN' -A 3             # 3 lines after
ast-grep -p 'PATTERN' -B 2             # 2 lines before
ast-grep -p 'PATTERN' -C 5             # 5 lines before & after

# JSON output
ast-grep -p 'PATTERN' --json           # JSON lines (default)
ast-grep -p 'PATTERN' --json=pretty    # Pretty-printed JSON
ast-grep -p 'PATTERN' --json=stream    # JSON stream
ast-grep -p 'PATTERN' --json=compact   # Compact single array

# Color control
ast-grep -p 'PATTERN' --color=always
ast-grep -p 'PATTERN' --color=never
ast-grep -p 'PATTERN' --color=auto     # Default
```

**Debug & Inspection:**

```bash
# Show tree-sitter AST
ast-grep -p 'PATTERN' --debug-query
ast-grep -p 'PATTERN' --debug-query=pattern  # Pattern AST only
ast-grep -p 'PATTERN' --debug-query=ast      # Full file AST

# Verbose output
ast-grep -p 'PATTERN' --inspect
```

**File Filtering:**

```bash
# Globs (include/exclude)
ast-grep -p 'PATTERN' --globs '**/*.test.js'
ast-grep -p 'PATTERN' --globs '!**/node_modules/**'

# Follow symlinks
ast-grep -p 'PATTERN' --follow

# StdIn support
cat file.js | ast-grep -p 'PATTERN' --stdin
```

**Performance:**

```bash
# Thread control
ast-grep -p 'PATTERN' -j 8             # Use 8 threads
ast-grep -p 'PATTERN' --threads=16

# Heading control (per-file headers)
ast-grep -p 'PATTERN' --no-heading     # Omit file headers
```

### `ast-grep scan` - Configuration-based Scanning

Run predefined rules across projects. Great for linting and code quality checks.

**Basic Usage:**

```bash
# Scan with project rules
ast-grep scan                          # Uses sgconfig.yml

# Scan with specific config
ast-grep scan -c path/to/config.yml
ast-grep scan --config rules/custom.yml

# Scan single rule file
ast-grep scan -r path/to/rule.yml
ast-grep scan --rule my-rule.yml
```

**Rule Filtering:**

```bash
# Filter by rule ID pattern (regex)
ast-grep scan --filter 'security-.*'  # All security rules
ast-grep scan --filter 'deprecated'   # Rules with "deprecated"
```

**Severity Overrides:**

```bash
# Override severity levels
ast-grep scan --error                  # Treat all as errors
ast-grep scan --warning                # Treat all as warnings
ast-grep scan --info                   # Treat all as info
ast-grep scan --hint                   # Treat all as hints
ast-grep scan --off                    # Disable severity
```

**Output Formats:**

```bash
# Default rich format
ast-grep scan                          # Colored, detailed

# Report styles
ast-grep scan --report-style=rich      # Full details (default)
ast-grep scan --report-style=medium    # Moderate detail
ast-grep scan --report-style=short     # Minimal output

# CI/CD formats
ast-grep scan --format=github          # GitHub Actions annotations
ast-grep scan --format=sarif           # SARIF format for tools

# JSON with metadata
ast-grep scan --json --include-rule    # Include rule definitions
```

**Performance & Processing:**

```bash
# Thread control
ast-grep scan -j 16

# StdIn mode
cat code.js | ast-grep scan --stdin
```

### `ast-grep test` - Rule Testing & Validation

Test rules against snapshots and validate syntax.

```bash
# Run all tests
ast-grep test

# Test specific rules (glob pattern)
ast-grep test 'rules/security-*.yml'

# Interactive mode
ast-grep test --interactive            # Review each test
ast-grep test -i

# Update snapshots
ast-grep test --update-all             # Update all snapshots
ast-grep test -U

# Skip snapshot comparison
ast-grep test --skip-snapshot-tests    # Only validate syntax
```

### `ast-grep new` - Scaffolding & Generation

Create new rules, tests, and projects.

```bash
# Create new project
ast-grep new

# Create new rule
ast-grep new rule

# Create new test
ast-grep new test

# Create utility rule
ast-grep new util

# Specify language
ast-grep new rule --lang javascript
ast-grep new rule -l typescript
```

### `ast-grep lsp` - Language Server

Launch LSP server for editor integration.

```bash
# Start LSP server
ast-grep lsp
```

See editor-specific setup guides for configuration.

### `ast-grep completions` - Shell Completions

Generate shell completion scripts.

```bash
# Generate for your shell
ast-grep completions bash
ast-grep completions zsh
ast-grep completions fish
ast-grep completions powershell
ast-grep completions elvish
```

**Installation:**

```bash
# Bash
ast-grep completions bash > /usr/local/etc/bash_completion.d/ast-grep

# Zsh
ast-grep completions zsh > ~/.zfunc/_ast-grep

# Fish
ast-grep completions fish > ~/.config/fish/completions/ast-grep.fish
```

---

## Advanced Pattern Syntax

### Meta-Variable Naming Rules

**Valid:**
- `$VAR` - Uppercase letters
- `$META_VAR` - Underscores allowed
- `$VAR1`, `$A2` - Digits allowed (except first char)
- `$A`, `$B`, `$C` - Single letter

**Invalid:**
- `$invalid` - Lowercase
- `$Svalue` - Mixed case
- `$123` - Starting with digit
- `$KEBAB-CASE` - Hyphens not allowed
- `$` - Empty name

### Single vs Multiple Node Matching

**Single node** (`$VAR`):
```bash
# Matches: console.log("hello")
# Rejects: console.log(), console.log("a", "b")
ast-grep -p 'console.log($MSG)'
```

**Multiple nodes** (`$$$VAR`):
```bash
# Matches: fn(), fn(a), fn(a, b, c)
ast-grep -p 'function $NAME($$$PARAMS) { $$$ }'

# Common patterns
$$$ARGS      # Zero or more arguments
$$$STMTS     # Zero or more statements
$$$PARAMS    # Zero or more parameters
$$$          # Unnamed multi-node wildcard
```

### Meta-Variable Capturing

**Repeated variables must match identically:**

```bash
# Matches: a == a, x == x
# Rejects: a == b
ast-grep -p '$A == $A'

# Matches: if (x) { return x; }
# Rejects: if (x) { return y; }
ast-grep -p 'if ($VAR) { return $VAR; }'
```

**Non-capturing wildcards** (prefix with `_`):

```bash
# $_VAR doesn't capture - each can match different content
ast-grep -p 'function $_FUNC() { $_FUNC(); }'

# Matches both:
# function foo() { bar(); }
# function foo() { foo(); }
```

### Named vs Unnamed Nodes

Tree-sitter distinguishes named and unnamed nodes. Use `$$VAR` for unnamed:

```bash
# Match unnamed nodes (operators, punctuation)
ast-grep -p '$A $$OP $B'              # Matches any operator
```

### Pattern Strictness in Practice

**Example - Function matching:**

```javascript
// Code variations
function foo() { return 42; }
function foo() {
  return 42;
}
function foo()
{
  return 42;
}
```

```bash
# smart (default) - matches all above
ast-grep -p 'function foo() { return 42; }' --strictness smart

# cst - only exact whitespace match
ast-grep -p 'function foo() { return 42; }' --strictness cst

# signature - matches by shape, ignores body
ast-grep -p 'function foo() { $$$ }' --strictness signature
```

### Complex Pattern Examples

**Find functions calling themselves recursively:**
```bash
ast-grep -p 'function $NAME($$$) { $$$ $NAME($$$) $$$ }'
```

**Find error handling without logging:**
```bash
# Pattern: try/catch without console/logger
ast-grep -p 'try { $$$ } catch ($E) { $$$ }' | \
  grep -v 'console\|logger'
```

**Find React components with hooks:**
```bash
ast-grep -p 'function $COMPONENT($$$) { $$$ use$HOOK($$$) $$$ }' -l tsx
```

**Find functions with specific return patterns:**
```bash
# Functions returning promises
ast-grep -p 'function $NAME($$$) { $$$ return new Promise($$$) $$$ }'

# Functions with early returns
ast-grep -p 'function $NAME($$$) { $$$ return $EARLY; $$$ return $FINAL; $$$ }'
```

---

## Configuration & Rules

### Project Configuration (`sgconfig.yml`)

```yaml
# Basic project config
ruleDirs:
  - rules/
  - custom-rules/

languageGlobs:
  javascript:
    - "**/*.js"
    - "**/*.jsx"
  typescript:
    - "**/*.ts"
    - "**/*.tsx"

# Custom language mapping
customLanguages:
  my-lang:
    libraryPath: path/to/my-lang.so
    extensions:
      - .mylang
```

### Rule File Structure

```yaml
# rule.yml
id: no-console-log
message: Avoid console.log in production
severity: warning
language: javascript

rule:
  pattern: console.log($$$)

# Optional: auto-fix
fix: logger.debug($$$)

# Optional: constraints
constraints:
  ARGS:
    regex: ".*"  # Additional validation
```

### Advanced Rule Features

**Multiple pattern alternatives:**

```yaml
rule:
  any:
    - pattern: console.log($$$)
    - pattern: console.error($$$)
    - pattern: console.warn($$$)
```

**Pattern combinations:**

```yaml
rule:
  all:
    - pattern: function $NAME($$$) { $$$ }
    - not:
        pattern: function $NAME($$$) { $$$ return $$$ }
```

**Nested patterns:**

```yaml
rule:
  pattern: |
    class $CLASS {
      $$$
      $METHOD($$$) {
        $$$
      }
      $$$
    }
  inside:
    pattern: export default $$$
```

---

## Output Formats & Integration

### JSON Schema

**Compact format** (`--json=compact`):
```json
[
  {
    "text": "matched code",
    "range": {
      "start": {"line": 10, "column": 2},
      "end": {"line": 10, "column": 20}
    },
    "file": "src/app.js",
    "metaVariables": {
      "single": {
        "VAR": {"text": "value", "range": {...}}
      },
      "multi": {
        "ARGS": [
          {"text": "arg1", "range": {...}},
          {"text": "arg2", "range": {...}}
        ]
      }
    }
  }
]
```

**Stream format** (`--json=stream`):
```json
{"text":"match1",...}
{"text":"match2",...}
```

### CI/CD Integration

**GitHub Actions:**

```yaml
# .github/workflows/ast-grep.yml
name: Lint Code
on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ast-grep/action@v1.4
        with:
          config: sgconfig.yml
```

**SARIF output for code scanning:**

```bash
ast-grep scan --format=sarif > results.sarif
```

### Processing with jq

```bash
# Extract all matched text
ast-grep -p 'PATTERN' --json=compact | jq -r '.[].text'

# Get unique file list
ast-grep -p 'PATTERN' --json=compact | jq -r '.[].file' | sort -u

# Count matches per file
ast-grep -p 'PATTERN' --json=stream | \
  jq -r '.file' | uniq -c | sort -rn

# Extract meta-variable values
ast-grep -p '$FUNC($$$)' --json=compact | \
  jq -r '.[].metaVariables.single.FUNC.text' | sort -u
```

---

## Testing & Validation

### Test File Structure

```
tests/
  my-rule-test.yml     # Test definition
  snapshots/
    my-rule-test.yml   # Expected output
```

**Test definition:**

```yaml
# tests/my-rule-test.yml
id: test-no-console
rule:
  pattern: console.log($$$)

valid:
  - logger.debug('ok')
  - console.info('ok')

invalid:
  - console.log('bad')
  - |
    function test() {
      console.log('also bad');
    }
```

### Snapshot Testing

Snapshots capture expected output for regression testing.

```bash
# Generate initial snapshots
ast-grep test --update-all

# Verify tests match snapshots
ast-grep test

# Review and update interactively
ast-grep test --interactive
```

---

## Performance & Optimization

### Benchmarking

```bash
# Time searches
time ast-grep -p 'PATTERN' -l typescript src/

# Profile with different thread counts
time ast-grep -p 'PATTERN' -j 1
time ast-grep -p 'PATTERN' -j 4
time ast-grep -p 'PATTERN' -j 8
```

### Optimization Strategies

**1. Limit scope:**
```bash
# Specific directory
ast-grep -p 'PATTERN' src/components/

# File type filtering
ast-grep -p 'PATTERN' --globs '**/*.ts'
```

**2. Use appropriate strictness:**
```bash
# Faster for exact matches
ast-grep -p 'EXACT_CODE' --strictness cst

# Faster for loose matches
ast-grep -p 'PATTERN' --strictness relaxed
```

**3. Optimize patterns:**
```bash
# More specific patterns are faster
ast-grep -p 'function specificName($$$) { $$$ }'  # Fast
ast-grep -p 'function $ANY($$$) { $$$ }'          # Slower
```

**4. Parallel processing:**
```bash
# Auto-detect (default)
ast-grep -p 'PATTERN'

# Manual thread count
ast-grep -p 'PATTERN' -j $(nproc)
```

### Memory Considerations

For large codebases:

```bash
# Process in batches
find src/ -name '*.js' | xargs -n 100 ast-grep -p 'PATTERN'

# Use streaming JSON
ast-grep scan --json=stream | process-stream.sh
```

---

## Common Workflows

### Code Migration

```bash
# Find old API usage
ast-grep -p 'oldAPI($$$)' --json=compact > migration-report.json

# Interactive replacement
ast-grep -p 'oldAPI($METHOD, $$$ARGS)' \
         -r 'newAPI({ method: $METHOD, args: [$$$ARGS] })' -i

# Batch replacement with confirmation
ast-grep -p 'oldAPI($$$)' -r 'newAPI($$$)' -U
```

### Code Quality Checks

```bash
# Find complex patterns (in CI)
ast-grep scan --format=github --error

# Generate quality report
ast-grep scan --json > quality-report.json
```

### Refactoring Analysis

```bash
# Find all usage sites before refactoring
ast-grep -p 'dangerousFunction($$$)' -l -l javascript | \
  xargs -I {} sh -c 'echo "File: {}" && ast-grep -p "dangerousFunction(\$\$\$)" {}'

# Verify refactoring completeness
if ast-grep -p 'oldPattern($$$)' src/ > /dev/null; then
  echo "ERROR: Old pattern still exists"
  exit 1
fi
```

---

## Resources

- **Official Docs**: https://ast-grep.github.io/
- **CLI Reference**: https://ast-grep.github.io/reference/cli.html
- **Pattern Syntax**: https://ast-grep.github.io/reference/rule.html
- **Playground**: https://ast-grep.github.io/playground.html
- **GitHub**: https://github.com/ast-grep/ast-grep
