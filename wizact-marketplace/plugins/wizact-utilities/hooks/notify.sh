#!/bin/bash
# macOS notification helper for Claude Code hooks.
# Usage: notify.sh <message>
# Detects session name and tmux window automatically.
# Uses terminal-notifier if available, falls back to osascript.
#
# Note: terminal-notifier's -execute/-activate flags are broken on
# macOS Sequoia+, so we don't use them.

set -euo pipefail

MESSAGE="${1:-Claude needs attention}"

# --- Session name ---
SESSION_NAME=""
CLAUDE_PID="${PPID:-}"
if [ -n "$CLAUDE_PID" ]; then
  CLAUDE_CMD=$(ps -o args= -p "$CLAUDE_PID" 2>/dev/null || true)
  if echo "$CLAUDE_CMD" | grep -q 'claude'; then
    SESSION_NAME=$(echo "$CLAUDE_CMD" | grep -oE '\-\-name[= ]+[^ ]+' | sed 's/--name[= ]*//' || true)
    if [ -z "$SESSION_NAME" ]; then
      SESSION_NAME=$(echo "$CLAUDE_CMD" | grep -oE '\-\-resume[= ]+[^ ]+' | sed 's/--resume[= ]*//' || true)
    fi
  fi
fi
if [ -z "$SESSION_NAME" ] && [ -n "${TMUX:-}" ]; then
  SESSION_NAME=$(tmux display-message -p '#{window_name}' 2>/dev/null || true)
fi

TITLE="Claude Code"
if [ -n "$SESSION_NAME" ]; then
  TITLE="Claude Code - $SESSION_NAME"
fi

# --- Tmux window info (included in notification body) ---
TMUX_INFO=""
if [ -n "${TMUX:-}" ] && [ -n "${TMUX_PANE:-}" ]; then
  TMUX_WIN=$(tmux display-message -t "$TMUX_PANE" -p '#{window_index}' 2>/dev/null || true)
  if [ -n "$TMUX_WIN" ]; then
    TMUX_INFO=" [tmux:$TMUX_WIN]"
  fi
fi

# --- Send notification ---
if command -v terminal-notifier >/dev/null 2>&1; then
  terminal-notifier \
    -message "${MESSAGE}${TMUX_INFO}" \
    -title "$TITLE" \
    -group "claude-code-$$" \
    >/dev/null 2>&1
else
  osascript -e "display notification \"${MESSAGE}${TMUX_INFO}\" with title \"$TITLE\"" 2>/dev/null
fi
