# Go-Developer Skill Migration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Migrate legacy go-developer agent to skill-based architecture by enhancing SKILL.md content and updating plugin configuration.

**Architecture:** Add missing content (Pragmatic Guidelines, Anti-Patterns) to skills/go-developer/SKILL.md, update plugin.json to register developer.md dispatcher, remove legacy agent, update documentation.

**Tech Stack:** Markdown, JSON, Git

---

## Task 1: Enhance SKILL.md with Pragmatic Guidelines

**Files:**
- Modify: `wizact-marketplace/plugins/wizact-dev-essentials/skills/go-developer/SKILL.md:121-122`

**Step 1: Add Pragmatic Guidelines section**

Add after line 121 (after "Scalable Architecture" section):

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

**Step 2: Verify content added correctly**

Run: `grep -A 20 "Pragmatic Guidelines" wizact-marketplace/plugins/wizact-dev-essentials/skills/go-developer/SKILL.md`

Expected: Shows the new section with all three subsections (When to Create, When to Split, Interface Size)

**Step 3: Commit**

```bash
git add wizact-marketplace/plugins/wizact-dev-essentials/skills/go-developer/SKILL.md
git commit -S -m "feat(go-developer): add pragmatic guidelines section

Add decision-making heuristics for interface creation, layer splitting,
and interface sizing. Migrated from legacy agent.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 2: Add Anti-Patterns Section to SKILL.md

**Files:**
- Modify: `wizact-marketplace/plugins/wizact-dev-essentials/skills/go-developer/SKILL.md:142-143`

**Step 1: Add Anti-Patterns section**

Add before line 143 (before "Quick Checklist" section):

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

**Step 2: Verify content added correctly**

Run: `grep -A 30 "Anti-Patterns to Avoid" wizact-marketplace/plugins/wizact-dev-essentials/skills/go-developer/SKILL.md`

Expected: Shows both anti-patterns (Business Logic in Handlers, God Objects) with code examples

**Step 3: Commit**

```bash
git add wizact-marketplace/plugins/wizact-dev-essentials/skills/go-developer/SKILL.md
git commit -S -m "feat(go-developer): add anti-patterns section

Add examples of common anti-patterns (business logic in handlers,
god objects) with correct alternatives. Migrated from legacy agent.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 3: Update plugin.json to Register developer.md Agent

**Files:**
- Modify: `wizact-marketplace/plugins/wizact-dev-essentials/.claude-plugin/plugin.json:12`

**Step 1: Read current plugin.json**

Run: `cat wizact-marketplace/plugins/wizact-dev-essentials/.claude-plugin/plugin.json`

Expected: Shows current agents array with go-developer.md

**Step 2: Update agents array**

Change line 12 from:
```json
"agents": ["./agents/go-developer.md", "./agents/go-reviewer.md", "./agents/specbuilder.md"]
```

To:
```json
"agents": ["./agents/developer.md", "./agents/go-reviewer.md", "./agents/specbuilder.md"]
```

**Step 3: Verify JSON is valid**

Run: `cat wizact-marketplace/plugins/wizact-dev-essentials/.claude-plugin/plugin.json | python3 -m json.tool > /dev/null && echo "Valid JSON"`

Expected: "Valid JSON"

**Step 4: Commit**

```bash
git add wizact-marketplace/plugins/wizact-dev-essentials/.claude-plugin/plugin.json
git commit -S -m "feat(plugin): register developer.md dispatcher agent

Replace go-developer agent with developer.md language-aware dispatcher.
The dispatcher auto-detects Go projects and invokes go-developer skill.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 4: Delete Legacy go-developer Agent

**Files:**
- Delete: `wizact-marketplace/plugins/wizact-dev-essentials/agents/go-developer.md`

**Step 1: Verify skill has all content**

Run: `grep -c "Pragmatic Guidelines\|Anti-Patterns" wizact-marketplace/plugins/wizact-dev-essentials/skills/go-developer/SKILL.md`

Expected: 2 (both sections present)

**Step 2: Delete legacy agent**

Run: `git rm wizact-marketplace/plugins/wizact-dev-essentials/agents/go-developer.md`

Expected: File staged for deletion

**Step 3: Verify deletion**

Run: `ls wizact-marketplace/plugins/wizact-dev-essentials/agents/`

Expected: Shows developer.md, go-reviewer.md, specbuilder.md (no go-developer.md)

**Step 4: Commit**

```bash
git commit -S -m "feat(wizact-dev-essentials): remove legacy go-developer agent

BREAKING CHANGE: go-developer agent migrated to skill architecture

Content migrated to skills/go-developer/SKILL.md with enhancements:
- Added Pragmatic Guidelines (interface decisions, layer splitting)
- Added Anti-Patterns section (business logic in handlers, god objects)

Migration path:
- Use developer.md agent for auto-detection of Go projects
- Or invoke Skill(skill=\"go-developer\") directly

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 5: Update wizact-dev-essentials README

**Files:**
- Modify: `wizact-marketplace/plugins/wizact-dev-essentials/README.md:16,155-156`

**Step 1: Read current README**

Run: `grep -n "go-developer" wizact-marketplace/plugins/wizact-dev-essentials/README.md`

Expected: Shows lines referencing go-developer agent

**Step 2: Update agent references**

Find section listing agents (around line 16) and update:
- Change "go-developer" to "developer (language-aware dispatcher)"
- Keep go-reviewer and specbuilder as-is

Find documentation section (around lines 155-156) and update:
- Remove direct go-developer agent invocation examples
- Add note: "Go development guidance available via `developer` agent (auto-detects) or `Skill(skill='go-developer')`"

**Step 3: Verify changes**

Run: `grep -n "developer\|go-developer" wizact-marketplace/plugins/wizact-dev-essentials/README.md`

Expected: Shows updated references (developer agent, go-developer skill)

**Step 4: Commit**

```bash
git add wizact-marketplace/plugins/wizact-dev-essentials/README.md
git commit -S -m "docs(wizact-dev-essentials): update README for skill migration

Update agent references:
- Replace go-developer agent with developer dispatcher
- Document skill invocation: Skill(skill='go-developer')

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 6: Update Root README (Optional)

**Files:**
- Modify: `README.md:119` (if needed)

**Step 1: Check if root README references go-developer agent**

Run: `grep -n "go-developer" README.md`

Expected: Shows line 119 with example of agent invocation (or no output if not referenced)

**Step 2: Update example if present**

If line 119 shows agent invocation example, update to demonstrate skill invocation:

Change:
```python
Task(subagent_type="wizact-dev-essentials:go-developer", prompt="Implement feature X")
```

To:
```python
# Auto-detect language and apply best practices
Task(subagent_type="wizact-dev-essentials:developer", prompt="Implement feature X")

# Or invoke skill directly
Skill(skill="wizact-dev-essentials:go-developer")
```

**Step 3: Commit (if changed)**

```bash
git add README.md
git commit -S -m "docs: update go-developer examples for skill migration

Update examples to show developer dispatcher usage and direct skill
invocation instead of legacy agent.

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

---

## Task 7: Validation Testing

**Files:**
- Test: All modified files

**Step 1: Verify skill structure**

Run: `ls -la wizact-marketplace/plugins/wizact-dev-essentials/skills/go-developer/`

Expected: Shows SKILL.md, REFERENCE.md, rules/, scripts/

**Step 2: Verify SKILL.md completeness**

Run: `grep -c "## Pragmatic Guidelines\|## Anti-Patterns\|## Quick Checklist" wizact-marketplace/plugins/wizact-dev-essentials/skills/go-developer/SKILL.md`

Expected: 3 (all three sections present)

**Step 3: Verify plugin.json validity**

Run: `cat wizact-marketplace/plugins/wizact-dev-essentials/.claude-plugin/plugin.json | python3 -m json.tool`

Expected: Valid JSON output with developer.md in agents array

**Step 4: Verify legacy agent deleted**

Run: `test ! -f wizact-marketplace/plugins/wizact-dev-essentials/agents/go-developer.md && echo "Legacy agent deleted"`

Expected: "Legacy agent deleted"

**Step 5: Verify git status clean**

Run: `git status`

Expected: "nothing to commit, working tree clean" (all changes committed)

---

## Task 8: Bump Plugin Version

**Files:**
- Modify: `wizact-marketplace/plugins/wizact-dev-essentials/.claude-plugin/plugin.json:3`

**Step 1: Use bump-plugin-version skill**

Run: `Skill(skill="wizact-utilities:bump-plugin-version", args="wizact-dev-essentials")`

Expected: Version bumped to 1.2.0 (minor version for new features)

**Step 2: Verify version updated**

Run: `grep '"version"' wizact-marketplace/plugins/wizact-dev-essentials/.claude-plugin/plugin.json`

Expected: Shows "version": "1.2.0"

**Step 3: Verify marketplace.json synced**

Run: `grep -A 3 'wizact-dev-essentials' wizact-marketplace/marketplace.json | grep version`

Expected: Shows matching version 1.2.0

**Step 4: Verify changes committed**

Run: `git log -1 --oneline`

Expected: Shows version bump commit

---

## Success Criteria

After completing all tasks:

✅ SKILL.md contains Pragmatic Guidelines section
✅ SKILL.md contains Anti-Patterns section
✅ plugin.json registers developer.md (not go-developer.md)
✅ Legacy agents/go-developer.md deleted
✅ READMEs updated with new references
✅ All changes committed with signed commits
✅ Plugin version bumped to 1.2.0
✅ No broken references to legacy agent

## Notes

- All commits signed with `-S` flag per user preferences
- AI-Assisted label should be added to any PR/issue manually (not in descriptions)
- No Claude Code footers or AI attribution in commit messages
- Migration is breaking change - documented in commit message
