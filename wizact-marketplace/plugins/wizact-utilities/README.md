# wizact-utilities

Utility tools and hooks for Claude Code on macOS.

## Features

### 🔔 Notification Hooks
- Desktop notifications when Claude waits for input (60s+ idle)
- Permission request alerts
- MCP tool input notifications
- Silent (no sound) notifications

### 🔧 Version Management
- **bump-plugin-version**: Automatically bump plugin versions following semantic versioning

## Installation
Add to `~/.claude/settings.json`:
```json
{
  "plugins": [
    "~/dev/github.com/wizact/dotclaude/mac/wizact-marketplace/plugins/wizact-utilities"
  ]
}
```

## Requirements
- macOS (uses osascript)

## User Setup (Manual)
Add to `~/.claude/settings.json`:
```json
{
  "plugins": [
    "~/dev/github.com/wizact/dotclaude/mac/wizact-marketplace/plugins/wizact-utilities"
  ]
}
```
Then restart Claude session.

## Skills

### `bump-plugin-version` (User-Invocable)
Automatically analyze changes and bump plugin version following semantic versioning.

**Invocation**:
```bash
/bump-plugin-version [plugin-name]
```

Analyzes git changes to determine whether to bump major, minor, or patch version and updates both `plugin.json` and `marketplace.json` files.
