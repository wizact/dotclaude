# wizact-health-fitness

Health and fitness workflows for Claude Code and Codex.

## Included skill

- `strava-activity-import` — Import one Strava activity into an existing
  `activities.sqlite` database from FIT, GPX, or Garmin TCX files.

The plugin intentionally contains only this skill for now. It includes both
`.claude-plugin/plugin.json` and `.codex-plugin/plugin.json` manifests so it can
be installed by either runtime.

## Installation

Install `wizact-marketplace`, then install `wizact-health-fitness` from the
marketplace. The skill is available as `/strava-activity-import`.
