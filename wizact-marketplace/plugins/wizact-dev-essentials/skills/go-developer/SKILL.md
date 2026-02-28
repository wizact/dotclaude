---
name: go-developer
description: Go development best practices - clean architecture, testing, security, and idiomatic patterns for production-ready code
user-invocable: true
---

# Go Developer

Production-ready Go development guidelines covering architecture, testing, security, and performance. Contains 26 rules across 7 categories, prioritized by impact.

## When to Apply

Reference these guidelines when:
- Writing new Go packages or services
- Implementing business logic or domain models
- Structuring application architecture
- Writing tests for Go code
- Reviewing code for best practices
- Refactoring existing Go code

## Rule Categories by Priority

| Priority | Category | Impact | Prefix | Count |
|----------|----------|--------|--------|-------|
| 1 | Architecture | CRITICAL | `arch-` | 5 |
| 2 | Security | CRITICAL | `security-` | 4 |
| 3 | Testing | HIGH | `test-` | 6 |
| 4 | Error Handling | HIGH | `error-` | 3 |
| 5 | Code Organization | MEDIUM | `org-` | 5 |
| 6 | Performance | MEDIUM | `perf-` | 2 |
| 7 | Patterns | LOW | `pattern-` | 1 |

## Quick Reference

### 1. Architecture (CRITICAL)

- `arch-dependency-direction` - Dependencies flow inward (outer → inner, never inner → outer)
- `arch-ports-adapters` - Define interfaces (ports) for external dependencies, implement concrete adapters
- `arch-dependency-inversion` - Depend on abstractions (interfaces), not concretions (structs)
- `arch-single-responsibility` - One responsibility per type/function
- `arch-open-closed` - Extend via interfaces, not modification

### 2. Security (CRITICAL)

- `security-sql-injection` - Always use parameterized queries ($1, $2), never string concatenation
- `security-password-hashing` - Use bcrypt with cost ≥12 for password hashing
- `security-input-validation` - Validate at system boundaries (user input, external APIs)
- `security-error-sanitization` - Never expose internal errors to users

### 3. Testing (HIGH)

- `test-table-driven` - Use table-driven tests with descriptive test case names
- `test-fixtures` - Store test data in testdata/ directory
- `test-helpers` - Test helpers fail tests (t.Fatalf), never return errors
- `test-gomock` - Use gomock for mocking interfaces in tests
- `test-no-mock-netconn` - Never mock net.Conn; use real connections or higher abstractions
- `test-config-defaults` - Avoid global state; use config structs with defaults

### 4. Error Handling (HIGH)

- `error-wrapping` - Wrap errors with context using fmt.Errorf with %w
- `error-sentinel` - Define package-level sentinel errors (var ErrNotFound = errors.New(...))
- `error-context` - Add context explaining what failed, not just raw errors

### 5. Code Organization (MEDIUM)

- `org-function-breakdown` - Break functions down judiciously (not too much, not too little)
- `org-package-structure` - Organize packages by domain/concern, not by type
- `org-guard-clauses` - Use early returns (guard clauses), not nested ifs
- `org-yagni` - Implement only what's needed now, not speculative features
- `org-simplicity` - Three similar lines better than premature abstraction

### 6. Performance (MEDIUM)

- `perf-concurrency` - Handle concurrent access with sync.Mutex/RWMutex when needed
- `perf-edge-cases` - Handle nil checks, empty collections, boundary values

### 7. Patterns (LOW)

- `pattern-config-defaults` - Configuration structs with sensible defaults (avoid globals)

## Scalable Architecture

Structure adapts to project complexity while principles remain constant:

**Small (< 1K lines)**: Single file organization
```
main.go
task.go          # Domain models
repository.go    # Ports
postgres.go      # Adapters
handlers.go      # HTTP
```

**Medium (1K-10K lines)**: Package-based structure
```
cmd/server/main.go
pkg/
  task/
    task.go       # Domain
    repository.go # Port
    service.go
  postgres/
    task_repo.go  # Adapter
  http/
    handlers.go
```

**Large (10K+ lines)**: Full layer separation
```
internal/
  task/
    domain/
      task.go
    application/
      service.go
    adapters/
      postgres_repo.go
      http_controller.go
    ports/
      repository.go
```

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

## How to Use

Reference individual rule files for detailed explanations and code examples:

```
@.claude/skills/go-developer/rules/arch-dependency-direction.md
@.claude/skills/go-developer/rules/security-sql-injection.md
```

Each rule file contains:
- Why it matters explanation
- Incorrect code example with explanation
- Correct code example with explanation
- Benefits and additional context

## Full Compiled Document

For complete guide with all rules expanded: `@.claude/skills/go-developer/REFERENCE.md`

## Anti-Patterns to Avoid

**Business Logic in Handlers:**

```go
// ❌ BAD: Handler directly accesses DB, contains business logic
func handleComplete(w http.ResponseWriter, r *http.Request) {
    task, _ := db.Query(...)
    task.Done = true
    db.Exec(...)
}

// ✅ GOOD: Delegate to service with proper error handling
func handleComplete(w http.ResponseWriter, r *http.Request) {
    id := r.URL.Query().Get("id")
    if id == "" {
        http.Error(w, "missing task id", http.StatusBadRequest)
        return
    }
    if err := taskService.Complete(id); err != nil {
        // Sanitize errors (see security-error-sanitization)
        http.Error(w, "failed to complete task", http.StatusInternalServerError)
        return
    }
    w.WriteHeader(http.StatusNoContent)
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

## Quick Checklist

Before submitting Go code:

**Architecture**:
- [ ] Dependencies flow inward
- [ ] Ports/adapters pattern used for external dependencies
- [ ] Single Responsibility Principle followed

**Security**:
- [ ] Parameterized SQL queries (no string concatenation)
- [ ] bcrypt for passwords (cost ≥12)
- [ ] Input validation at boundaries
- [ ] Sanitized error messages for users

**Testing**:
- [ ] Table-driven tests with descriptive names
- [ ] Test helpers fail tests instead of returning errors
- [ ] No global state (use config with defaults)
- [ ] Cleanup functions returned where needed

**Error Handling**:
- [ ] Errors wrapped with %w for context
- [ ] Guard clauses used (early returns)
- [ ] Edge cases handled (nil, empty, boundaries)

**Code Quality**:
- [ ] Functions broken down judiciously
- [ ] Packages organized by domain
- [ ] YAGNI (no speculative features)
- [ ] Simplest solution chosen
