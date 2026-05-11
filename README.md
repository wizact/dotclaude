# Wizact Agent Extensions

A marketplace-based collection of reusable plugins providing agents, skills,
commands, and hooks for Claude Code and Codex.

## Purpose

This repository provides structured marketplaces for Claude Code and Codex
extensions that can be integrated into any project. It organizes plugins,
templates, and conventions to standardize development workflows across both
agent runtimes.

## Repository Structure

```
dotclaude/
├── .agents/
│   └── plugins/
│       └── marketplace.json        # Codex marketplace catalog
├── wizact-marketplace/           # Plugin marketplace
│   ├── .claude-plugin/
│   │   └── marketplace.json        # Claude Code marketplace catalog
│   └── plugins/
│       ├── wizact-dev-essentials/  # Core development plugin
│       │   ├── agents/              # Specialized agents
│       │   ├── skills/              # Reusable skills
│       │   ├── .claude-plugin/      # Claude Code plugin manifest
│       │   └── .codex-plugin/       # Codex plugin manifest
│       ├── wizact-utilities/        # System utilities plugin
│       │   ├── skills/              # Utility skills
│       │   ├── hooks/               # Custom hooks
│       │   ├── .claude-plugin/      # Claude Code plugin manifest
│       │   └── .codex-plugin/       # Codex plugin manifest
│       └── speculator/              # Specification builder plugin
│           ├── agents/              # Spec agents
│           ├── skills/              # Spec skills
│           ├── .claude-plugin/      # Claude Code plugin manifest
│           └── .codex-plugin/       # Codex plugin manifest
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

#### Claude Code

```
/plugin 
```

Install the `wizact-marketplace` on your machine.
Install desired plugins: `wizact-dev-essentials`, `wizact-utilities`, `speculator`.

#### Codex

Codex discovers the local marketplace from `.agents/plugins/marketplace.json`.
The catalog points to the `.codex-plugin/plugin.json` manifests for each
plugin:

- `wizact-dev-essentials`
- `wizact-utilities`
- `speculator`

See [wizact-dev-essentials/README.md](wizact-marketplace/plugins/wizact-dev-essentials/README.md) for detailed plugin documentation.

## What's Included

### Plugins

#### wizact-dev-essentials

Essential development tools plugin providing:

**Skills** (5):
- `generate-commit-message` - Generate Conventional Commits formatted messages
- `go-developer` - Go development best practices and idiomatic patterns
- `python-developer` - Python development best practices and Pythonic patterns
- `test-driven-development` - TDD red-green-refactor discipline enforcement
- `worktree` - Git worktree workflow automation

**Agents** (2):
- `developer` - Multi-language dispatcher (Go, Python) with best practices
- `go-reviewer` - Proactive code review for Go projects

#### wizact-utilities

System utilities plugin providing:

**Skills** (3):
- `fd-search` - Lightning-fast file system search using `fd`
- `ripgrep-search` - Blazing-fast code search using `ripgrep`
- `bump-plugin-version` - Automatic semantic version bumping for plugins

#### speculator

Comprehensive specification builder plugin providing:

**Skills** (7):
- `spec-setup` - Initialize project documentation structure
- `spec-context` - Parse GitHub issues/PRs and gather context
- `spec-requirements` - Generate requirements.md with EARS notation
- `spec-design` - Generate design.md with architecture
- `spec-tasks` - Generate tasks.md with trackable work items
- `spec-verify` - Verify implementation completeness
- `spec-finalize` - Finalize spec package with cross-links

**Agents** (1):
- `specbuilder` - ⚠️ DEPRECATED: Use individual skills instead


## Usage

### Quick Start

```bash
# Generate commit message (wizact-dev-essentials skill)
/generate-commit-message

# Search files (wizact-utilities skill)
/fd-search "*.go"

# Search code (wizact-utilities skill)
/ripgrep-search "pattern"

# Setup project documentation (speculator skill)
/spec-setup
```

### Using Agents

Agents are available via Claude Code's Agent tool and Codex sub-agents where
the runtime supports them:

```python
# Auto-detect language and apply best practices
Agent(subagent_type="wizact-dev-essentials:developer", prompt="Implement feature X")

# Go code review agent (auto-invoked after Go code changes)
Agent(subagent_type="wizact-dev-essentials:go-reviewer", prompt="Review recent changes")

# Specbuilder agent (DEPRECATED - use individual /spec-* skills)
Agent(subagent_type="speculator:specbuilder", prompt="Create spec for issue #123")
```

See individual plugin documentation for detailed usage:
- [wizact-dev-essentials](wizact-marketplace/plugins/wizact-dev-essentials/)
- [wizact-utilities](wizact-marketplace/plugins/wizact-utilities/README.md)
- [speculator](wizact-marketplace/plugins/speculator/)

## License

MIT - See [LICENSE](LICENSE)

## Links

- **Repository**: https://github.com/wizact/dotclaude
- **Issues**: https://github.com/wizact/dotclaude/issues
- **Author**: [wizact](https://github.com/wizact)
