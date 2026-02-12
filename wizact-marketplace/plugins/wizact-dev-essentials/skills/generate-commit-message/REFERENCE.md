# Commit Message Skill - Complete Reference Guide

Comprehensive reference for the Conventional Commits specification, examples, patterns, and troubleshooting.

## Table of Contents

1. [Conventional Commits Specification](#conventional-commits-specification)
2. [Script Documentation](#script-documentation)
3. [Advanced Patterns](#advanced-patterns)
4. [Real-World Examples](#real-world-examples)
5. [Troubleshooting](#troubleshooting)
6. [Integration Patterns](#integration-patterns)
7. [Best Practices](#best-practices)

## Conventional Commits Specification

### Format Structure

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Type

MUST be one of the following:

- **feat**: New feature for the user
- **fix**: Bug fix for the user
- **docs**: Documentation only changes
- **style**: Changes that don't affect code meaning (whitespace, formatting, semicolons)
- **refactor**: Code change that neither fixes a bug nor adds a feature
- **perf**: Code change that improves performance
- **test**: Adding missing tests or correcting existing tests
- **build**: Changes affecting build system or external dependencies (npm, cargo, gradle)
- **ci**: Changes to CI configuration files and scripts (GitHub Actions, Travis, Circle)
- **chore**: Other changes that don't modify src or test files (tooling, scaffolding)

### Scope

OPTIONAL element after type providing additional contextual information:

- Denoted by parentheses: `feat(parser):`
- Should be a noun describing section of codebase
- Examples: `api`, `ui`, `database`, `auth`, `parser`, `cli`

### Description

Brief summary of the code change:

- MUST immediately follow type/scope prefix
- MUST use imperative, present tense: "change" not "changed" nor "changes"
- MUST NOT capitalize first letter
- MUST NOT end with period
- SHOULD be under 50 characters

### Body

OPTIONAL longer description:

- MUST begin one blank line after description
- Free-form, MAY consist of multiple paragraphs
- SHOULD wrap at 72 characters
- SHOULD explain "what" and "why", not "how"
- MAY use bullet points (use `-` or `*`)

### Footer(s)

OPTIONAL metadata:

- MUST begin one blank line after body (or description if no body)
- MUST either be a token + `: ` or `#` separator, or `BREAKING CHANGE: `
- Common footers:
  - `Fixes #123` - Closes issue
  - `Refs #456` - References issue
  - `Co-authored-by: Name <email>` - Multiple authors
  - `BREAKING CHANGE: description` - Breaking API changes

### Breaking Changes

MUST be indicated in footer OR by `!` after type/scope:

```
feat(api)!: remove deprecated endpoints

BREAKING CHANGE: The /v1/users endpoint has been removed.
Use /v2/users instead.
```

## Script Documentation

### 1. analyze-changes.sh - Analyze Git Changes

**Purpose**: Analyze staged and unstaged changes with file statistics.

**Syntax**: `analyze-changes.sh [options]`

**Examples**:
```bash
# Basic analysis
analyze-changes.sh

# Include unstaged changes
analyze-changes.sh --include-unstaged

# Detailed file stats
analyze-changes.sh --detailed

# JSON output
analyze-changes.sh --json
```

**Output**:
- Staged files count
- Changed file types (code/test/docs/config)
- Lines added/deleted
- Binary files changed

### 2. generate-message.sh - Generate Commit Message

**Purpose**: Generate Conventional Commit message from parameters.

**Syntax**: `generate-message.sh <type> [scope] <description> [options]`

**Examples**:
```bash
# Simple commit
generate-message.sh feat "add user authentication"

# With scope
generate-message.sh fix auth "handle null token case"

# With body
generate-message.sh refactor api "simplify error handling" \
  --body "Consolidate error handling logic into middleware.
Reduces duplication across route handlers."

# With footer
generate-message.sh feat auth "add OAuth2 support" \
  --body "Implement OAuth2 authorization code flow." \
  --footer "Fixes #123"

# Breaking change
generate-message.sh feat api "remove legacy endpoints" \
  --breaking "Removed /v1 API endpoints. Use /v2 instead."

# Multiple footers
generate-message.sh fix "update dependencies" \
  --footer "Refs #456" \
  --footer "Co-authored-by: John Doe <john@example.com>"
```

**Validation**:
- Type must be valid
- Description required
- Subject line length checked
- Body line wrapping validated

### 3. validate-message.sh - Validate Commit Message

**Purpose**: Validate commit message format against Conventional Commits spec.

**Syntax**: `validate-message.sh [file | -]`

**Examples**:
```bash
# Validate from file
validate-message.sh commit.txt

# Validate from stdin
echo "feat: add new feature" | validate-message.sh

# Validate from heredoc
validate-message.sh <<EOF
feat(auth): add JWT support

Implement JWT token generation and validation.

Fixes #123
EOF

# Use in pre-commit hook
validate-message.sh .git/COMMIT_EDITMSG
```

**Exit Codes**:
- `0` - Valid commit message
- `1` - Invalid format
- `2` - Invalid arguments

**Validation Rules**:
- Type must be recognized
- Subject line ≤ 50 characters
- Body lines ≤ 72 characters
- Blank line between subject and body
- Imperative mood (basic check)

### 4. commit-types.sh - List Commit Types

**Purpose**: Display commit types with descriptions and examples.

**Syntax**: `commit-types.sh [options]`

**Examples**:
```bash
# Display all types
commit-types.sh

# JSON output
commit-types.sh --json

# Filter by type
commit-types.sh --type=feat

# With scope examples
commit-types.sh --examples
```

**Output Formats**:
- **Default**: Human-readable table
- **JSON**: Structured data for tooling

### 5. commit-interactive.sh - Interactive Builder

**Purpose**: Interactive TUI for building commit messages.

**Syntax**: `commit-interactive.sh [options]`

**Examples**:
```bash
# Interactive builder
commit-interactive.sh

# Pre-fill type
commit-interactive.sh --type=feat

# Skip analysis
commit-interactive.sh --no-analyze

# Preview only (don't generate)
commit-interactive.sh --preview
```

**Workflow**:
1. Shows git change analysis
2. Select commit type from menu
3. Prompt for optional scope
4. Enter description
5. Optionally add body
6. Optionally add footers
7. Show preview
8. Confirm and generate

## Advanced Patterns

### Multi-Paragraph Body

```
feat(api): add pagination support

Add pagination to all list endpoints for better performance
and user experience.

Implementation uses cursor-based pagination with configurable
page sizes. Default page size is 20 items.

API clients should use the 'next' link in response for
subsequent pages.

Fixes #234
Refs #235
```

### Multiple Footers

```
fix(security): update authentication library

BREAKING CHANGE: Minimum supported version is now Node 18
Fixes #456
Refs #457
Co-authored-by: Jane Smith <jane@example.com>
```

### Breaking Change Indicator

```
feat(api)!: redesign user endpoint

Complete redesign of /users endpoint structure.

BREAKING CHANGE: Response format changed from array to object
with 'data' and 'meta' fields. Update API clients accordingly.
```

### Bullet Lists in Body

```
refactor(ui): reorganize component structure

Restructure components for better maintainability:

- Move shared components to common/
- Split large components into smaller units
- Add component documentation
- Update import paths

No functional changes.
```

## Real-World Examples

### Feature Development

**Simple Feature**:
```
feat(auth): add password reset flow
```

**Complex Feature**:
```
feat(notifications): add real-time push notifications

Implement WebSocket-based push notifications for user events.

Features:
- Connection management with automatic reconnection
- Event filtering by user preferences
- Notification history persistence
- Rate limiting per user

Uses Socket.io for WebSocket handling with fallback to
long-polling for older browsers.

Fixes #789
```

### Bug Fixes

**Simple Fix**:
```
fix(parser): handle empty input correctly
```

**Complex Fix**:
```
fix(database): prevent connection pool exhaustion

Fix connection leak in error handling paths.

The database connection pool was not releasing connections
when queries threw exceptions. This caused gradual pool
exhaustion under high error rates.

Added proper connection cleanup in try-finally blocks
and reduced default pool size to surface issues earlier.

Fixes #1001
Refs #1002
```

### Documentation

**Simple Doc Change**:
```
docs: update installation instructions
```

**Complex Doc Update**:
```
docs(api): add authentication guide

Add comprehensive guide for API authentication covering:

- OAuth2 flow setup
- API key management
- Token refresh patterns
- Error handling examples
- Security best practices

Includes code examples in Python, JavaScript, and Go.

Closes #567
```

### Refactoring

**Simple Refactor**:
```
refactor(utils): extract validation helpers
```

**Major Refactor**:
```
refactor(core): migrate to async/await

Replace callback-based async patterns with async/await
throughout the codebase.

Changes:
- Convert all Promise chains to async/await
- Update error handling to use try-catch
- Simplify control flow in complex operations
- Remove callback utility functions

No functional changes. All existing tests pass.

Refs #888
```

### Performance

```
perf(database): add indexes for frequent queries

Add composite indexes for user lookup queries.

Measured improvements:
- User search by email: 450ms → 12ms
- Active user count: 2300ms → 45ms
- User permissions check: 180ms → 8ms

Indexes added to users table on (email, active) and
(role_id, created_at).

Refs #999
```

### Build/CI

```
ci(github): parallelize test suite

Split test suite into parallel jobs for faster CI runs.

Reduces total CI time from 12 minutes to 4 minutes by
running unit, integration, and e2e tests concurrently.

Each job uses isolated database for test isolation.
```

### Tests

```
test(auth): add edge cases for token validation

Add tests for:
- Expired tokens
- Malformed tokens
- Tokens with invalid signatures
- Tokens with missing claims

Increases auth module coverage from 78% to 94%.
```

## Troubleshooting

### Common Mistakes

**Past Tense (Wrong)**:
```
feat: added new feature  ❌
fix: fixed bug in parser  ❌
```

**Correct Form**:
```
feat: add new feature  ✓
fix: handle parser edge case  ✓
```

**Capitalized Description (Wrong)**:
```
feat: Add new feature  ❌
```

**Correct Form**:
```
feat: add new feature  ✓
```

**Period at End (Wrong)**:
```
feat: add new feature.  ❌
```

**Correct Form**:
```
feat: add new feature  ✓
```

**No Type (Wrong)**:
```
add new feature  ❌
```

**Correct Form**:
```
feat: add new feature  ✓
```

**Subject Too Long (Wrong)**:
```
feat: add comprehensive authentication system with OAuth2 and JWT support  ❌
```

**Correct Form**:
```
feat: add OAuth2 and JWT authentication

Implement comprehensive authentication system supporting
both OAuth2 and JWT token-based auth.  ✓
```

### Validation Errors

**Error: Invalid type**
```
Solution: Use one of: feat, fix, docs, style, refactor, perf, test, build, ci, chore
```

**Error: Subject too long**
```
Solution: Keep subject under 50 chars, move details to body
```

**Error: Missing blank line**
```
Solution: Add blank line between subject and body
```

**Error: Body line too long**
```
Solution: Wrap body lines at 72 characters
```

### Choosing the Right Type

**feat vs fix**:
- `feat`: Adds new functionality
- `fix`: Repairs existing functionality

**refactor vs perf**:
- `refactor`: Restructures code without changing behavior
- `perf`: Improves performance (measurable change)

**docs vs chore**:
- `docs`: User-facing documentation (README, API docs)
- `chore`: Internal docs, tooling, configs

**build vs ci**:
- `build`: Build system, dependencies (package.json, Cargo.toml)
- `ci`: CI/CD configs (.github/workflows, .travis.yml)

**test vs fix**:
- `test`: Adding/modifying tests without fixing bugs
- `fix`: Fixing bugs (even if discovered via tests)

## Integration Patterns

### Pre-Commit Hook

Create `.git/hooks/commit-msg`:
```bash
#!/bin/bash

# Validate commit message format
COMMIT_MSG_FILE=$1

if ! @wizact-dev-essentials/skills/generate-commit-message/scripts/validate-message.sh "$COMMIT_MSG_FILE"; then
    echo "Commit message validation failed!" >&2
    echo "Use Conventional Commits format:" >&2
    echo "  <type>[scope]: <description>" >&2
    exit 1
fi
```

Make executable:
```bash
chmod +x .git/hooks/commit-msg
```

### Prepare Commit Message Hook

Create `.git/hooks/prepare-commit-msg`:
```bash
#!/bin/bash

COMMIT_MSG_FILE=$1
COMMIT_SOURCE=$2

# Only generate for normal commits (not merge, squash, etc.)
if [ -z "$COMMIT_SOURCE" ] || [ "$COMMIT_SOURCE" = "message" ]; then
    # Generate suggested commit message
    SUGGESTION=$(@wizact-dev-essentials/skills/generate-commit-message/scripts/analyze-changes.sh --suggest)

    # Prepend suggestion as comment
    echo "# Suggested: $SUGGESTION" > "$COMMIT_MSG_FILE.new"
    cat "$COMMIT_MSG_FILE" >> "$COMMIT_MSG_FILE.new"
    mv "$COMMIT_MSG_FILE.new" "$COMMIT_MSG_FILE"
fi
```

### Git Alias

Add to `~/.gitconfig`:
```ini
[alias]
    cm = "!f() { \
        @wizact-dev-essentials/skills/generate-commit-message/scripts/commit-interactive.sh; \
    }; f"

    analyze = "!@wizact-dev-essentials/skills/generate-commit-message/scripts/analyze-changes.sh"

    types = "!@wizact-dev-essentials/skills/generate-commit-message/scripts/commit-types.sh"
```

Usage:
```bash
git cm              # Interactive commit builder
git analyze         # Analyze changes
git types           # Show commit types
```

### CI/CD Validation

GitHub Actions workflow:
```yaml
name: Validate Commits

on: [pull_request]

jobs:
  validate-commits:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Validate commit messages
        run: |
          for commit in $(git rev-list origin/main..HEAD); do
            msg=$(git log --format=%B -n 1 $commit)
            echo "$msg" | ./scripts/validate-message.sh || exit 1
          done
```

### Changelog Generation

Generate changelog from conventional commits:
```bash
#!/bin/bash

# Extract commits by type
git log --pretty=format:"%s" origin/main..HEAD | while read line; do
    if [[ $line =~ ^feat(\(.*\))?: ]]; then
        echo "- ${line#feat*: }" >> CHANGELOG_features.txt
    elif [[ $line =~ ^fix(\(.*\))?: ]]; then
        echo "- ${line#fix*: }" >> CHANGELOG_fixes.txt
    fi
done

# Combine into changelog
cat <<EOF > CHANGELOG.md
# Changelog

## Features
$(cat CHANGELOG_features.txt 2>/dev/null || echo "None")

## Bug Fixes
$(cat CHANGELOG_fixes.txt 2>/dev/null || echo "None")
EOF
```

## Best Practices

### Commit Granularity

**Too Large (Anti-pattern)**:
```
feat: implement user management system

Added users, roles, permissions, authentication, authorization,
user profile pages, admin panel, audit logging, and email
notifications.
```

**Better Approach** (Atomic commits):
```
feat(auth): add user authentication
feat(auth): add role-based permissions
feat(ui): add user profile pages
feat(admin): add user management panel
feat(audit): add action logging
feat(email): add user notification system
```

### Scope Guidelines

**Good Scopes**:
- Module/package names: `auth`, `api`, `database`
- Feature areas: `user`, `payment`, `search`
- Components: `header`, `sidebar`, `modal`
- Tools: `cli`, `parser`, `compiler`

**Avoid**:
- File names: `user.js` → use `user` or `api`
- Too specific: `login-button` → use `auth` or `ui`
- Too generic: `misc`, `other`, `stuff`

### Body Content

**What to Include**:
- Motivation for the change
- Contrast with previous behavior
- Side effects and consequences
- Performance implications
- Migration instructions (for breaking changes)

**What to Avoid**:
- Implementation details (code explains this)
- Obvious information
- Unrelated commentary

### Footer Usage

**Issue References**:
- `Fixes #123` - Closes issue (use for bug fixes)
- `Closes #123` - Closes issue (use for features)
- `Refs #123` - References issue (doesn't close)

**Multiple Issues**:
```
Fixes #123, #124, #125
```

**Co-authorship**:
```
Co-authored-by: John Doe <john@example.com>
Co-authored-by: Jane Smith <jane@example.com>
```

### Breaking Changes

**When to Use**:
- API contract changes
- Removed features
- Changed default behavior
- Incompatible data format changes

**Format**:
```
feat(api)!: change response format

BREAKING CHANGE: API responses now use snake_case instead of
camelCase. Update clients to handle new field naming.

Migration guide: https://docs.example.com/migration/v2
```

This reference covers the essential aspects of using the generate-commit-message skill effectively. For specification updates, refer to https://www.conventionalcommits.org/
