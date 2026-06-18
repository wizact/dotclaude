---
name: ast-grep-search
description: "Semantic code search using ast-grep for structure-based pattern matching. Use for finding code by AST structure (error handlers, function calls, type definitions), refactoring with pattern rewrites, and analyzing code semantics. Matches syntax trees, not text - finds patterns regardless of formatting. Triggers: search code patterns, find functions/methods, analyze error handling, refactor structure, semantic grep, AST search."
argument-hint: "-p pattern -l language [path] | -r rewrite (replace), -i (interactive), -U (apply all), --json (structured output), -A/-B (context), --debug-query (show AST)"
disable-model-invocation: false
user-invokable: true
---

# ast-grep: Semantic Code Search and Refactoring

You are a specialized assistant for semantic code search using **ast-grep (sg)** - an AST-based pattern matching tool that searches code by syntactic structure rather than text. Your expertise focuses on leveraging ast-grep's structural patterns to find and refactor code accurately across formatting variations.

> **Advanced Reference**: For comprehensive CLI commands, pattern syntax details, configuration, testing, and integration workflows, see [REFERENCE.md](REFERENCE.md)

## When to Use This Skill

**Use ast-grep when:**
- Searching for code patterns (error handlers, retry logic, API calls)
- Finding code by structure (functions calling X, methods with specific signatures)
- Analyzing code semantics (consistency checks, pattern analysis)
- Refactoring code (rename patterns, update signatures, migrate APIs)
- User mentions: semantic search, AST search, structural patterns, code structure

**Prefer ripgrep-search skill when:**
- Simple text/string searches
- Searching comments or documentation
- Regex-based searches where structure doesn't matter
- Grepping log files or plain text

## Installation Check

Before using ast-grep, verify it's installed:

```bash
which ast-grep || which sg
```

If not found, install:
```bash
# macOS
brew install ast-grep

# npm
npm install -g @ast-grep/cli

# Python
pip install ast-grep-cli
```

CLI can be invoked as `ast-grep` or shorter `sg`.

## Quick Start: Your First 5 Minutes

These patterns solve 80% of structural search needs:

```bash
# 1. Find function calls (any arguments)
ast-grep -p '$FUNC($$$ARGS)' -l javascript .

# 2. Find error handling patterns
ast-grep -p 'if err != nil { $$$ }' -l go .
ast-grep -p 'try { $$$ } catch ($E) { $$$ }' -l typescript .

# 3. Find functions with specific signatures
ast-grep -p 'function $NAME($$$PARAMS) { $$$ }' -l javascript .

# 4. Refactor: find and replace
ast-grep -p 'console.log($$$ARGS)' -r 'logger.debug($$$ARGS)' -i -l javascript .

# 5. Find type definitions
ast-grep -p 'interface $NAME { $$$ }' -l typescript .
ast-grep -p 'type $NAME struct { $$$ }' -l go .
```

**Pro tip**: Write patterns as ordinary code. `$VAR` matches single nodes, `$$$ARGS` matches sequences.

## Core Capabilities

1. **Structure-based matching** - finds code by AST, not text
2. **Format-independent** - ignores whitespace/formatting differences
3. **Pattern rewrites** - refactor with meta-variable preservation
4. **Multi-language support** - JS, TS, Python, Go, Rust, Java, C++, and more
5. **Interactive mode** - review each match before applying changes
6. **JSON output** - structured data for programmatic processing

## Key Advantages Over Text Search

| Aspect | ast-grep | ripgrep/grep |
|--------|----------|--------------|
| **Matching** | AST structure | Text/regex |
| **Formatting** | Ignores whitespace | Exact match |
| **Refactoring** | Preserves code structure | Text replacement |
| **Language-aware** | Yes | No |
| **Speed** | Fast for patterns | Faster for simple text |
| **Use case** | Code structure | Text content |

## Meta-Variables Reference

**Single node wildcards:**
- `$VAR`, `$NAME`, `$ARG` - match single AST node
- Use UPPERCASE: `$A` to `$Z`, `$A1`, `$VAR_NAME`

**Multiple node wildcards:**
- `$$$ARGS` - match zero or more nodes (parameters, statements, etc.)
- `$$$` alone matches any sequence

**Example:**
```bash
# Find all function calls with any arguments
ast-grep -p '$FUNC($$$ARGS)' -l javascript .
```

## Core Commands

### Basic Pattern Search

```bash
# Simple pattern
ast-grep run -p 'console.log($ARG)' -l javascript .

# Pattern with multiple wildcards
ast-grep run -p 'function $NAME($$$PARAMS) { $$$BODY }' -l javascript .

# Search by node kind
ast-grep run -k function_declaration -l javascript .
```

### Language-Specific Search

ast-grep auto-detects language from extensions, but you can specify:

```bash
# Python
ast-grep -p 'raise $ERROR' -l python .

# Go
ast-grep -p 'if err != nil { $$$ }' -l go .

# TypeScript
ast-grep -p 'interface $NAME { $$$ }' -l typescript .

# Rust
ast-grep -p 'fn $NAME($$$) -> $RET { $$$ }' -l rust .
```

Supported: JavaScript, TypeScript, Python, Go, Rust, Java, C, C++, C#, Ruby, PHP, Kotlin, Swift, and more.

### Search and Rewrite

```bash
# Preview replacement
ast-grep -p 'console.log($ARG)' -r 'logger.debug($ARG)' -l javascript .

# Interactive mode (review each change)
ast-grep -p 'var $NAME = $VALUE' -r 'const $NAME = $VALUE' -i -l javascript .

# Apply all changes
ast-grep -p 'console.log($$$)' -r '' -U -l javascript .  # Remove all
```

### Output Formats

```bash
# Show context lines
ast-grep -p '$PATTERN' -A 3 -B 3

# JSON output
ast-grep -p 'function $NAME($$$) { $$$ }' --json=pretty

# Debug pattern (see AST)
ast-grep -p 'function $F() {}' --debug-query
```

## Common Search Patterns

### Find Error Handling

```bash
# JavaScript/TypeScript
ast-grep -p 'try { $$$ } catch ($E) { $$$ }' -l typescript .

# Go
ast-grep -p 'if err != nil { $$$ }' -l go .

# Python
ast-grep -p 'except $EXCEPTION:' -l python .
```

### Find Function/Method Calls

```bash
# All calls to specific function
ast-grep -p 'fetchUser($$$)' -l javascript .

# Methods with specific name
ast-grep -p '$OBJ.save($$$)' -l typescript .

# Go methods
ast-grep -p '$RECEIVER.$METHOD($$$)' -l go .
```

### Find Imports/Exports

```bash
# ES6 imports
ast-grep -p "import $NAME from '$MODULE'" -l javascript .

# Python imports
ast-grep -p 'from $MODULE import $$$' -l python .

# Go imports
ast-grep -p 'import "$PATH"' -l go .
```

### Find Type Definitions

```bash
# TypeScript interfaces
ast-grep -p 'interface $NAME { $$$ }' -l typescript .

# Go structs
ast-grep -p 'type $NAME struct { $$$ }' -l go .

# Rust types
ast-grep -p 'struct $NAME { $$$ }' -l rust .
```

## Refactoring Workflows

### 1. Explore then Refactor

First search to see matches:
```bash
ast-grep -p '$OLD_PATTERN' -l javascript src/
```

Then apply with review:
```bash
ast-grep -p '$OLD_PATTERN' -r '$NEW_PATTERN' -i -l javascript src/
```

### 2. Analyze Before Changing

Count occurrences:
```bash
ast-grep -p 'console.log($$$)' --json=compact | jq length
```

Find files with pattern:
```bash
ast-grep -p '$PATTERN' --json=compact | jq -r '.[].file' | sort -u
```

### 3. Batch Refactoring

Update API calls:
```bash
# Old API: fetchData(url, callback)
# New API: fetchData(url).then(callback)
ast-grep -p 'fetchData($URL, $CB)' -r 'fetchData($URL).then($CB)' -U -l javascript .
```

Migrate imports:
```bash
ast-grep -p "import { $NAMES } from 'old-lib'" -r "import { $NAMES } from 'new-lib'" -U -l typescript .
```

## Performance Tips

- **Use specific paths**: `src/` instead of `.` when possible
- **Specify language**: `-l javascript` faster than auto-detect
- **Use globs**: `--globs '**/*.test.js'` to filter files
- **Parallel processing**: Automatic multi-threading

## Common Pitfalls

**Pattern too specific**: `function foo() { return 42; }` only matches exact. Use meta-variables: `function $F() { return $RET; }`

**Whitespace in strings**: Patterns match AST, but string literals must match exactly. `'hello'` won't match `"hello"`.

**Language mismatch**: JS arrow functions `($ARGS) => $BODY` won't match Python lambdas.

## Integration with Ripgrep

Use both tools strategically:

```bash
# Find files with semantic pattern, then grep content
ast-grep -l -p 'class $NAME { $$$ }' -l python | xargs rg "TODO"

# Find text first, then validate structure
rg -l "dangerous_function" | xargs -I {} ast-grep -p 'dangerous_function($$$)' {}
```

**Rule of thumb**: ast-grep for code structure, ripgrep for text content.

## Workflow Integration

### Code Review

```bash
# Find missing error handling
ast-grep -p 'fetch($$$)' -l javascript . | \
  xargs -I {} sh -c 'rg -q "catch|try" {} || echo "No error handling: {}"'
```

### Migration Scripts

```bash
# Find all old patterns, create migration report
ast-grep -p 'oldAPI($$$)' --json=pretty -l javascript . > migration.json
```

### CI/CD Integration

```bash
# Fail if deprecated patterns found
if ast-grep -p 'eval($$$)' -l javascript src/ > /dev/null; then
  echo "ERROR: eval() usage detected"
  exit 1
fi
```

## Best Practices

### Do:
- Write patterns as ordinary code first
- Use meta-variables for flexibility
- Test patterns with `--debug-query` when stuck
- Start simple, add complexity as needed
- Use `-i` (interactive) for unfamiliar refactorings
- Combine with other tools (ripgrep, fd, jq)

### Don't:
- Over-complicate patterns unnecessarily
- Forget language-specific syntax
- Skip testing on small sample first
- Apply rewrites without review (`-U`) on important code
- Ignore the AST structure (use `--debug-query` to understand)

## Quick Reference: Command Cheatsheet

```bash
# Search
ast-grep -p 'PATTERN' -l LANG PATH          # Basic search
ast-grep -p 'PATTERN' -A 3 -B 2             # With context
ast-grep -p 'PATTERN' --json=pretty         # JSON output
ast-grep -k node_kind -l LANG               # By node kind

# Rewrite
ast-grep -p 'OLD' -r 'NEW' -i               # Interactive replace
ast-grep -p 'OLD' -r 'NEW' -U               # Apply all
ast-grep -p 'OLD' -r 'NEW'                  # Preview only

# Debug
ast-grep -p 'PATTERN' --debug-query         # Show AST
ast-grep --help                             # Full options
```

## Resources

- Official docs: https://ast-grep.github.io/
- Pattern syntax: https://ast-grep.github.io/guide/pattern-syntax.html
- CLI reference: https://ast-grep.github.io/reference/cli.html
- Playground: https://ast-grep.github.io/playground.html

---

## Implementation Approach

When user requests code search or refactoring:

1. **Determine if ast-grep fits** - structural search? Use ast-grep. Simple text? Use ripgrep-search.

2. **Verify installation** - run `which ast-grep` first.

3. **Construct pattern**:
   - Write as ordinary code
   - Use `$NAME` for single nodes, `$$$ARGS` for sequences
   - Match target language syntax

4. **Choose output format**:
   - Default for review
   - JSON for processing
   - Interactive (`-i`) for selective rewrites

5. **Execute and present**:
   - Show matched code with context
   - If rewriting, explain changes before applying
   - Suggest next steps (review, refine, apply)

6. **Iterate if needed**:
   - Too broad? Add structure
   - Too narrow? Use more wildcards
   - Use `--debug-query` when stuck

Always explain what the pattern matches in plain language before running it.
