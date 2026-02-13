# wizact-utilities

Utility hooks for Claude Code on macOS.

## Features
- Desktop notifications when Claude waits for input (60s+ idle)
- Permission request alerts
- MCP tool input notifications
- Silent (no sound) notifications

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
