# Wizact Dev Essentials

Essential development tools plugin for Claude Code and Codex, providing fast
search capabilities, git workflow helpers, and Go development agents.

## Breaking Changes (v3.0.0)

Spec builder skills moved to `speculator` plugin.

**Removed**:
- spec-context, spec-requirements, spec-design, spec-tasks, spec-finalize, spec-verify, spec-setup (formerly setup-context-docs)
- specbuilder agent

**Migration**: Install `speculator` plugin (same marketplace)

## Features

### 🔍 Fast Search Tools
- **fd-search**: Lightning-fast file system search using `fd`
- **ripgrep-search**: Blazing-fast code search using `ripgrep`
- **search-code**: Smart code search command combining both tools

### 📝 Git Workflow
- **generate-commit-message**: Generate Conventional Commits formatted messages (skill)

### 🛠️ Go Development
- **developer**: Language-aware dispatcher agent (auto-detects Go projects)
- **go-reviewer**: Code review agent for Go projects

## Installation

The plugin includes both `.claude-plugin/plugin.json` and
`.codex-plugin/plugin.json` manifests.

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

#### Claude Code: Add to settings.json (Recommended)

Add to `~/.claude/settings.json`:

```json
{
  "plugins": [
    "~/dev/github.com/wizact/dotclaude/main/wizact-dev-essentials"
  ]
}
```

#### Claude Code: Symlink to plugins directory

```bash
ln -s ~/dev/github.com/wizact/dotclaude/main/wizact-dev-essentials ~/.claude/plugins/wizact-dev-essentials
```

#### Codex

Install through the repository-level Codex marketplace catalog at
`.agents/plugins/marketplace.json`.

## Usage

### Skills

Skills are automatically available to Claude Code and Codex agents when the
plugin is loaded. Some skills are **agent-auto-invoked** (replacing bash
commands), while others are **user-invocable** via `/skill-name`.

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

#### `developer`
Language-aware dispatcher agent that auto-detects project context. For Go and Python projects, provides comprehensive development guidance with best practices, architecture, testing, and security.

**Direct skill access**: `Skill(skill='go-developer')` explicitly invokes Go development guidance.

#### `go-reviewer`
Proactive code review agent for Go projects, ensuring quality and adherence to standards.

## License

MIT

## Author

[wizact](https://github.com/wizact)

## Repository

https://github.com/wizact/dotclaude
