---
name: spec-design
description: Generate design.md with architecture and components
user-invokable: true
argument-hint: "[requirements-path | spec-dir] [--skip-plan-agent] [--alternatives=N]"
---

# Spec Design Writer

Generate design.md with technical architecture, components, and implementation details from requirements.

## Input

**Arguments**:
- `requirements-path`: Path to requirements.md OR spec directory (auto-finds requirements.md)
- `--skip-plan-agent`: Don't launch Plan agent for complex decisions (faster)
- `--alternatives=N`: Show N alternative approaches (default: 0, max: 3)

**Example**:
```bash
/spec-design docs/bugs/b006-fix-login-timeout/requirements.md
/spec-design docs/bugs/b006-fix-login-timeout/
/spec-design --alternatives=2
/spec-design --skip-plan-agent
```

## Operations

### 1. Read Requirements

**Auto-detect path**:
- If argument is directory: look for `requirements.md` inside
- If argument is file: use directly
- If no argument: search cwd for `requirements.md`

**Extract**:
- Numbered requirements (R1, R2, ...)
- User stories (US-1, US-2, ...)
- EARS patterns and constraints
- Dependencies between requirements

### 2. Read Context (if available)

**Read context.json** (same directory as requirements.md):
- Extract: spec type, project context, user decisions
- Use to inform design choices

### 3. Launch Plan Agent (unless --skip-plan-agent)

**When to launch**:
- Complex architectural decisions (e.g., "Which state management approach?")
- Multiple viable approaches (e.g., "REST vs GraphQL")
- Cross-cutting concerns (e.g., "How to handle caching?")

**Skip if**:
- Straightforward bug fix (no architecture change)
- Requirements explicitly specify implementation
- User provided --skip-plan-agent flag

**Launch**:
```
Agent tool with subagent_type=Plan
Prompt: "Design architecture for <feature> satisfying requirements R1-R8. Consider: <constraints>"
```

### 4. Draft Design Document

**Structure**:
```markdown
# Design: <Feature/Bug Title>

## Overview
<1-2 paragraph summary of approach>

## Architecture

### Components

#### Component 1: <Name>
**Responsibility**: <What it does>
**Interfaces**: <Public API>
**Dependencies**: <What it depends on>
**Rationale**: Satisfies R1, R3

#### Component 2: <Name>
**Responsibility**: <What it does>
**Interfaces**: <Public API>
**Dependencies**: Component 1
**Rationale**: Satisfies R2, R4

### Data Structures

#### Structure 1: <Name>
```<language>
type SessionConfig struct {
    Timeout      time.Duration
    RefreshToken bool
}
```
**Purpose**: Stores session configuration
**Requirements**: R1, R5

### Data Flow

```
User Request → Middleware → Auth Handler → Session Manager → Database
                                              ↓
                                        Timeout Monitor
```

### API Contracts (if applicable)

#### Endpoint 1: POST /auth/login
**Request**:
```json
{
  "username": "string",
  "password": "string"
}
```

**Response**:
```json
{
  "token": "string",
  "expires_in": 3600
}
```

**Requirements**: R1, R2

## Implementation Details

### Component Interactions
1. User submits login → Auth Handler validates (R1)
2. Handler creates session → Session Manager stores (R2)
3. Timeout Monitor checks expiry → Logs out on timeout (R4)

### Configuration
- Timeout: Read from `config/auth.yaml` (R5)
- Default: 30 minutes if not configured (R6)

### Error Handling
- Invalid credentials → 401 Unauthorized (R7)
- Session timeout → 403 Forbidden + redirect (R8)

## Alternative Approaches (if --alternatives)

### Alternative 1: <Approach Name>
**Pros**: <Benefits>
**Cons**: <Drawbacks>
**Decision**: Rejected because <reason>

### Alternative 2: <Approach Name>
**Pros**: <Benefits>
**Cons**: <Drawbacks>
**Decision**: Selected because <reason>

## Requirements Coverage

| Requirement | Covered By |
|-------------|------------|
| R1 | Auth Handler, SessionConfig |
| R2 | Session Manager |
| R3 | Timeout Monitor |
| ... | ... |

## Open Questions
- Q1: Should session refresh be automatic or manual?
- Q2: What database index strategy for session lookup?
```

### 5. Verify Requirements Coverage

**Cross-check**:
- Every requirement (R1, R2, ...) mentioned in design
- No orphaned requirements (missing from design)
- No extra features (not in requirements)

**Add coverage table** (see template above)

### 6. Write design.md

**Write to**: `<directory>/design.md`

### 7. Update context.json

```json
{
  "design_written": true,
  "updated_at": "2026-03-05T11:30:00Z"
}
```

### 8. Display Output

**To user**:
```
Generated design.md:
- 4 components: Auth Handler, Session Manager, Timeout Monitor, Config Loader
- 2 data structures: SessionConfig, SessionToken
- 8 requirements covered (R1-R8)
- 2 alternative approaches evaluated

Coverage: 100% (all requirements addressed)

Next: Review design.md → /spec-tasks
```

## Output

- `design.md` written to spec directory
- context.json updated with `design_written: true`
- **Exit**: Returns control to main assistant

## Error Handling

**If requirements.md missing**:
- Search parent directories
- If not found: "Error: requirements.md not found. Run /spec-requirements first."

**If Plan agent fails**:
- Continue with manual design (no agent input)
- Note in output: "Plan agent skipped (errors encountered)"

**If design file exists**:
- Warn: "design.md exists. Overwrite? (y/n)"
- If no: abort
- If yes: backup to `design.md.bak`

**If requirements not covered**:
- Mark incomplete in context.json: `"design_complete": false`
- Add to design.md: `## Missing Coverage\n- R5: Not yet addressed`
- Note in output: "Partial design (R5 missing coverage)"

## Design Patterns

**For bug fixes**:
- Focus on affected components only
- Show before/after architecture
- Minimal scope (don't redesign unaffected parts)

**For features**:
- Show full component hierarchy
- Include new data models
- Document integration points with existing system

**For refactoring**:
- Show old vs new architecture side-by-side
- Migration plan
- Backward compatibility strategy

## Template (Minimal)

```markdown
# Design: <Title>

## Overview
<Summary>

## Components

### <Component Name>
**Responsibility**: <What>
**Requirements**: R1, R2

## Data Structures

### <Structure Name>
```<language>
<code>
```
**Requirements**: R3

## Requirements Coverage
| Req | Covered By |
|-----|------------|
| R1  | Component A |
```

## Next Actions

After this skill completes:

1. **Review** design.md to ensure architecture is sound
2. **Verify** all requirements (R1, R2, ...) have design coverage
3. **Check** alternative approaches section (if generated)
4. **Invoke** `/spec-tasks` to create implementation work breakdown:
   ```bash
   /spec-tasks
   ```
   Or specify the spec directory:
   ```bash
   /spec-tasks docs/bugs/b006-fix-login-timeout/
   ```
