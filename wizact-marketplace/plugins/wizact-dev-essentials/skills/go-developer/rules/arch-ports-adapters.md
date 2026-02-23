---
title: Ports and Adapters Pattern
impact: CRITICAL
impactDescription: Enables swapping implementations, testing without dependencies, clear contracts
tags: architecture, ports-adapters, hexagonal-architecture, go
category: arch
---

## Ports and Adapters Pattern

Define interfaces (ports) for external dependencies. Implement concrete adapters that satisfy those interfaces.

**Incorrect (depends on concrete type):**

```go
// Locked to Postgres, can't swap or test easily
type TaskService struct {
    repo *PostgresTaskRepository
}
```

**Correct (depends on interface):**

```go
// ✅ Port (interface) - defines the contract
type TaskRepository interface {
    Save(ctx context.Context, task Task) error
    FindByID(ctx context.Context, id string) (Task, error)
}

// ✅ Adapter 1 - in-memory (implements TaskRepository)
type MemoryTaskRepository struct {
    tasks map[string]Task
    mu    sync.RWMutex
}

func (r *MemoryTaskRepository) Save(ctx context.Context, task Task) error {
    r.mu.Lock()
    defer r.mu.Unlock()
    r.tasks[task.ID] = task
    return nil
}

func (r *MemoryTaskRepository) FindByID(ctx context.Context, id string) (Task, error) {
    r.mu.RLock()
    defer r.mu.RUnlock()
    task, ok := r.tasks[id]
    if !ok {
        return Task{}, errors.New("task not found")
    }
    return task, nil
}

// ✅ Adapter 2 - PostgreSQL (implements TaskRepository)
type PostgresTaskRepository struct {
    db *sql.DB
}

func (r *PostgresTaskRepository) Save(ctx context.Context, task Task) error {
    _, err := r.db.ExecContext(ctx,
        "INSERT INTO tasks (id, description, done) VALUES ($1, $2, $3)",
        task.ID, task.Description, task.Done)
    return err
}

func (r *PostgresTaskRepository) FindByID(ctx context.Context, id string) (Task, error) {
    var task Task
    err := r.db.QueryRowContext(ctx,
        "SELECT id, description, done FROM tasks WHERE id = $1", id).
        Scan(&task.ID, &task.Description, &task.Done)
    if err == sql.ErrNoRows {
        return Task{}, errors.New("task not found")
    }
    return task, err
}

// ✅ Business logic depends on PORT (interface), not concrete adapter
type TaskService struct {
    repo TaskRepository  // Can use MemoryTaskRepository OR PostgresTaskRepository
}
```

**Benefits:**
- Swap implementations without changing business logic
- Test with in-memory adapter, run with PostgreSQL
- Clear contracts between layers
- Duck typing - both adapters satisfy interface automatically

**When to create ports:**
- External dependencies (databases, APIs, file systems)
- Multiple implementations exist/will exist
- Need to test without real dependency

**Applies to**: All project sizes
