---
name: spec-requirements
description: Generate requirements.md with EARS notation from context
user-invokable: true
argument-hint: "[context-file] [--manual-input] [--answers=json]"
---

# Spec Requirements Writer

Generate requirements.md with EARS notation (Easy Approach to Requirements Syntax) from gathered context.

## Input

**Arguments**:
- `context-file`: Path to context.json (or auto-detect from cwd)
- `--manual-input`: Skip context.json, gather requirements manually from user
- `--answers=json-string`: User answers to clarification questions

**Example**:
```bash
/spec-requirements docs/bugs/b006-fix-login-timeout/context.json
/spec-requirements --answers='{"timeout":"configurable","sessions":"invalidate"}'
/spec-requirements --manual-input
```

## Operations

### 1. Read Context

**If context.json exists**:
- Read context.json from provided path or auto-detect in cwd
- Extract: issue description, spec type, context summary, clarification questions

**If --manual-input**:
- Prompt user: "Describe the feature/bug:"
- Prompt user: "Spec type (bug/feature):"
- Skip to step 3

### 2. Collect User Answers

**If --answers provided**:
- Parse JSON string: `{"timeout":"configurable","sessions":"invalidate"}`
- Map answers to clarification questions by key

**If no --answers**:
- Display clarification questions from context.json
- Prompt user for each answer
- Format: `Q1: <question>` → User provides answer

**Update context.json**:
```json
{
  "user_decisions": {
    "timeout": "configurable",
    "sessions": "invalidate"
  }
}
```

### 3. Draft Requirements

**Structure**:
```markdown
# Requirements

## User Stories

### US-1: <Title>
**As a** <role>
**I want** <capability>
**So that** <benefit>

**Acceptance Criteria**:
- [ ] AC1: <EARS requirement>
- [ ] AC2: <EARS requirement>

## Functional Requirements

### R1: <Requirement Title>
**Pattern**: Ubiquitous
**Statement**: The system SHALL <action> <object> <constraint>.

**Rationale**: <Why this requirement exists>
**Dependencies**: None
**Verification**: <How to test>

### R2: <Requirement Title>
**Pattern**: Event-Driven
**Statement**: WHEN <trigger event> the system SHALL <system response>.

**Rationale**: <Why>
**Dependencies**: R1
**Verification**: <How to test>
```

**EARS Patterns** (use all applicable):

1. **Ubiquitous** (always active):
   - `The system SHALL <action>`
   - Example: "The system SHALL validate all user inputs."

2. **Event-Driven** (triggered by event):
   - `WHEN <event> the system SHALL <response>`
   - Example: "WHEN user submits invalid credentials, the system SHALL display error message."

3. **Unwanted Behavior** (safety/security):
   - `IF <condition> THEN the system SHALL <mitigation>`
   - Example: "IF login timeout occurs, THEN the system SHALL log user out."

4. **State-Driven** (depends on system state):
   - `WHILE <state> the system SHALL <action>`
   - Example: "WHILE session is active, the system SHALL refresh tokens every 15 minutes."

5. **Optional** (user-configurable):
   - `WHERE <feature enabled> the system SHALL <action>`
   - Example: "WHERE timeout is configurable, the system SHALL read timeout from config."

### 4. Number Requirements

- Sequential: R1, R2, R3, ...
- Cross-reference dependencies: "Depends on: R1, R3"
- Group by category: Authentication (R1-R3), Session (R4-R6)

### 5. Add Feasibility Check

**Append to requirements.md**:
```markdown
## Feasibility Verification

- [ ] All requirements testable/verifiable
- [ ] No contradictory requirements
- [ ] Dependencies form DAG (no cycles)
- [ ] Requirements traceable to user stories
- [ ] EARS patterns correctly applied
```

### 6. Write requirements.md

**Write to**: `<directory>/requirements.md`

### 7. Update context.json

```json
{
  "requirements_written": true,
  "requirements_count": 8,
  "updated_at": "2026-03-05T11:00:00Z"
}
```

### 8. Display Output

**To user**:
```
Generated requirements.md:
- 3 user stories
- 8 functional requirements (R1-R8)
- EARS patterns: Ubiquitous (3), Event-Driven (4), State-Driven (1)
- Dependencies: R2→R1, R4→R3

Feasibility: All requirements testable and non-contradictory

Next: Review requirements.md → /spec-design
```

## Output

- `requirements.md` written to spec directory
- context.json updated with `requirements_written: true`
- **Exit**: Returns control to main assistant

## Error Handling

**If context.json missing and no --manual-input**:
- Search parent directories for context.json
- If not found: "Error: context.json not found. Use --manual-input or provide path."

**If user answers incomplete**:
- Mark partial in context.json: `"user_decisions_complete": false`
- Write requirements.md with TODO markers: `<!-- TODO: Answer Q2 -->`
- Note in output: "Partial requirements (missing answers to Q2, Q3)"

**If requirements file exists**:
- Warn: "requirements.md exists. Overwrite? (y/n)"
- If no: abort
- If yes: backup to `requirements.md.bak`

## EARS Pattern Examples

**Ubiquitous**:
- `The system SHALL hash all passwords using bcrypt.`
- `The system SHALL validate email format before storage.`

**Event-Driven**:
- `WHEN user clicks logout, the system SHALL invalidate session token.`
- `WHEN timeout expires, the system SHALL display warning dialog.`

**Unwanted Behavior**:
- `IF session token is invalid, THEN the system SHALL redirect to login.`
- `IF database connection fails, THEN the system SHALL retry 3 times.`

**State-Driven**:
- `WHILE user is authenticated, the system SHALL allow access to dashboard.`
- `WHILE form is incomplete, the system SHALL disable submit button.`

**Optional**:
- `WHERE 2FA is enabled, the system SHALL prompt for verification code.`
- `WHERE debug mode is active, the system SHALL log all API calls.`

## Template (Minimal)

```markdown
# Requirements: <Feature/Bug Title>

## User Stories

### US-1: <Title>
**As a** user
**I want** <capability>
**So that** <benefit>

## Functional Requirements

### R1: <Title>
**Pattern**: <EARS pattern>
**Statement**: <EARS statement>
**Verification**: <Test method>

## Feasibility Verification
- [ ] All requirements testable
- [ ] No contradictions
- [ ] Dependencies valid
```

## Next Actions

After this skill completes:

1. **Review** requirements.md to ensure all requirements are clear and complete
2. **Verify** EARS patterns are correctly applied
3. **Check** feasibility verification checklist
4. **Invoke** `/spec-design` to create the technical architecture:
   ```bash
   /spec-design
   ```
   Or specify the requirements file path:
   ```bash
   /spec-design docs/bugs/b006-fix-login-timeout/requirements.md
   ```
