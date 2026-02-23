---
title: Test Helpers Never Return Errors
impact: HIGH
impactDescription: Simplifies test code, fails tests immediately, clear test failures
tags: testing, test-helpers, go
category: test
---

## Test Helpers Never Return Errors

Test helpers should fail the test (t.Fatalf) instead of returning errors. This keeps test code clean.

**Incorrect (returns error):**

```go
// Forces every caller to check error
func createTask(t *testing.T, desc string) (Task, error) {
    t.Helper()
    return NewTask(desc)
}

// Test must handle error
func TestTaskCompletion(t *testing.T) {
    task, err := createTask(t, "test task")
    if err != nil {
        t.Fatalf("failed to create task: %v", err)  // Boilerplate!
    }

    // Actual test logic
    err = task.Complete()
    if err != nil {
        t.Errorf("Complete() failed: %v", err)
    }
}
```

**Correct (fails test immediately):**

```go
// Fails test immediately on error
func mustCreateTask(t *testing.T, desc string) Task {
    t.Helper()
    task, err := NewTask(desc)
    if err != nil {
        t.Fatalf("failed to create task: %v", err)
    }
    return task
}

// Clean test code
func TestTaskCompletion(t *testing.T) {
    task := mustCreateTask(t, "test task")  // No error handling!

    // Focus on actual test logic
    err := task.Complete()
    if err != nil {
        t.Errorf("Complete() failed: %v", err)
    }
}
```

**Test helper with cleanup:**

```go
// Returns cleanup function
func createTempFile(t *testing.T, content string) (string, func()) {
    t.Helper()

    tmpFile, err := os.CreateTemp("", "test-*.txt")
    if err != nil {
        t.Fatalf("failed to create temp file: %v", err)
    }

    if _, err := tmpFile.WriteString(content); err != nil {
        tmpFile.Close()
        os.Remove(tmpFile.Name())
        t.Fatalf("failed to write to temp file: %v", err)
    }
    tmpFile.Close()

    cleanup := func() {
        os.Remove(tmpFile.Name())
    }

    return tmpFile.Name(), cleanup
}

// Usage
func TestReadFile(t *testing.T) {
    path, cleanup := createTempFile(t, "test content")
    defer cleanup()  // Cleanup automatically

    content, err := ReadFile(path)
    require.NoError(t, err)
    assert.Equal(t, "test content", content)
}
```

**Multiple helpers:**

```go
func mustCreateUser(t *testing.T, email string) *User {
    t.Helper()
    user, err := NewUser(email)
    if err != nil {
        t.Fatalf("failed to create user: %v", err)
    }
    return user
}

func mustHashPassword(t *testing.T, password string) string {
    t.Helper()
    hash, err := HashPassword(password)
    if err != nil {
        t.Fatalf("failed to hash password: %v", err)
    }
    return hash
}

// Clean test using multiple helpers
func TestUserAuthentication(t *testing.T) {
    user := mustCreateUser(t, "test@example.com")
    user.PasswordHash = mustHashPassword(t, "secret123")

    // Test logic without error handling clutter
    err := AuthenticateUser(user.Email, "secret123")
    assert.NoError(t, err)
}
```

**Benefits:**
- Cleaner test code (no error handling boilerplate)
- Fails fast with clear message
- t.Helper() shows correct line number in failure
- Focus on test logic, not setup

**Always use t.Helper():**
```go
func mustDoSomething(t *testing.T) Result {
    t.Helper()  // Reports error at caller's line, not here
    // ...
}
```

**Applies to**: All test helper functions
