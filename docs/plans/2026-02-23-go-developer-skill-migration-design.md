# Go-Developer Agent to Skill Migration Design

**Date:** 2026-02-23
**Status:** Approved
**Approach:** Clean Cut Migration (Approach A)

## Overview

Migrate from legacy `agents/go-developer.md` to skill-based architecture using `skills/go-developer/`. The `developer.md` dispatcher agent will auto-detect Go projects and invoke the skill via `Skill(skill="go-developer")`.

## Architecture

### Current State
- Legacy agent: `./agents/go-developer.md` (925 lines, monolithic)
- New skill: `./skills/go-developer/` (modular: SKILL.md + 26 rule files)
- Dispatcher: `./agents/developer.md` calls `Skill(skill="go-developer")`

### Target State
- Remove legacy agent completely
- Enhance `SKILL.md` with missing content
- Update plugin configuration and docs
- Single source of truth: `skills/go-developer/SKILL.md`

### Invocation Flow
```
User requests Go work
  → developer.md detects Go project (go.mod, *.go files)
  → Calls Skill(skill="go-developer")
  → Loads skills/go-developer/SKILL.md
  → Applies guidance (26 rules + pragmatic guidelines)
```

## Content Migration

### Add to SKILL.md

**1. Pragmatic Guidelines Section** (after line 121)

```markdown
## Pragmatic Guidelines

**When to Create an Interface?**

Create interface if ANY apply:
- Multiple implementations exist or will exist
- Need to test without external dependency (database, API, file system)
- Crossing architectural boundaries (domain → adapter)

Don't create for:
- Single implementation unlikely to change
- Internal helpers within same package
- Simple utilities

**When to Split into Layers?**

- **Small (< 1K lines)**: Domain types in one file, interfaces in same package
- **Medium (1K-10K lines)**: Separate packages per concern (task/, user/, auth/)
- **Large (10K+ lines)**: Full layer separation (domain/, application/, adapters/, ports/)

Start simple, refactor when complexity demands it.

**Interface Size Guideline:**

- Keep interfaces small: **1-5 methods**
- Large interfaces (>5 methods) suggest multiple responsibilities
- Split into focused interfaces (Interface Segregation Principle)
```

**2. Anti-Patterns Section** (before line 143)

```markdown
## Anti-Patterns to Avoid

**Business Logic in Handlers:**
```go
// ❌ BAD: HTTP handler contains business logic
func handleComplete(w http.ResponseWriter, r *http.Request) {
    task, _ := db.Query(...)
    task.Done = true
    db.Exec(...)
}

// ✅ GOOD: Delegate to service
func handleComplete(w http.ResponseWriter, r *http.Request) {
    id := r.URL.Query().Get("id")
    if err := taskService.Complete(id); err != nil {
        http.Error(w, err.Error(), 500)
        return
    }
}
```

**God Objects:**
```go
// ❌ BAD: Too many dependencies
type TaskManager struct {
    db, cache, emailer, logger, config, httpClient, validator, reporter
}

// ✅ GOOD: Focused responsibilities
type TaskService struct {
    repo TaskRepository  // Single focused dependency
}
```
```

## Documentation Updates

### 1. plugin.json
```json
// Before:
"agents": ["./agents/go-developer.md", "./agents/go-reviewer.md", "./agents/specbuilder.md"]

// After:
"agents": ["./agents/developer.md", "./agents/go-reviewer.md", "./agents/specbuilder.md"]
```

**Changes:**
- Add `./agents/developer.md` (dispatcher)
- Remove `./agents/go-developer.md` (migrated to skill)

### 2. wizact-dev-essentials/README.md
- Update agent list: show `developer` as language-aware dispatcher
- Remove direct `go-developer` agent references
- Add note: "Go development guidance via `developer` agent (auto-detects) or `Skill(skill='go-developer')`"

### 3. Root README.md
- Update example on line 119 if it shows agent invocation
- Optional: depends on whether example should demonstrate agent vs skill usage

### 4. Commit Message
```
feat(wizact-dev-essentials): migrate go-developer to skill architecture

BREAKING CHANGE: Remove go-developer agent in favor of skill

- Move go-developer from ./agents/ to ./skills/ (already done)
- Add Pragmatic Guidelines and Anti-Patterns sections to SKILL.md
- Update plugin.json to include developer.md dispatcher
- Remove legacy agents/go-developer.md
- Update documentation references

Migration path:
- Use developer agent for auto-detection of Go projects
- Or invoke Skill(skill="go-developer") directly
- Legacy agent ./agents/go-developer.md removed
```

## Files Changed

**Modified:**
- `wizact-marketplace/plugins/wizact-dev-essentials/skills/go-developer/SKILL.md`
- `wizact-marketplace/plugins/wizact-dev-essentials/.claude-plugin/plugin.json`
- `wizact-marketplace/plugins/wizact-dev-essentials/README.md`
- `README.md` (root, optional)

**Deleted:**
- `wizact-marketplace/plugins/wizact-dev-essentials/agents/go-developer.md`

## Validation

After migration:
1. Verify `Skill(skill="go-developer")` loads SKILL.md correctly
2. Test developer.md auto-detection on Go project
3. Confirm all 26 rules + new sections present in SKILL.md
4. Verify no broken references in documentation

## Risks & Mitigation

**Risk:** Users directly invoking `wizact-dev-essentials:go-developer` agent
**Mitigation:** Document breaking change in commit message; users should use `developer` dispatcher or direct skill invocation

**Risk:** Missing content from legacy agent
**Mitigation:** Content analysis shows 95% coverage; adding Pragmatic Guidelines and Anti-Patterns sections closes gaps

**Risk:** Skill invocation mechanism issues
**Mitigation:** Other skills (fd-search, ripgrep-search) follow same pattern successfully

## Timeline

Estimated: 1-2 hours

1. Add content to SKILL.md (30 min)
2. Update plugin.json and READMEs (15 min)
3. Delete legacy agent (5 min)
4. Test and validate (15-30 min)
5. Commit and document (15 min)
