---
name: spec-finalize
description: Finalize spec package with cross-links and verification
user-invokable: true
argument-hint: "[spec-dir] [--verify-only]"
---

# Spec Finalizer

Finalize spec package with cross-links, verification, and traceability summary. Last phase of spec creation workflow.

## Input

**Arguments**:
- `spec-dir`: Spec directory path (must contain requirements.md, design.md, tasks.md)
- `--verify-only`: Check completeness without making changes

**Example**:
```bash
/spec-finalize docs/bugs/b006-fix-login-timeout/
/spec-finalize --verify-only
```

## Operations

### 1. Verify Directory Structure

**Required files**:
- `context.json`
- `requirements.md`
- `design.md`
- `tasks.md`

**Check**:
- All files exist
- All files non-empty (>100 bytes)
- context.json valid JSON

**If --verify-only**:
- Only run verification checks
- Display results
- Exit without writes

### 2. Read All Documents

**Extract from requirements.md**:
- Requirements list: R1, R2, ..., RN
- User stories: US-1, US-2, ...

**Extract from design.md**:
- Components list
- Requirements coverage table (if exists)

**Extract from tasks.md**:
- Tasks list: T1, T2, ..., TN
- Requirements traceability table (if exists)

**Extract from context.json**:
- Spec metadata (type, issue, directory)

### 3. Update Cross-Links in requirements.md

**Add section at end** (if not exists):
```markdown
## Related Documents

- [Design Specification](./design.md) - Technical architecture
- [Implementation Tasks](./tasks.md) - Work breakdown

## Requirement Coverage

| Requirement | Design | Tasks |
|-------------|--------|-------|
| R1 | Auth Handler component | T1, T2 |
| R2 | Session Manager component | T3 |
| R3 | Timeout Monitor component | T1, T4 |
| ... | ... | ... |
```

**Populate table**:
- Parse design.md for requirement mentions: "Satisfies R1, R3"
- Parse tasks.md for requirement cross-refs: "Requirements: R1, R3"
- Build mapping: R1 → [Component X, Tasks T1,T2]

### 4. Update Cross-Links in design.md

**Add section at end** (if not exists):
```markdown
## Related Documents

- [Requirements Specification](./requirements.md) - User stories and EARS notation
- [Implementation Tasks](./tasks.md) - Work breakdown

## Design Coverage

| Component | Implements Requirements | Implementation Tasks |
|-----------|-------------------------|----------------------|
| Auth Handler | R1, R2 | T1, T2 |
| Session Manager | R3, R4 | T3, T4 |
| Timeout Monitor | R5 | T5 |
| ... | ... | ... |
```

**Populate table**:
- Map components → requirements (from design.md)
- Map components → tasks (from tasks.md)

### 5. Update Cross-Links in tasks.md

**Add section at end** (if not exists):
```markdown
## Related Documents

- [Requirements Specification](./requirements.md) - User stories and EARS notation
- [Design Specification](./design.md) - Technical architecture

## Task Coverage

| Task | Implements Requirements | Modifies Components |
|------|-------------------------|---------------------|
| T1 | R1, R3 | Auth Handler, Config Loader |
| T2 | R2 | Session Manager |
| T3 | R4, R5 | Timeout Monitor |
| ... | ... | ... |
```

**Populate table**:
- Requirements already in tasks.md (no parsing needed)
- Components: infer from design.md component list + task descriptions

### 6. Generate Traceability Matrix

**Create comprehensive matrix**:
```markdown
## Full Traceability Matrix

| User Story | Requirements | Design Components | Tasks |
|------------|--------------|-------------------|-------|
| US-1 | R1, R2 | Auth Handler, Session Manager | T1, T2, T3 |
| US-2 | R3, R4 | Timeout Monitor | T4, T5 |
| US-3 | R5, R6 | Config Loader | T1, T6 |
```

**Verify**:
- Every user story → ≥1 requirement
- Every requirement → ≥1 design component
- Every requirement → ≥1 task
- No orphaned items

### 7. Create SPEC_INDEX.md

**Write to**: `<directory>/SPEC_INDEX.md`

**Content**:
```markdown
# Specification Index: <Feature/Bug Title>

## Metadata

- **Type**: Bug Fix / Feature
- **Issue**: [#42](https://github.com/org/repo/issues/42)
- **Directory**: `docs/bugs/b006-fix-login-timeout/`
- **Created**: 2026-03-05
- **Status**: Ready for Implementation

## Documents

### [Requirements](./requirements.md)
User stories and functional requirements using EARS notation.

- 3 user stories
- 8 functional requirements (R1-R8)
- EARS patterns: Ubiquitous, Event-Driven, State-Driven

### [Design](./design.md)
Technical architecture and implementation details.

- 4 components: Auth Handler, Session Manager, Timeout Monitor, Config Loader
- 2 data structures: SessionConfig, SessionToken
- 100% requirements coverage

### [Tasks](./tasks.md)
Trackable work items with requirement cross-references.

- 12 tasks across 5 phases
- Estimated effort: 8.5 days
- PR workflow and commit conventions

## Traceability Summary

| User Story | Requirements | Components | Tasks |
|------------|--------------|------------|-------|
| US-1 | R1, R2 | Auth Handler | T1, T2 |
| US-2 | R3, R4 | Timeout Monitor | T3, T4 |
| ... | ... | ... | ... |

## Coverage Verification

- ✅ All user stories have requirements
- ✅ All requirements have design components
- ✅ All requirements have implementation tasks
- ✅ All task dependencies are valid (no cycles)
- ✅ Cross-links between documents complete

## Next Steps

1. Review all three documents
2. Create feature branch per PR workflow in tasks.md
3. Implement tasks T1-T12 in sequence
4. Create PRs with `AI-Assisted` label
```

### 8. Update context.json

```json
{
  "finalized": true,
  "finalized_at": "2026-03-05T12:30:00Z"
}
```

### 9. Display Output

**To user**:
```
Finalized spec package: docs/bugs/b006-fix-login-timeout/

Documents:
- ✅ requirements.md (8 requirements, 3 user stories)
- ✅ design.md (4 components, 100% coverage)
- ✅ tasks.md (12 tasks, 8.5 days estimated)
- ✅ SPEC_INDEX.md (traceability summary)

Cross-links added:
- requirements.md → design.md, tasks.md
- design.md → requirements.md, tasks.md
- tasks.md → requirements.md, design.md

Traceability verified:
- US-1 → R1,R2 → Auth Handler, Session Manager → T1,T2,T3
- US-2 → R3,R4 → Timeout Monitor → T4,T5
- US-3 → R5,R6 → Config Loader → T1,T6

Coverage: 100%
- All user stories → requirements ✅
- All requirements → design ✅
- All requirements → tasks ✅
- No orphaned items ✅

Spec package ready for implementation.
```

## Output

- Updated: requirements.md, design.md, tasks.md (with cross-links)
- Created: SPEC_INDEX.md
- Updated: context.json (`finalized: true`)
- **Exit**: Workflow complete

## Error Handling

**If files missing**:
- List missing files: "Error: Missing files: design.md, tasks.md"
- Suggest: "Run /spec-design and /spec-tasks first."

**If coverage incomplete**:
- Mark in context.json: `"finalized": false, "coverage_issues": [....]`
- Display issues:
  ```
  Coverage issues found:
  - R5 has no design component
  - R7 has no implementation tasks
  - US-3 has no requirements

  Fix these issues before finalizing.
  ```
- If --verify-only: exit with error code
- If normal mode: write SPEC_INDEX.md with warnings, but mark incomplete

**If cross-link update fails**:
- Backup files: `requirements.md.bak`, `design.md.bak`, `tasks.md.bak`
- Attempt update
- If error: restore from backups
- Report: "Error updating cross-links: <reason>. Files restored."

**If SPEC_INDEX.md exists**:
- Overwrite without warning (SPEC_INDEX.md is generated, not user-edited)

## Verification Checklist

**Files**:
- [ ] context.json exists and valid
- [ ] requirements.md exists (>100 bytes)
- [ ] design.md exists (>100 bytes)
- [ ] tasks.md exists (>100 bytes)

**Content**:
- [ ] All user stories have ≥1 requirement
- [ ] All requirements have ≥1 design component
- [ ] All requirements have ≥1 task
- [ ] No orphaned requirements (in req but not in design/tasks)
- [ ] No orphaned tasks (in tasks but requirements not in req)

**Cross-links**:
- [ ] requirements.md links to design.md, tasks.md
- [ ] design.md links to requirements.md, tasks.md
- [ ] tasks.md links to requirements.md, design.md

**Dependencies**:
- [ ] Task dependencies form DAG (no cycles)
- [ ] Requirement dependencies valid

## --verify-only Mode

**Use case**: Check spec completeness without modifying files

**Output**:
```
Verification Results:

Files: ✅ All present
Content: ⚠ Issues found
  - R5 missing design component
  - R7 missing tasks

Cross-links: ❌ Not present
  - requirements.md missing Related Documents section
  - design.md missing Related Documents section

Recommendation: Run /spec-finalize (without --verify-only) to fix.
```

**Exit code**: 0 if all checks pass, 1 if issues found

## Template (SPEC_INDEX.md)

```markdown
# Specification Index: <Title>

## Metadata
- **Type**: <bug|feature>
- **Issue**: <link>
- **Status**: Ready for Implementation

## Documents
- [Requirements](./requirements.md) - <summary>
- [Design](./design.md) - <summary>
- [Tasks](./tasks.md) - <summary>

## Traceability Summary
<table>

## Next Steps
1. Review documents
2. Create branch
3. Implement tasks
```

## Next Actions

After this skill completes, the spec package is **ready for implementation**:

1. **Review** SPEC_INDEX.md for complete traceability summary
2. **Verify** all cross-links work between documents
3. **Check** coverage is 100% (all requirements → design → tasks)
4. **Begin implementation**:
   - Create feature branch per PR workflow in tasks.md
   - Start with task T1 (first in dependency order)
   - Follow commit conventions and sign commits (`git commit -S`)
   - Create PRs with `AI-Assisted` label

**Workflow complete** - no further spec skills needed unless updates required.
