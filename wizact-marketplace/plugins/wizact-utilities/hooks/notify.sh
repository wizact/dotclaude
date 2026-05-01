#!/bin/bash
# macOS notification helper for Claude Code hooks.
# Usage: notify.sh <message>
# Detects session name and tmux window automatically.
# Prefers growlrrr (click-to-activate + tmux switch), falls back to
# terminal-notifier, then osascript.

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
if [ -z "$SESSION_NAME" ] && [ -n "${TMUX:-}" ] && [ -n "${TMUX_PANE:-}" ]; then
  TMUX_WINDOW_NAME=$(tmux display-message -t "$TMUX_PANE" -p '#{window_name}' 2>/dev/null || true)
  if [ -n "$TMUX_WINDOW_NAME" ]; then
    SESSION_NAME="tmux: $TMUX_WINDOW_NAME"
  fi
fi

# --- Tmux window info ---
TMUX_WIN=""
TMUX_SOCK=""
TMUX_BIN=""
if [ -n "${TMUX:-}" ] && [ -n "${TMUX_PANE:-}" ]; then
  TMUX_BIN=$(command -v tmux)
  TMUX_WIN=$("$TMUX_BIN" display-message -t "$TMUX_PANE" -p '#{window_index}' 2>/dev/null || true)
  TMUX_SOCK=$(echo "$TMUX" | cut -d, -f1)
fi

# --- Send notification ---
if command -v grrr >/dev/null 2>&1; then
  SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
  ICON="$SCRIPT_DIR/claude-code-icon.png"
  GRRR_ARGS=(--title "Claude Code" --sound none)
  if [ -f "$ICON" ]; then
    GRRR_ARGS+=(--image "$ICON")
  fi
  if [ -n "$SESSION_NAME" ]; then
    GRRR_ARGS+=(--subtitle "$SESSION_NAME")
  fi
  if [ -n "$TMUX_WIN" ] && [ -n "$TMUX_SOCK" ]; then
    # Inside tmux: --reactivate can't see the real terminal app, so we
    # detect the terminal via env vars and use --execute to activate it
    # and switch to the correct tmux window.
    BUNDLE_ID=""
    if [ -n "${ITERM_SESSION_ID:-}" ]; then
      BUNDLE_ID="com.googlecode.iterm2"
    elif [ -n "${KITTY_WINDOW_ID:-}" ]; then
      BUNDLE_ID="net.kovidgoyal.kitty"
    elif [ -n "${WEZTERM_PANE:-}" ]; then
      BUNDLE_ID="com.github.wez.wezterm"
    elif [ -n "${GHOSTTY_RESOURCES_DIR:-}" ]; then
      BUNDLE_ID="com.mitchellh.ghostty"
    fi
    EXEC_CMD="'$TMUX_BIN' -S '$TMUX_SOCK' select-window -t '$TMUX_WIN'"
    if [ -n "$BUNDLE_ID" ]; then
      EXEC_CMD="open -b '$BUNDLE_ID' && $EXEC_CMD"
    fi
    GRRR_ARGS+=(--execute "$EXEC_CMD")
  else
    GRRR_ARGS+=(--reactivate)
  fi
  grrr "${GRRR_ARGS[@]}" "$MESSAGE" >/dev/null 2>&1

elif command -v terminal-notifier >/dev/null 2>&1; then
  # terminal-notifier: -execute/-activate broken on macOS Sequoia+
  TN_TITLE="Claude Code"
  if [ -n "$SESSION_NAME" ]; then
    TN_TITLE="Claude Code - $SESSION_NAME"
  fi
  TMUX_INFO=""
  if [ -n "$TMUX_WIN" ]; then
    TMUX_INFO=" [tmux:$TMUX_WIN]"
  fi
  terminal-notifier \
    -message "${MESSAGE}${TMUX_INFO}" \
    -title "$TN_TITLE" \
    -group "claude-code-$$" \
    -sound "" \
    >/dev/null 2>&1

else
  # osascript: no click action support
  OS_TITLE="Claude Code"
  if [ -n "$SESSION_NAME" ]; then
    OS_TITLE="Claude Code - $SESSION_NAME"
  fi
  TMUX_INFO=""
  if [ -n "$TMUX_WIN" ]; then
    TMUX_INFO=" [tmux:$TMUX_WIN]"
  fi
  osascript -e "display notification \"${MESSAGE}${TMUX_INFO}\" with title \"$OS_TITLE\"" 2>/dev/null
fi
