---
name: generate-commit-message
description: Generate meaningful git commit messages following Conventional Commits and best practices
disable-model-invocation: false
user-invocable: true
---

# Commit Message Skill

Specialized assistant for generating meaningful git commit messages following **Conventional Commits** format and git best practices. Expertise focuses on analyzing code changes, selecting appropriate commit types, and crafting clear, atomic commit messages.

> **Reference Guide**: For comprehensive examples, patterns, and troubleshooting, see @wizact-dev-essentials/skills/generate-commit-message/REFERENCE.md

## Core Capabilities

1. **Analyze git state** - staged/unstaged changes, file statistics, change types
2. **Generate structured messages** - Conventional Commits format with type, scope, description
3. **Validate commit format** - ensure compliance with specification and line length rules
4. **Interactive commit builder** - guided TUI for constructing commit messages
5. **Commit type reference** - list types with descriptions and scope examples

## Quick Start Scripts

This skill includes 5 essential scripts for commit message workflows:

1. **analyze-changes.sh** - Analyze staged/unstaged changes with file stats
2. **generate-message.sh** - Generate commit message from parameters
3. **validate-message.sh** - Validate commit message format
4. **commit-types.sh** - List/explain commit types with examples
5. **commit-interactive.sh** - Interactive commit message builder

Usage: `@wizact-dev-essentials/skills/generate-commit-message/scripts/script-name.sh --help` for each script.

## Key Advantages

- **Consistent format**: Enforces Conventional Commits across team
- **Better history**: Searchable, structured commit log
- **Automation-friendly**: Parseable format for changelog generation
- **Clearer intent**: Explicit type/scope shows purpose at a glance
- **Atomic commits**: Encourages one logical change per commit

## Core Workflow

### When User Invokes `/generate-commit-message`

1. **Analyze git state**:
   - Run `git status` for staged/unstaged changes
   - Run `git diff --cached` for staged change details
   - Run `git diff` for unstaged changes (if any)

2. **Generate structured message** using Conventional Commits:
   - Choose type: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`
   - Add scope when helpful (e.g., `auth`, `api`, `ui`, `database`)
   - Write clear, imperative description under 50 characters
   - Include body/footer when needed for context

3. **Follow formatting rules**:
   - Imperative mood ("add" not "added")
   - Subject line under 50 characters
   - Body wrapped at 72 characters
   - Issue references (`Fixes #123`)
   - Breaking changes (`BREAKING CHANGE:`)

4. **Provide explanation** of type/scope choices

5. **Offer alternatives** and allow refinement

## Conventional Commits Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Commit Types

- **feat**: New features or functionality
- **fix**: Bug fixes
- **docs**: Documentation changes only
- **style**: Code style changes (formatting, semicolons, etc.)
- **refactor**: Code restructuring without changing functionality
- **perf**: Performance improvements
- **test**: Adding or updating tests
- **build**: Build system or dependency changes
- **ci**: CI/CD configuration changes
- **chore**: Maintenance tasks, tooling

## Best Practices

### Do:
- **Use imperative mood** - "add feature" not "added feature"
- **Keep subject concise** - under 50 characters for readability
- **Add scope for clarity** - helps categorize changes by module/area
- **Reference issues** - link to tracking issues with `Fixes #123`
- **Document breaking changes** - use `BREAKING CHANGE:` footer
- **Make atomic commits** - one logical change per commit

### Don't:
- **Don't use past tense** - "added" or "fixed" is incorrect
- **Don't exceed line limits** - subject > 50 chars or body > 72 chars hurts readability
- **Don't mix concerns** - keep refactoring separate from feature work
- **Don't omit type** - always include a valid commit type
- **Don't add AI attribution** - per user preferences, no "Generated with Claude Code" footers
- **Don't be vague** - "fix bug" or "update code" provides no context

## Quick Script Examples

For immediate use, try these common scenarios:

```bash
# Analyze current changes
@wizact-dev-essentials/skills/generate-commit-message/scripts/analyze-changes.sh

# Generate a commit message
@wizact-dev-essentials/skills/generate-commit-message/scripts/generate-message.sh feat auth "add JWT support"

# Validate a commit message
@wizact-dev-essentials/skills/generate-commit-message/scripts/validate-message.sh <<< "feat(auth): add JWT support"

# List commit types
@wizact-dev-essentials/skills/generate-commit-message/scripts/commit-types.sh

# Interactive builder
@wizact-dev-essentials/skills/generate-commit-message/scripts/commit-interactive.sh
```

## Integration with Scripts

When creating commits programmatically:
1. **Error handling**: Validate inputs before generating messages
2. **User preferences**: Respect `.claude/CLAUDE.md` settings (no AI footers)
3. **Format validation**: Use `validate-message.sh` before committing
4. **Atomic changes**: Ensure staged changes represent one logical unit
5. **Signed commits**: Use `-S` flag when user config requires it

Remember: Commit messages are for future developers (including yourself). Clarity and consistency matter more than brevity. When in doubt, include more context in the body rather than cramming details into the subject line.
