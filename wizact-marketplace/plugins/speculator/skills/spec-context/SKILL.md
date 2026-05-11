---
name: spec-context
description: Parse GitHub issue/PR and gather project context for spec creation
user-invokable: true
argument-hint: "#42 | URL [--skip-exploration] [--output=path]"
---

# Spec Context Gatherer

Parse GitHub issues/PRs and gather comprehensive project context as the first phase of specification creation.

## Input

**Arguments**:
- GitHub issue/PR URL or `#issue-number` or raw description
- `--skip-exploration`: Skip launching Explore agents (faster, less thorough)
- `--output=path`: Custom output directory (default: auto-generated)

## Operations

### 1. Parse Input Source

**If GitHub URL or #issue-number**:
- Use `gh issue view <number>` or `gh pr view <number>` to fetch metadata
- Extract: title, body, labels, assignees, comments
- Determine spec type from labels: `bug`, `enhancement`, `feature`

**If raw description**:
- Use description as-is
- Prompt user for spec type (bug or feature)

### 2. Determine Directory Structure

**Auto-generate directory name**:
- Format: `docs/{features|bugs}/b00N-slug/`
- Slug: Lowercase, kebab-case from issue title
- Number: Next available sequential number (b001, b002, etc.)

**Example**: Issue #42 "Fix Login Timeout" → `docs/bugs/b006-fix-login-timeout/`

**If `--output` provided**: Use custom path instead

### 3. Create Directory

```bash
mkdir -p <directory>
```

### 4. Read Repository Context

**CLAUDE.md** (project instructions):
- Read `.claude/CLAUDE.md` if exists
- Extract: architecture, patterns, conventions

**Constitution** (product/technical docs):
- Read `constitution/product.md` if exists
- Read `constitution/tech.md` if exists
- Extract: requirements, constraints, standards

**Historic specs** (previous examples):
- Find 2-3 most recent specs: `docs/features/` or `docs/bugs/`
- Read their structure to learn patterns

### 5. Launch Exploration (unless --skip-exploration)

**Auto-detect complexity**:
- Simple (1-2 files affected): Launch 1 Explore agent
- Medium (3-5 files): Launch 2 Explore agents
- Complex (6+ files or cross-cutting): Launch 3 Explore agents

**Exploration targets**:
- Relevant source files based on issue description
- Test files for affected components
- Related configuration/infrastructure

**Launch agents**:
```
Agent tool with subagent_type=Explore
Prompt: "Explore <component> to understand <specific aspect>"
```

**Audit synthesis**:
- After explorers complete, launch 1 Explore agent as auditor
- Prompt: "Synthesize findings from exploration of <components>"
- Total agents: 2-4 (1-3 explorers + 1 auditor)

### 6. Draft Clarification Questions

Based on issue description and exploration findings:
- Missing requirements
- Ambiguous acceptance criteria
- Implementation choices (e.g., "Should timeout be configurable?")
- Edge cases (e.g., "What happens to existing sessions?")

**Format**:
```markdown
## Clarification Questions

1. **Timeout behavior**: Should timeout be configurable or hard-coded?
2. **Session handling**: What happens to existing sessions on timeout?
3. **Error messages**: Should timeout errors be user-visible or logged?
```

### 7. Write context.json

**Schema**:
```json
{
  "version": "1.0",
  "issue_url": "https://github.com/org/repo/issues/42",
  "issue_number": 42,
  "spec_type": "bug",
  "directory": "docs/bugs/b006-fix-login-timeout/",
  "context_summary": "Project uses Go + PostgreSQL. Login system in auth/ package. Timeout currently hard-coded at 30s. Users report session loss without warnings.",
  "clarification_questions": [
    "Should timeout be configurable?",
    "What happens to existing sessions?"
  ],
  "user_decisions": {},
  "requirements_written": false,
  "design_written": false,
  "tasks_written": false,
  "finalized": false,
  "created_at": "2026-03-05T10:30:00Z"
}
```

**Write to**: `<directory>/context.json`

### 8. Display Output

**To user**:
```
Created spec directory: docs/bugs/b006-fix-login-timeout/

Context gathered:
- Issue: #42 "Fix Login Timeout"
- Type: bug
- Explored 3 components: auth/, session/, middleware/
- Synthesis: Login timeout hard-coded, no user warnings

Clarification questions:
1. Should timeout be configurable?
2. What happens to existing sessions?

Next: Review questions → /spec-requirements --answers='{...}'
```

## Output

- `context.json` written to spec directory
- Clarification questions displayed
- **Exit**: Returns control to main assistant

## Error Handling

**If GitHub API fails**:
- Prompt user to paste issue content manually
- Continue with raw description flow

**If directory exists**:
- Warn user: "Directory exists. Overwrite? (y/n)"
- If no, abort
- If yes, backup existing `context.json` to `context.json.bak`

**If exploration agents fail**:
- Mark in context.json: `"exploration_completed": false`
- Continue with context from CLAUDE.md/constitution only
- Note in output: "Exploration skipped (errors encountered)"

## Examples

**Full workflow**:
```bash
/spec-context #42
# Gathers context, asks 3 clarification questions
```

**Skip exploration** (faster):
```bash
/spec-context #42 --skip-exploration
# Only reads CLAUDE.md/constitution, no Explore agents
```

**Custom directory**:
```bash
/spec-context #42 --output=docs/custom-spec/
```

**Raw description** (no GitHub issue):
```bash
/spec-context "Users report login timeout after 30 seconds"
# Prompts for spec type, continues
```

## Next Actions

After this skill completes:

1. **Review** the clarification questions displayed
2. **Answer** the questions (prepare answers as JSON or plain text)
3. **Invoke** `/spec-requirements` with your answers:
   ```bash
   /spec-requirements --answers='{"timeout":"configurable","sessions":"invalidate"}'
   ```
   Or simply invoke `/spec-requirements` and answer questions interactively
