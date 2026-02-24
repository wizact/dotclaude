---
name: test-driven-development
description: Use when implementing features, fixing bugs, or refactoring code. Enforces TDD red-green-refactor discipline - write failing tests first, minimal implementation second, then refactor. Prevents writing implementation before tests, skipping test failure verification, over-engineering during green phase, or bundling multiple behaviors in one test. Keywords trigger automatic invocation - tdd, test first, write tests, unit test, test coverage
user-invokable: true
---

# Test-Driven Development

## Iron Law

**NO IMPLEMENTATION WITHOUT FAILING TEST FIRST**

You MUST verify test failure before writing implementation. A passing test before implementation means the test is broken.

## When to Use This Skill

Use TDD for ALL code changes:

- ✓ Adding new features (any size)
- ✓ Fixing bugs
- ✓ Refactoring existing code
- ✓ Modifying behavior

**Except:**
- Mistakes requiring immediate revert
- Anti-patterns discovered during code review
- "Simple" one-line changes
- "Obvious" fixes
- "Quick" refactors
- "Trivial" updates

**NO OTHER EXCEPTIONS.** User override only.

## The Five Phases

```mermaid
graph TD
    Start([User Task]) --> Think[Phase 1: THINK]
    Think --> Red[Phase 2: RED<br/>Write Test]
    Red --> VerifyRed{Verify:<br/>Test Fails?}
    VerifyRed -->|No - Test Passes| RedError[ERROR: Test must fail first]
    RedError --> Red
    VerifyRed -->|Yes - Correct Failure| Green[Phase 3: GREEN<br/>Implement]
    Green --> VerifyGreen{Verify:<br/>Test Passes?}
    VerifyGreen -->|No| Green
    VerifyGreen -->|Yes| Refactor[Phase 4: REFACTOR]
    Refactor --> VerifyRefactor{Tests<br/>Still Pass?}
    VerifyRefactor -->|No| RefactorError[ERROR: Broke tests]
    RefactorError --> Refactor
    VerifyRefactor -->|Yes| MoreWork{More<br/>Behaviors?}
    MoreWork -->|Yes| Think
    MoreWork -->|No| Done([Complete])

    style RedError fill:#ff6b6b
    style RefactorError fill:#ff6b6b
    style VerifyRed fill:#ffd93d
    style VerifyGreen fill:#6bcf7f
    style VerifyRefactor fill:#6bcf7f
```

### Phase 1: THINK (Strategy)

Explore and define what behavior you're implementing before writing ANY code.

**Activities:**
- Identify ONE specific behavior to implement
- Define clear success criteria
- Define happy path and edge cases to implement in this cycle
- Plan test scope (what to assert, what to ignore)
- Write one-sentence test objective

**Output:** Clear statement like "Test that `parseJSON` returns error for invalid input"

**Exit criteria:** You can articulate exactly what the test will verify

---

### Phase 2: RED (Write Failing Test)

Write minimal test that fails for the RIGHT reason.

**<HARD-GATE>**
Do NOT proceed to Phase 3 GREEN until:
1. Test is written
2. Test is executed
3. Test FAILS
4. Failure message matches expected error
**</HARD-GATE>**

**Activities:**
- Write minimal test (< 10 lines typical)
- Single assertion only
- Execute test
- **VERIFY:** Confirm exact failure message
- Document why test fails

**What to write:**
```
Test structure:
1. Setup (arrange)
2. Action (act)
3. Assert (one thing)
```

**What NOT to write:**
- ✗ Multiple assertions
- ✗ Testing multiple behaviors
- ✗ Complex setup logic
- ✗ Implementation code

**Verification checkpoint:**
```
BEFORE GREEN: Confirm test output shows:
- Test executed
- Test FAILED
- Error message matches expectation
```

**If test passes:** STOP. Test is broken. Fix test, not implementation.

**Exit criteria:** Test fails with expected error message

---

### Phase 3: GREEN (Minimal Implementation)

Write simplest code to pass test. Nothing more.

**<HARD-GATE>**
Entry requirements:
1. Test exists
2. Test is FAILING
3. Failure verified in Phase 2
**</HARD-GATE>**

**Activities:**
- Write minimal code to pass test
- Hardcoding is acceptable
- No refactoring
- No optimization
- Execute tests
- Verify passage

**What minimal means:**
- Hardcode return values if that passes test
- Use simplest logic possible
- Ignore edge cases not in current test
- Copy-paste acceptable
- Bad names acceptable

**What NOT to do:**
- ✗ Refactor while implementing
- ✗ Optimize prematurely
- ✗ Handle cases not in test
- ✗ Add multiple features
- ✗ Clean up existing code

**Verification checkpoint:**
```
AFTER GREEN: Confirm test output shows:
- All tests executed
- All tests PASSED
- No warnings/errors
```

**Exit criteria:** Test passes, no other tests break

---

### Phase 4: REFACTOR (Improve Design)

Improve structure while keeping tests green.

**<HARD-GATE>**
Entry requirements:
1. All tests PASSING
2. Implementation complete for current behavior
**</HARD-GATE>**

**Activities:**
- Improve structure/naming/duplication
- One refactoring at a time
- Run tests after EACH change
- Revert if tests fail
- Skip if no obvious improvements

**What to refactor:**
- Extract duplicated code
- Improve variable names
- Simplify logic
- Remove hardcoding (if multiple tests exist)
- Improve readability

**What NOT to refactor:**
- ✗ Multiple changes at once
- ✗ Add new features
- ✗ Change behavior
- ✗ Optimize without measurement

**Verification checkpoint:**
```
AFTER EACH REFACTOR: Confirm:
- All tests still PASSING
- No new warnings
- Behavior unchanged
```

**If tests fail:** STOP. Revert refactoring. Tests define correctness.

**Exit criteria:** Tests pass, code improved (or no improvements needed)

---

### Phase 5: REPEAT

Return to Phase 1 for next behavior.

**When to repeat:**
- Feature has more behaviors to implement
- Bug has more cases to fix
- Refactoring has more improvements

**When to stop:**
- All required behaviors implemented
- All tests passing
- No obvious improvements remaining

---

## Anti-Skipping Guardrails

**If you think ANY of these, STOP immediately:**

| Thought | Reality |
|---------|---------|
| "This is a simple fix, no TDD required" | Simple fixes need tests too. Return to Phase 1. |
| "The change is obvious" | Obvious changes still need verification. Return to Phase 1. |
| "Just a quick refactor" | Refactoring requires test safety net. Return to Phase 1. |
| "Only renaming variables" | Tests verify no behavior change. Return to Phase 1. |
| "Too small to test" | If too small to break, prove it with test. Return to Phase 1. |
| "I'll write implementation first, then tests" | STOP. Tests first. Return to Phase 2. |
| "Test passes already, that's good" | STOP. Test must fail first. Fix test. |
| "Let me add multiple assertions" | STOP. One assertion per test. Split tests. |
| "I'll refactor while implementing" | STOP. GREEN phase is minimal only. |

**User override only:** TDD can ONLY be skipped with explicit user permission.

---

## Red Flags

These thoughts mean you're breaking TDD:

**During RED phase:**
- "Let me write the implementation to see what test should look like"
- "I'll make the test pass immediately"
- "This test covers multiple scenarios"

**During GREEN phase:**
- "While I'm here, I'll clean up this code"
- "Let me handle these edge cases too"
- "I'll use a better algorithm"

**During REFACTOR phase:**
- "I'll add this feature while refactoring"
- "Let me refactor multiple things at once"
- "Tests might fail but I'll fix them after"

**ALL mean: STOP. Return to appropriate phase.**

---

## Verification Checkpoints

### RED Exit Verification
```
Before GREEN phase:
✓ Test written
✓ Test executed
✓ Test FAILED
✓ Failure message matches expected error
✓ Documented why test fails
```

### GREEN Exit Verification
```
Before REFACTOR phase:
✓ Implementation written
✓ Tests executed
✓ All tests PASSED
✓ No new warnings
✓ Minimal implementation only
```

### REFACTOR Exit Verification
```
After each refactoring:
✓ Tests executed
✓ All tests still PASSED
✓ No behavior change
✓ Code improved
```

---

## Quick Reference

| Phase | Goal | Exit Criteria |
|-------|------|---------------|
| **THINK** | Define behavior | Can articulate test objective |
| **RED** | Write failing test | Test fails with expected error |
| **GREEN** | Minimal implementation | Test passes, minimal code |
| **REFACTOR** | Improve design | Tests pass, code improved |
| **REPEAT** | Next behavior | More work exists |

---

## Examples

### Feature: Add JSON parsing

**THINK:** Test that `parseJSON` returns error for invalid input

**RED:**
```go
func TestParseJSON_InvalidInput(t *testing.T) {
    _, err := parseJSON("invalid")
    if err == nil {
        t.Error("expected error for invalid JSON")
    }
}
```
Execute → FAILS: "undefined: parseJSON" ✓ Correct failure

**GREEN:**
```go
func parseJSON(input string) (map[string]interface{}, error) {
    return nil, errors.New("invalid JSON")
}
```
Execute → PASSES ✓

**REFACTOR:** (skip, nothing to improve yet)

**REPEAT:** THINK: Test that `parseJSON` parses valid JSON...

---

### Bugfix: Handle nil pointer

**THINK:** Test that `processUser` doesn't crash on nil user

**RED:**
```go
func TestProcessUser_NilUser(t *testing.T) {
    err := processUser(nil)
    if err == nil {
        t.Error("expected error for nil user")
    }
}
```
Execute → FAILS: "panic: nil pointer dereference" ✓ Wrong error type, but confirms bug

**GREEN:**
```go
func processUser(user *User) error {
    if user == nil {
        return errors.New("user cannot be nil")
    }
    // existing logic...
}
```
Execute → PASSES ✓

**REFACTOR:** Extract error constant

**REPEAT:** (done, bug fixed)

---

### Refactor: Extract duplicated logic

**THINK:** Test that `formatName` handles existing cases

**RED:**
```go
func TestFormatName_FirstLast(t *testing.T) {
    result := formatName("John", "Doe")
    expected := "Doe, John"
    if result != expected {
        t.Errorf("got %s, want %s", result, expected)
    }
}
```
Execute → FAILS: "undefined: formatName" ✓ Correct (function doesn't exist yet)

**GREEN:**
```go
func formatName(first, last string) string {
    return last + ", " + first
}
```
Execute → PASSES ✓

**REFACTOR:** Replace duplicated logic in codebase with `formatName` calls

**REPEAT:** (done, duplication removed)

---

## Common Mistakes and Anti-Patterns

### Implementation Before Test

**WRONG:**
```
1. Write parseJSON function
2. Write test for parseJSON
```

**RIGHT:**
```
1. Write test for parseJSON (fails)
2. Write parseJSON function (passes)
```

**Why:** Test must fail first to prove it actually tests something.

---

### Not Verifying Test Failure

**WRONG:**
```
1. Write test
2. Assume it will fail
3. Write implementation
```

**RIGHT:**
```
1. Write test
2. Execute test, confirm failure message
3. Write implementation
```

**Why:** Test might pass for wrong reasons (typo, wrong assertion, etc).

---

### Multiple Assertions in One Test

**WRONG:**
```go
func TestParseJSON(t *testing.T) {
    result, err := parseJSON(`{"key": "value"}`)
    if err != nil {
        t.Error("unexpected error")
    }
    if result["key"] != "value" {
        t.Error("wrong value")
    }
    if len(result) != 1 {
        t.Error("wrong length")
    }
}
```

**RIGHT:**
```go
func TestParseJSON_ValidInput_NoError(t *testing.T) {
    _, err := parseJSON(`{"key": "value"}`)
    if err != nil {
        t.Error("unexpected error")
    }
}

func TestParseJSON_ValidInput_ParsesValue(t *testing.T) {
    result, _ := parseJSON(`{"key": "value"}`)
    if result["key"] != "value" {
        t.Error("wrong value")
    }
}
```

**Why:** One test per behavior. Clear failure messages. Easier debugging.

---

### Over-Engineering During GREEN

**WRONG:**
```go
// GREEN phase implementation
func parseJSON(input string) (map[string]interface{}, error) {
    // Validate input
    if len(input) == 0 {
        return nil, errors.New("empty input")
    }

    // Optimize with custom parser
    parser := NewOptimizedParser()

    // Handle edge cases
    result, err := parser.Parse(input)
    if err != nil {
        return nil, fmt.Errorf("parse error: %w", err)
    }

    return result, nil
}
```

**RIGHT:**
```go
// GREEN phase implementation
func parseJSON(input string) (map[string]interface{}, error) {
    var result map[string]interface{}
    err := json.Unmarshal([]byte(input), &result)
    return result, err
}
```

**Why:** GREEN phase is minimal implementation only. Refactor later.

---

### Refactoring Without Test Safety Net

**WRONG:**
```
1. Notice duplicated code
2. Extract function immediately
3. Hope nothing breaks
```

**RIGHT:**
```
1. Notice duplicated code
2. Verify tests exist and pass
3. Extract function
4. Run tests, confirm still passing
```

**Why:** Tests prove refactoring didn't break behavior.

---

### Testing Mock Behavior Instead of Real Behavior

**WRONG:**
```go
func TestProcessUser(t *testing.T) {
    mock := &MockUserService{}
    mock.On("GetUser").Return(&User{Name: "test"})

    result := mock.GetUser()

    // Testing that mock returns what we told it to return
    if result.Name != "test" {
        t.Error("mock didn't work")
    }
}
```

**RIGHT:**
```go
func TestProcessUser(t *testing.T) {
    // Use real UserService with test database or in-memory store
    service := NewUserService(testDB)
    service.CreateUser(&User{Name: "test"})

    // Test actual behavior
    result := service.GetUser(1)

    if result.Name != "test" {
        t.Error("service didn't retrieve user correctly")
    }
}
```

**Why:** Tests should verify real behavior, not mock configuration.

---

### Adding Test-Only Methods to Production Classes

**WRONG:**
```go
type UserService struct {
    db Database
}

// Test-only method polluting production code
func (s *UserService) SetMockDB(mockDB Database) {
    s.db = mockDB
}
```

**RIGHT:**
```go
type UserService struct {
    db Database
}

// Production code stays clean
func NewUserService(db Database) *UserService {
    return &UserService{db: db}
}

// Tests use constructor with test database
func TestUserService(t *testing.T) {
    testDB := NewTestDatabase()
    service := NewUserService(testDB)
    // Test with real interface, test implementation
}
```

**Why:** Production code shouldn't know about testing. Use dependency injection.

---

### Mocking Without Understanding Dependencies

**WRONG:**
```go
// Mock everything reflexively
mockDB := &MockDB{}
mockCache := &MockCache{}
mockLogger := &MockLogger{}
mockMetrics := &MockMetrics{}
mockValidator := &MockValidator{}
// ... test becomes mock configuration exercise
```

**RIGHT:**
```go
// Use real implementations for simple dependencies
logger := log.NewNopLogger()  // Real logger, no output
validator := NewValidator()    // Real validator, pure logic

// Mock only external/slow dependencies
mockDB := &MockDB{}  // External I/O
mockCache := &MockCache{}  // External I/O

service := NewService(mockDB, mockCache, logger, validator)
// Test actual logic with minimal mocking
```

**Why:** Over-mocking tests implementation details, not behavior. Mock boundaries, not logic.

---

### Testing Multiple Behaviors in One Test

See "Multiple Assertions in One Test" above.

---

## Verification Checklist

Before marking work complete, verify ALL items:

PRE-COMPLETION CHECKLIST:
- [ ] Every new function/method has a test
- [ ] Watched each test fail before implementing
- [ ] Each test failed for expected reason (feature missing, not typo)
- [ ] Wrote minimal code to pass each test
- [ ] All tests pass
- [ ] Output pristine (no errors, warnings)
- [ ] Tests use real code (mocks only if unavoidable)
- [ ] Edge cases covered (nil, empty, invalid input)
- [ ] Error cases covered (failures, exceptions)
- [ ] No test-only methods in production code
- [ ] No testing mock behavior instead of real behavior
- [ ] No multiple behaviors in single test
- [ ] No mocks without understanding why

**If ANY item unchecked:** Work is NOT complete. Return to appropriate phase.

---

## Language-Specific Notes

**Infer from codebase:**
- Test framework (Go: testing / testify, Python: pytest, etc)
- Test file naming (`*_test.go`, `test_*.py`, etc)
- Assertion style (table-driven, BDD, etc)

**When in doubt:** Ask user for test framework preference.

## Integration with Other Workflows

**TDD composes with:**
- Feature development (use TDD for each feature slice)
- Bug fixing (use TDD to reproduce, then fix)
- Refactoring (use tests as safety net)
- Code review (verify tests exist and follow TDD)

**TDD does NOT replace:**
- Integration tests (TDD focuses on unit tests)
- Manual testing (TDD verifies logic, not UX)
- System design (TDD implements design, doesn't create it)

---

## Summary

**The Workflow:**
1. **THINK:** What behavior am I implementing?
2. **RED:** Write test that fails
3. **GREEN:** Write minimal code to pass
4. **REFACTOR:** Improve code structure
5. **REPEAT:** Next behavior

**The Gates:**
- No GREEN without failing test
- No REFACTOR without passing tests
- No skipping phases

**The Discipline:**
- All code changes use TDD
- One behavior per cycle
- Minimal implementation in GREEN
- Verify at every checkpoint

**The Result:**
- Fast feedback cycles
- High test coverage
- Confident refactoring
- Clear regression detection
