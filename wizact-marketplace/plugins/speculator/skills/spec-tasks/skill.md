---
name: spec-tasks
description: Generate tasks.md with trackable work items and PR workflow
user-invokable: true
argument-hint: "[spec-dir] [--max-task-days=1] [--include-pr-workflow]"
---

# Spec Tasks Writer

Generate tasks.md with trackable work items, requirement cross-references, and PR workflow from requirements and design.

## Input

**Arguments**:
- `spec-dir`: Spec directory path (must contain requirements.md + design.md)
- `--max-task-days=N`: Maximum task size in days (default: 1)
- `--include-pr-workflow`: Include PR workflow section (default: true)

**Example**:
```bash
/spec-tasks docs/bugs/b006-fix-login-timeout/
/spec-tasks --max-task-days=2
/spec-tasks --include-pr-workflow=false
```

## Operations

### 1. Read Requirements and Design

**Auto-detect paths**:
- If argument is directory: look for `requirements.md` and `design.md` inside
- If no argument: search cwd for both files

**Extract from requirements.md**:
- Numbered requirements (R1, R2, ...)
- User stories (US-1, US-2, ...)
- Dependencies between requirements

**Extract from design.md**:
- Components and responsibilities
- Data structures
- Implementation details
- Requirements coverage

### 2. Read Context (if available)

**Read context.json**:
- Extract: spec type, project context
- Use to inform task breakdown

### 3. Break Into Implementation Phases

**Criteria for task breakdown**:
- Each task ≤ max-task-days (default: 1 day)
- Atomic: Can be completed independently
- Testable: Has clear verification criteria
- Reviewable: Fits in single PR

**Phases**:
1. **Setup/Infrastructure**: Config, database migrations, test fixtures
2. **Core Implementation**: Main components per design.md
3. **Integration**: Connect components, end-to-end flow
4. **Testing**: Unit tests, integration tests
5. **Documentation**: Code comments, user docs (if applicable)

### 4. Number Tasks and Cross-Reference

**Format**:
```markdown
## Tasks

### T1: <Task Title>
**Phase**: Setup
**Estimate**: 0.5 days
**Requirements**: R1, R3
**Description**: <What needs to be done>
**Verification**: <How to verify completion>
**Dependencies**: None

### T2: <Task Title>
**Phase**: Core
**Estimate**: 1 day
**Requirements**: R2, R4
**Description**: <What>
**Verification**: <How>
**Dependencies**: T1
```

**Numbering**: Sequential (T1, T2, T3, ...)
**Cross-references**: Link to requirements (R1, R2, ...) that each task implements

### 5. Verify Requirements Coverage

**Check**:
- Every requirement (R1, R2, ...) covered by ≥1 task
- No orphaned requirements
- Task dependencies form DAG (no cycles)

**Add traceability table**:
```markdown
## Requirements Traceability

| Requirement | Covered By Tasks |
|-------------|------------------|
| R1 | T1, T2 |
| R2 | T3 |
| R3 | T1, T4 |
| ... | ... |
```

### 6. Add PR Workflow (if --include-pr-workflow)

**Structure**:
```markdown
## PR Workflow

### Branch Naming
- Feature: `feature/b006-fix-login-timeout`
- Bug fix: `bugfix/b006-fix-login-timeout`
- Refactor: `refactor/b006-fix-login-timeout`

### Commit Conventions
Follow Conventional Commits:
- `feat: add session timeout configuration`
- `fix: prevent session loss on timeout`
- `test: add timeout monitor tests`
- `docs: update auth configuration guide`

**REQUIRED**: All commits MUST be signed with `-S` flag:
```bash
git commit -S -m "feat: add timeout config"
```

### PR Description Template
```markdown
## Summary
<1-2 sentence summary>

## Changes
- <bullet list of changes>

## Requirements
Addresses: R1, R3, R5

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows project conventions
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] Commits are signed
```

### Labels
- `AI-Assisted` (REQUIRED for all PRs)
- `bug` or `feature` (based on spec type)
- `needs-review`

**IMPORTANT**: Add "AI-Assisted" label to PR metadata, NOT in description.
```

### 7. Write tasks.md

**Write to**: `<directory>/tasks.md`

**Full structure**:
```markdown
# Tasks: <Feature/Bug Title>

## Overview
<1-2 sentence summary of implementation plan>

## Tasks

### T1: <Title>
...

### T2: <Title>
...

## Requirements Traceability
| Req | Tasks |
|-----|-------|
| R1  | T1, T2 |

## PR Workflow
<See template above>

## Task Dependencies
```
T1 → T2 → T3
     ↓
     T4 → T5
```
```

### 8. Update context.json

```json
{
  "tasks_written": true,
  "task_count": 12,
  "updated_at": "2026-03-05T12:00:00Z"
}
```

### 9. Display Output

**To user**:
```
Generated tasks.md:
- 12 tasks across 5 phases
- Estimates: 8.5 days total
- Requirements coverage: 100% (all R1-R8 covered)
- Dependencies: T2→T1, T4→T3, T5→T2,T4

Traceability:
- R1 → T1, T2
- R2 → T3, T4
- R3 → T1, T5
...

Next: Review tasks.md → /spec-finalize
```

## Output

- `tasks.md` written to spec directory
- context.json updated with `tasks_written: true, task_count: N`
- **Exit**: Returns control to main assistant

## Error Handling

**If requirements.md or design.md missing**:
- Search parent directories
- If not found: "Error: requirements.md and design.md required. Run /spec-requirements and /spec-design first."

**If requirements not covered**:
- Mark incomplete: `"task_coverage_complete": false`
- Add to tasks.md: `## Missing Coverage\n- R5: No tasks implement this requirement`
- Note in output: "Partial tasks (R5 not covered)"

**If tasks file exists**:
- Warn: "tasks.md exists. Overwrite? (y/n)"
- If no: abort
- If yes: backup to `tasks.md.bak`

**If task dependencies have cycles**:
- Detect cycle: T1→T2→T3→T1
- Error: "Cycle detected in task dependencies: T1→T2→T3→T1. Fix before continuing."
- Suggest resolution: "Consider splitting T1 or removing dependency"

## Task Size Guidelines

**≤1 day** (default):
- 1-3 files changed
- <200 lines of code
- Focused scope

**≤2 days** (if --max-task-days=2):
- 3-5 files changed
- <500 lines of code
- Single component

**>2 days** (avoid unless necessary):
- Break into smaller tasks
- Exception: Database migration + code changes together

## Template (Minimal)

```markdown
# Tasks: <Title>

## Tasks

### T1: <Title>
**Phase**: Setup
**Estimate**: 0.5 days
**Requirements**: R1
**Description**: <What>
**Verification**: <How>
**Dependencies**: None

## Requirements Traceability
| Req | Tasks |
|-----|-------|
| R1  | T1 |

## PR Workflow

### Commit Conventions
- All commits signed: `git commit -S`
- Follow Conventional Commits

### Labels
- `AI-Assisted` (required)
```

## Next Actions

After this skill completes:

1. **Review** tasks.md to ensure work breakdown is reasonable
2. **Verify** all requirements (R1, R2, ...) have task coverage
3. **Check** task dependencies form valid DAG (no cycles)
4. **Validate** task estimates are realistic (≤1 day default)
5. **Invoke** `/spec-finalize` to complete the spec package:
   ```bash
   /spec-finalize
   ```
   Or specify the spec directory:
   ```bash
   /spec-finalize docs/bugs/b006-fix-login-timeout/
   ```
