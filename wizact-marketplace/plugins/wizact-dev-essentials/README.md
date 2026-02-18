# Wizact Dev Essentials

Essential development tools plugin for Claude Code, providing fast search capabilities, git workflow helpers, Go development agents, and documentation setup utilities.

## Features

### 🔍 Fast Search Tools
- **fd-search**: Lightning-fast file system search using `fd`
- **ripgrep-search**: Blazing-fast code search using `ripgrep`
- **search-code**: Smart code search command combining both tools

### 📝 Git Workflow
- **generate-commit-message**: Generate Conventional Commits formatted messages (skill)

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

Skills are automatically available to Claude agents when the plugin is loaded. Some skills are **agent-auto-invoked** (replacing bash commands), while others are **user-invocable** via `/skill-name`.

#### `fd-search` (Agent Auto-Invoked + User-Invocable)
**Replaces bash `find` command** - Agents automatically use this for file searches.
Fast file system search. See [skills/fd-search/SKILL.md](skills/fd-search/SKILL.md) for details.

**User Invocation**:
```bash
/fd-search pattern [directory]
```

**Scripts**:
```bash
# Find JavaScript files
@wizact-dev-essentials/skills/fd-search/scripts/find-by-extension.sh js

# Find large files
@wizact-dev-essentials/skills/fd-search/scripts/find-large-files.sh

# Find recent files
@wizact-dev-essentials/skills/fd-search/scripts/find-recent.sh 1day
```

#### `ripgrep-search` (Agent Auto-Invoked + User-Invocable)
**Replaces bash `grep` command** - Agents automatically use this for text searches.
Ultra-fast code search. See [skills/ripgrep-search/skill.md](skills/ripgrep-search/skill.md) for details.

**User Invocation**:
```bash
/ripgrep-search pattern [path]
```

**Scripts**:
```bash
# Search code with context
@wizact-dev-essentials/skills/ripgrep-search/scripts/search-context.sh "TODO"

# Search logs
@wizact-dev-essentials/skills/ripgrep-search/scripts/search-logs.sh "ERROR"

# Multiline search
@wizact-dev-essentials/skills/ripgrep-search/scripts/search-multiline.sh "struct.*{"
```

#### `generate-commit-message` (User-Invocable)
Generate Conventional Commits formatted messages. See [skills/generate-commit-message/skill.md](skills/generate-commit-message/skill.md) for details.

**Invocation**:
```bash
# User can invoke via slash command
/generate-commit-message

# Claude auto-loads when discussing commits
```

**Scripts**:
```bash
# Analyze staged changes
@wizact-dev-essentials/skills/generate-commit-message/scripts/analyze-changes.sh

# Generate commit message
@wizact-dev-essentials/skills/generate-commit-message/scripts/generate-message.sh feat auth "add JWT support"

# Validate commit format
@wizact-dev-essentials/skills/generate-commit-message/scripts/validate-message.sh <<< "feat: add feature"

# List commit types
@wizact-dev-essentials/skills/generate-commit-message/scripts/commit-types.sh

# Interactive builder
@wizact-dev-essentials/skills/generate-commit-message/scripts/commit-interactive.sh
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
