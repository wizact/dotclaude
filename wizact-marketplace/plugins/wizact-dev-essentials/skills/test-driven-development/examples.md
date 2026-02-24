# TDD Examples

Complete TDD cycle walkthroughs demonstrating THINK → RED → GREEN → REFACTOR → REPEAT.

---

## Feature: Add JSON parsing

**THINK:**
```
Behavior: When parseJSON receives invalid input, then returns error
Scope: Malformed JSON, error != nil
Deferred: Valid JSON (next), empty strings (future)
Assertion: Error != nil
Test Name: TestParseJSON_InvalidInput_ReturnsError
```

**RED:**
```go
func TestParseJSON_InvalidInput_ReturnsError(t *testing.T) {
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

## Bugfix: Handle nil pointer

**THINK:**
```
Behavior: When processUser receives nil user, then returns error (no panic)
Scope: Nil check, error return
Deferred: Error message format (future)
Assertion: Error != nil, no panic
Test Name: TestProcessUser_NilUser_ReturnsError
```

**RED:**
```go
func TestProcessUser_NilUser_ReturnsError(t *testing.T) {
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

## Refactor: Extract duplicated logic

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

## HTTP Handler: Status Code

**THINK:**
```
Behavior: When request has no name param, then return status 200
Scope: GET /, HTTP status code check
Deferred: Response body (next), custom name (future)
Assertion: w.Code == 200
Test Name: TestHelloHandler_NoNameParam_Returns200
```

**RED:**
```go
func TestHelloHandler_NoNameParam_Returns200(t *testing.T) {
    req := httptest.NewRequest(http.MethodGet, "/", nil)
    w := httptest.NewRecorder()

    HelloHandler(w, req)

    if w.Code != http.StatusOK {
        t.Errorf("expected 200, got %d", w.Code)
    }
}
```
Execute → FAILS: "undefined: HelloHandler" ✓ Correct

**GREEN:**
```go
func HelloHandler(w http.ResponseWriter, r *http.Request) {
    name := r.URL.Query().Get("name")
    if name == "" {
        name = "World"
    }
    fmt.Fprintf(w, "Hello, %s", name)
}
```
Execute → PASSES ✓ (default status is 200)

**REFACTOR:** (skip, code is clear)

**REPEAT:** THINK: Test response body content...
