# Wizact Dev Essentials

Essential development tools plugin for Claude Code, providing fast search capabilities, git workflow helpers, Go development agents, and documentation setup utilities.

## Features

### 🔍 Fast Search Tools
- **fd-search**: Lightning-fast file system search using `fd`
- **ripgrep-search**: Blazing-fast code search using `ripgrep`
- **search-code**: Smart code search command combining both tools

### 📝 Git Workflow
- **commit-message**: Generate Conventional Commits formatted messages

### 🛠️ Go Development
- **go-developer**: Comprehensive Go development agent with best practices
- **go-reviewer**: Code review agent for Go projects
- **specbuilder**: Feature specification builder for structured planning

### 📚 Documentation
- **setup-context-docs**: Context-driven development documentation setup

## Installation

### Prerequisites

Install required system tools:

```bash
# macOS
brew install fd ripgrep

# Linux (Debian/Ubuntu)
apt install fd-find ripgrep

# Linux (Fedora)
dnf install fd-find ripgrep
```

### Plugin Installation

#### Option 1: Add to settings.json (Recommended)

Add to `~/.claude/settings.json`:

```json
{
  "plugins": [
    "~/dev/github.com/wizact/dotclaude/mac/wizact-dev-essentials"
  ]
}
```

#### Option 2: Symlink to plugins directory

```bash
ln -s ~/dev/github.com/wizact/dotclaude/mac/wizact-dev-essentials ~/.claude/plugins/wizact-dev-essentials
```

## Usage

### Commands

#### `/commit-message`
Generate structured git commit messages:
```bash
# Stage your changes first
git add .

# Generate commit message
/commit-message
```

#### `/search-code`
Smart code search across project:
```bash
/search-code <pattern>
```

#### `/setup-context-docs`
Initialize context documentation for project:
```bash
/setup-context-docs
```

### Skills

Skills are automatically available to Claude agents when the plugin is loaded.

#### `fd-search`
Fast file system search. See [skills/fd-search/SKILL.md](skills/fd-search/SKILL.md) for details.

Example scripts:
```bash
# Find JavaScript files
@wizact-dev-essentials/skills/fd-search/scripts/find-by-extension.sh js

# Find large files
@wizact-dev-essentials/skills/fd-search/scripts/find-large-files.sh

# Find recent files
@wizact-dev-essentials/skills/fd-search/scripts/find-recent.sh 1day
```

#### `ripgrep-search`
Ultra-fast code search. See [skills/ripgrep-search/skill.md](skills/ripgrep-search/skill.md) for details.

Example scripts:
```bash
# Search code with context
@wizact-dev-essentials/skills/ripgrep-search/scripts/search-context.sh "TODO"

# Search logs
@wizact-dev-essentials/skills/ripgrep-search/scripts/search-logs.sh "ERROR"

# Multiline search
@wizact-dev-essentials/skills/ripgrep-search/scripts/search-multiline.sh "struct.*{"
```

### Agents

Agents are available via the Task tool with `subagent_type` parameter.

#### `go-developer`
Specialized agent for Go development following best practices, proper architecture, testing, and security.

#### `go-reviewer`
Proactive code review agent for Go projects, ensuring quality and adherence to standards.

#### `specbuilder`
Creates complete feature/bug specifications from GitHub issues, PRs, or user prompts.

## License

MIT

## Author

[wizact](https://github.com/wizact)

## Repository

https://github.com/wizact/dotclaude
