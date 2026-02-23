---
title: Dependency Inversion
impact: CRITICAL
impactDescription: Decouples components, enables testing, supports dependency injection
tags: architecture, solid, dependency-inversion, go
category: arch
---

## Dependency Inversion

Depend on abstractions (interfaces), not concretions (structs). High-level modules should not depend on low-level modules.

**Incorrect (depends on concretion):**

```go
// Tightly coupled to PostgreSQL
type TaskService struct {
    repo *PostgresTaskRepository
}

// Can't test without database
// Can't swap to different storage
func NewTaskService(db *sql.DB) *TaskService {
    return &TaskService{
        repo: &PostgresTaskRepository{db: db},
    }
}
```

**Correct (depends on abstraction):**

```go
// Depends on interface (abstraction)
type TaskService struct {
    repo TaskRepository  // Interface
}

// Accepts any implementation of TaskRepository
func NewTaskService(repo TaskRepository) *TaskService {
    return &TaskService{repo: repo}
}

// Production code
func main() {
    db := openDB()
    repo := &PostgresTaskRepository{db: db}
    service := NewTaskService(repo)  // Inject concrete adapter
}

// Test code
func TestTaskService(t *testing.T) {
    repo := &MemoryTaskRepository{tasks: make(map[string]Task)}
    service := NewTaskService(repo)  // Inject test adapter
    // Test without database
}
```

**Benefits:**
- Swap implementations at runtime
- Test without external dependencies
- Clear separation of concerns
- Follows Open/Closed principle

**When to use:**
- External dependencies (databases, APIs, file systems)
- Multiple implementations exist/will exist
- Need testability without real dependency

**Don't create interfaces for:**
- One implementation, unlikely to change
- Internal helpers
- Simple utilities

**Applies to**: All project sizes
