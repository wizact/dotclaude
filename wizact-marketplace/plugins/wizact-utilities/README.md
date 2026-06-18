# wizact-utilities

Essential developer utilities: fast file/code search, desktop notifications, and version management for Claude Code and Codex on macOS.

## Features

### 🔍 Fast Search Skills
- **fd-search**: Ultra-fast file finding (10-100x faster than `find`)
- **ripgrep-search**: Blazing fast code/text search (10-100x faster than `grep`)
- **ast-grep-search**: Semantic code search by AST structure - NEW! ⭐

### 🔔 Notification Hooks
- Desktop notifications when Claude waits for input (60s+ idle)
- Permission request alerts
- MCP tool input notifications
- Session name in notification title (detected from `--name`/`--resume` flags or tmux window name)
- Click-to-activate: clicking the notification brings the terminal back to focus (requires growlrrr)
- Tmux window switching: clicking the notification switches to the correct tmux window (requires growlrrr)

### 🔧 Version Management
- **bump-plugin-version**: Automatically bump plugin versions following semantic versioning

## Installation
The plugin includes both `.claude-plugin/plugin.json` and
`.codex-plugin/plugin.json` manifests.

### Claude Code

Add to `~/.claude/settings.json`:
```json
{
  "plugins": [
    "~/dev/github.com/wizact/dotclaude/mac/wizact-marketplace/plugins/wizact-utilities"
  ]
}
```
Then restart Claude session.

### Codex

Install through the repository-level Codex marketplace catalog at
`.agents/plugins/marketplace.json`.

## Notification Tool Setup

The notification hooks use the best available tool on your system. Install one of the following for the best experience:

### Recommended: growlrrr

[growlrrr](https://github.com/moltenbits/growlrrr) is a modern macOS notification tool that supports click-to-activate and command execution on click -- both of which work on macOS Sequoia and later.

```bash
brew tap moltenbits/tap && brew install growlrrr
```

See the [growlrrr GitHub page](https://github.com/moltenbits/growlrrr) for other installation options.

With growlrrr installed, clicking a notification will:
1. Reactivate the originating terminal window
2. Switch to the correct tmux window (if running inside tmux)

### Alternative: terminal-notifier

```bash
brew install terminal-notifier
```

Note: `terminal-notifier`'s `-execute` and `-activate` flags are broken on macOS Sequoia+. Notifications will display with session names but clicking them will not activate the terminal or switch tmux windows. The tmux window index is shown in the notification body as `[tmux:N]` instead.

### Fallback: osascript

If neither tool is installed, notifications are sent via `osascript display notification`. Session names are included in the title, but there is no click action support.

## Requirements

### System
- macOS 13.0+ (Ventura or later for growlrrr, earlier versions work with terminal-notifier/osascript)

### Optional Dependencies

**For ast-grep-search skill:**
- `ast-grep` (install via `brew install ast-grep`, `npm install -g @ast-grep/cli`, or `pip install ast-grep-cli`)
  - Required only if you want to use semantic AST-based code search
  - The skill will check for installation and guide you through setup if not found

**For fd-search skill:**
- `fd` (install via `brew install fd-find`)
  - Auto-invoked instead of bash `find` for faster file searches

**For ripgrep-search skill:**
- `ripgrep` (install via `brew install ripgrep`)
  - Auto-invoked instead of bash `grep` for faster text searches

## Skills

### `fd-search` (User-Invocable)
Ultra-fast file search - REQUIRED instead of bash `find`.

**Usage**: Automatically invoked for file searches. 10-100x faster than `find`, respects .gitignore, simple syntax.

**Manual Invocation**:
```bash
/fd-search [pattern] [path]
```

### `ripgrep-search` (User-Invocable)  
Blazing fast code/text search - REQUIRED instead of bash `grep`.

**Usage**: Automatically invoked for text searches. 10-100x faster than grep, respects .gitignore, Unicode support.

**Manual Invocation**:
```bash
/ripgrep-search [pattern] [path]
```

### `ast-grep-search` (User-Invocable) ⭐ NEW
Semantic code search using AST pattern matching.

**Requires**: `ast-grep` CLI tool

**When to use**: Finding code by structure (error handlers, function calls, type definitions), refactoring with pattern rewrites, analyzing code semantics.

**Key features**:
- Matches AST structure, not text (format-independent)
- Pattern rewrites preserve code structure
- Multi-language: JS, TS, Python, Go, Rust, Java, C++, and more
- Meta-variables: `$VAR` (single node), `$$$ARGS` (sequences)

**Installation**:
```bash
# macOS
brew install ast-grep

# npm (cross-platform)
npm install -g @ast-grep/cli

# Python
pip install ast-grep-cli
```

**Examples**:
```bash
# Find error handling
ast-grep -p 'if err != nil { $$$ }' -l go .

# Find and refactor
ast-grep -p 'console.log($$$)' -r 'logger.debug($$$)' -i -l js .

# Find functions
ast-grep -p 'function $NAME($$$PARAMS) { $$$ }' -l javascript .
```

**Manual Invocation**:
```bash
/ast-grep-search
```

The skill will verify installation and provide setup instructions if ast-grep is not found.

### `bump-plugin-version` (User-Invocable)
Automatically analyze changes and bump plugin version following semantic versioning.

**Invocation**:
```bash
/bump-plugin-version [plugin-name]
```

Analyzes git changes to determine whether to bump major, minor, or patch version and updates both `plugin.json` and `marketplace.json` files.
