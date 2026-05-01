# wizact-utilities

Utility tools and hooks for Claude Code on macOS.

## Features

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
Add to `~/.claude/settings.json`:
```json
{
  "plugins": [
    "~/dev/github.com/wizact/dotclaude/mac/wizact-marketplace/plugins/wizact-utilities"
  ]
}
```
Then restart Claude session.

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
- macOS 13.0+ (Ventura or later for growlrrr, earlier versions work with terminal-notifier/osascript)

## Skills

### `bump-plugin-version` (User-Invocable)
Automatically analyze changes and bump plugin version following semantic versioning.

**Invocation**:
```bash
/bump-plugin-version [plugin-name]
```

Analyzes git changes to determine whether to bump major, minor, or patch version and updates both `plugin.json` and `marketplace.json` files.
