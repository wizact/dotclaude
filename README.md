# Claude Code Extensions

A marketplace-based collection of reusable plugins providing agents, skills, and commands for Claude Code.

## Purpose

This repository provides a structured marketplace for Claude Code extensions that can be integrated into any project. Organized as a proper marketplace with plugins, templates, and conventions to standardize development workflows.

## Repository Structure

```
dotclaude/
├── wizact-marketplace/           # Plugin marketplace
│   └── plugins/
│       └── wizact-dev-essentials/  # Core development plugin
│           ├── agents/              # Specialized agents
│           ├── commands/            # Slash commands
│           ├── skills/              # Reusable skills
│           └── README.md
├── TEMPLATES/                    # Reusable templates
│   ├── context-docs/            # Context documentation templates
│   └── conventions/             # Language conventions
│       ├── go/                  # Go coding standards
│       └── python/              # Python coding standards
└── README.md
```

## Installation

### Prerequisites

Install required system tools:

```bash
# macOS
brew install fd ripgrep

# Linux (Debian/Ubuntu)
apt install fd-find ripgrep
```

### Setup

```bash
# Clone the repository
git clone --bare https://github.com/wizact/dotclaude.git ~/dev/github.com/wizact/dotclaude
cd ~/dev/github.com/wizact/dotclaude

# For machine-specific configurations (recommended)
git worktree add <your-machine-name> main
cd <your-machine-name>
```

### Plugin Installation

```
/plugin 
```

Install the `wizact-marketplace` on your machine.
Install the `wizact-dev-essentials` plugin.

See [wizact-dev-essentials/README.md](wizact-marketplace/plugins/wizact-dev-essentials/README.md) for detailed plugin documentation.

## What's Included

### Plugins

#### wizact-dev-essentials

Essential development tools plugin providing:

**Commands** (2):
- `/generate-commit-message` - Generate Conventional Commits formatted messages
- `/search-code` - Smart code pattern search

**Skills** (5):
- `fd-search` - Lightning-fast file system search using `fd`
- `ripgrep-search` - Blazing-fast code search using `ripgrep`
- `go-developer` - Go development best practices and idiomatic patterns
- `test-driven-development` - TDD red-green-refactor discipline enforcement
- `setup-context-docs` - Context-driven development documentation setup

**Agents** (3):
- `developer` - Multi-language dispatcher (Go, Python) with best practices
- `go-reviewer` - Proactive code review for Go projects
- `specbuilder` - Feature specification builder from issues/PRs

### Templates

#### Context Documentation (`TEMPLATES/context-docs/`)
- Feature specification templates (requirements, design, tasks)
- Example feature structure (f002-uuid-multi-repo)
- Setup via `/setup-context-docs` skill

#### Language Conventions (`TEMPLATES/conventions/`)
- **Go** (`go/conventions.md`) - Go coding standards and patterns
- **Python** (`python/conventions.md`) - Python coding standards and patterns

## Usage

### Quick Start

```bash
# Generate commit message
/generate-commit-message

# Search code
/search-code "pattern"

# Setup project documentation
/setup-context-docs
```

### Using Agents

Agents are available via Claude Code's Task tool:

```python
# Auto-detect language and apply best practices
Task(subagent_type="wizact-dev-essentials:developer", prompt="Implement feature X")

# Or invoke skill directly
Skill(skill="wizact-dev-essentials:go-developer")

# Use specbuilder agent
Task(subagent_type="wizact-dev-essentials:specbuilder", prompt="Create spec for issue #123")
```

See individual component documentation for detailed usage:
- [Plugin README](wizact-marketplace/plugins/wizact-dev-essentials/README.md)
- [fd-search](wizact-marketplace/plugins/wizact-dev-essentials/skills/fd-search/SKILL.md)
- [ripgrep-search](wizact-marketplace/plugins/wizact-dev-essentials/skills/ripgrep-search/skill.md)

## License

MIT - See [LICENSE](LICENSE)

## Links

- **Repository**: https://github.com/wizact/dotclaude
- **Issues**: https://github.com/wizact/dotclaude/issues
- **Author**: [wizact](https://github.com/wizact)
