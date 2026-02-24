# TDD Anti-Patterns

Common mistakes and how to avoid them. Consult when debugging TDD workflow issues.

---

## Implementation Before Test

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

## Not Verifying Test Failure

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

## Multiple Assertions in One Test

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

## Over-Engineering During GREEN

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

## Refactoring Without Test Safety Net

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

## Testing Mock Behavior Instead of Real Behavior

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

## Adding Test-Only Methods to Production Classes

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

## Mocking Without Understanding Dependencies

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

## Testing Multiple Behaviors in One Test

See "Multiple Assertions in One Test" above.

---

## Treating All Slowness as TDD Failure

**WRONG:**
```
"This test took 5 minutes to write, TDD is inefficient"
→ Abandons TDD, writes implementation directly
→ Spends 2 hours debugging mysterious bug later
```

**RIGHT:**
```
"Test took 5 minutes, implementation 30 seconds"
→ Test clarified requirements
→ Implementation was trivial because test showed the way
→ Saved hours of debugging
```

**Why:** Test setup cost amortizes across all future tests. First test pays infrastructure cost (httptest, fixtures), subsequent tests are fast.

---

## Not Categorizing Test Failures

**WRONG:**
```
$ go test
./middleware_test.go:19:13: undefined: ErrorMiddleware
FAIL

"Test failed, let me write implementation"
→ Doesn't distinguish between broken test and correct RED failure
```

**RIGHT:**
```
$ go test
./middleware_test.go:19:13: undefined: ErrorMiddleware
FAIL

"Failure type: 'undefined' - correct for Cycle 1 (new function)"
→ Verified this is expected RED failure, proceed to GREEN
```

**Why:** Broken tests (syntax errors, import errors) lead to false GREEN. Must verify failure type matches expected (undefined, assertion failure, type error).
