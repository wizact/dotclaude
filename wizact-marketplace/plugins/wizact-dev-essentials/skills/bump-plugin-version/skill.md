---
name: bump-plugin-version
description: Analyze changes and automatically bump plugin version in plugin.json and marketplace.json following semantic versioning
disable-model-invocation: false
user-invocable: true
---

# Plugin Version Bumper

Automatically analyze staged/unstaged changes to determine correct semantic version bump and update both `plugin.json` and `marketplace.json`.

## When User Invokes `/bump-plugin-version [plugin-name]`

### 1. Identify Target Plugin

If `plugin-name` argument provided:
- Use specified plugin name
- Validate plugin exists in marketplace

If no argument:
- Detect from current working directory path
- If in `plugins/{name}/`, use that plugin
- Otherwise, list available plugins and ask user to specify

### 2. Analyze Git Changes

Run the following to understand changes:
```bash
git status
git diff --cached  # Staged changes
git diff           # Unstaged changes
git log --oneline -5  # Recent commits for context
```

Focus analysis on files within the target plugin directory:
```
plugins/{plugin-name}/**/*
```

### 3. Determine Version Bump Type

**MAJOR** (x.0.0) - Breaking changes:
- Removed commands, skills, agents, or hooks
- Changed command/skill interfaces that break existing usage
- Modified hook behavior incompatibly
- Removed required configuration fields
- Changed data formats incompatibly

**MINOR** (0.x.0) - New features:
- Added new commands, skills, agents, or hooks
- Added new optional parameters/configuration
- Enhanced existing functionality (backward compatible)
- New capabilities that don't break existing usage

**PATCH** (0.0.x) - Bug fixes and minor updates:
- Bug fixes
- Documentation updates
- Performance improvements
- Refactoring without behavior changes
- Dependency updates (non-breaking)

### 4. Present Analysis to User

Show:
- Detected changes summary
- Recommended version bump type and rationale
- Current plugin version → New plugin version
- Current marketplace version → New marketplace version
- Affected files:
  - `plugins/{plugin-name}/.claude-plugin/plugin.json`
  - `wizact-marketplace/.claude-plugin/marketplace.json` (plugin entry + marketplace version)

Ask for confirmation or allow user to override bump type.

### 5. Update Version Files

After confirmation:

1. **Update plugin.json**:
   - Read current version from `plugins/{plugin-name}/.claude-plugin/plugin.json`
   - Calculate new version based on bump type
   - Update `version` field
   - Write back to file

2. **Update marketplace.json - Plugin Entry**:
   - Read `wizact-marketplace/.claude-plugin/marketplace.json`
   - Find plugin entry in `plugins[]` array matching `plugin-name`
   - Update that plugin's `version` field to match new plugin.json version
   - Write back to file

3. **Update marketplace.json - Marketplace Version**:
   - Read marketplace's own `version` field (root level, if present)
   - Apply **aggregated bump logic**:
     - **MAJOR**: If any plugin has MAJOR bump
     - **MINOR**: If any plugin has MINOR bump (and no MAJOR)
     - **PATCH**: If only PATCH bumps across all plugins
   - Update marketplace's `version` field
   - Write back to file

4. **Verify changes**:
   - Show diff of both files
   - Confirm versions are correct

### 6. Completion

Report:
- Plugin version bumped: `{old-version}` → `{new-version}`
- Marketplace plugin entry updated to: `{new-version}`
- Marketplace version bumped: `{old-marketplace-version}` → `{new-marketplace-version}`
- Updated files list
- Suggest next steps: review changes, commit, etc.

## Marketplace Version Aggregation Logic

The marketplace.json has its **own independent version** at the root level that reflects the collective state of all plugins:

- **MAJOR bump**: At least one plugin received a MAJOR bump
- **MINOR bump**: At least one plugin received a MINOR bump (no MAJOR bumps)
- **PATCH bump**: All plugin changes are PATCH only

This allows marketplace versioning to signal breaking changes across any plugin.

## Semantic Versioning Rules

Format: `MAJOR.MINOR.PATCH`

- **MAJOR**: Incompatible API/interface changes
- **MINOR**: Backward-compatible new functionality
- **PATCH**: Backward-compatible bug fixes

Start at `1.0.0` for initial release. Pre-release versions (`0.x.x`) indicate API instability.

## Edge Cases

- **No changes detected**: Warn user, ask if they want to force bump
- **Multiple change types**: Use highest priority (MAJOR > MINOR > PATCH)
- **Version mismatch**: If plugin.json and marketplace.json plugin entry differ, warn and ask which to trust
- **Invalid version format**: Report error and show current invalid version
- **Marketplace has no root version**: Only update plugin entry version

## Example Usage

```bash
# Auto-detect from current directory
/bump-plugin-version

# Specify plugin explicitly
/bump-plugin-version wizact-dev-essentials

# Typical workflow:
# 1. Make changes to plugin
# 2. Stage changes with git add
# 3. Run /bump-plugin-version
# 4. Review and confirm version bump
# 5. Commit with updated versions
```

## Implementation Notes

- Use JSON parsing to safely update version fields
- Preserve formatting and field order in JSON files
- Always show diffs before writing files
- Never guess - if unclear, ask user to clarify change type
- Consider commit messages for additional context on change intent
- Track whether this is first bump in current session to determine marketplace aggregation
