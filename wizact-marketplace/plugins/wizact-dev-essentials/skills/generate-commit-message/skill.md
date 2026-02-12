---
name: generate-commit-message
description: Generate meaningful git commit messages following Conventional Commits and best practices
disable-model-invocation: false
user-invocable: true
---

# Commit Message Generator

Generate meaningful git commit messages following **Conventional Commits** format and git best practices.

## When User Invokes `/generate-commit-message`

1. **Analyze the current git state**:
   - Run `git status` to see staged and unstaged changes
   - Run `git diff --cached` to examine staged changes in detail
   - Run `git diff` to see unstaged changes (if any)

2. **Generate a structured commit message** using Conventional Commits format:
   - Choose appropriate type: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`
   - Add scope when helpful (e.g., `auth`, `api`, `ui`, `database`)
   - Write clear, imperative description under 50 characters
   - Include body and footer when needed for context

3. **Follow formatting best practices**:
   - Use imperative mood ("add" not "added")
   - Keep subject line under 50 characters
   - Wrap body at 72 characters
   - Include issue references (`Fixes #123`)
   - Document breaking changes (`BREAKING CHANGE:`)

4. **Provide explanation** of type and scope choices

5. **Offer alternatives** and allow refinement

Always ensure commits are atomic (one logical change) and provide meaningful context for future developers.

## Conventional Commits Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

## Commit Types

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
