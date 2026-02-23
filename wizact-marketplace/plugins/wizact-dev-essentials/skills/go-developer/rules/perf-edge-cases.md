---
title: Handle Edge Cases
impact: MEDIUM
impactDescription: Prevents panics, handles boundary conditions, robust code
tags: performance, edge-cases, robustness, go
category: perf
---

## Handle Edge Cases

Always handle nil checks, empty collections, boundary values, and resource cleanup.

**Nil checks:**

```go
// ✅ Check for nil
func Process(task *Task) error {
    if task == nil {
        return errors.New("task is nil")
    }
    // Safe to use task
    task.Done = true
    return nil
}

// ❌ No nil check - will panic
func Process(task *Task) error {
    task.Done = true  // Panic if task is nil!
    return nil
}
```

**Empty collections:**

```go
// ✅ Check for empty
func ProcessTasks(tasks []Task) error {
    if len(tasks) == 0 {
        return errors.New("no tasks to process")
    }

    for _, task := range tasks {
        // Process
    }
    return nil
}

// ✅ Empty map handling
func GetUserTasks(tasksByUser map[string][]Task, userID string) []Task {
    tasks, ok := tasksByUser[userID]
    if !ok || len(tasks) == 0 {
        return []Task{}  // Return empty slice, not nil
    }
    return tasks
}
```

**Boundary values:**

```go
// ✅ Validate boundaries
func SetPriority(priority int) error {
    if priority < 1 || priority > 5 {
        return errors.New("priority must be 1-5")
    }
    // Safe to use
    return nil
}

func SetLimit(limit int) error {
    if limit <= 0 {
        return errors.New("limit must be positive")
    }
    if limit > 1000 {
        return errors.New("limit too large (max 1000)")
    }
    return nil
}

// ✅ String length validation
func SetDescription(desc string) error {
    if len(desc) == 0 {
        return errors.New("description required")
    }
    if len(desc) > 1000 {
        return errors.New("description too long (max 1000 chars)")
    }
    return nil
}
```

**Resource cleanup:**

```go
// ✅ Always defer cleanup
func ProcessFile(path string) error {
    file, err := os.Open(path)
    if err != nil {
        return err
    }
    defer file.Close()  // Cleanup on all exit paths

    // Process file
    return nil
}

// ✅ Database transaction cleanup
func UpdateTask(db *sql.DB, task Task) error {
    tx, err := db.Begin()
    if err != nil {
        return err
    }
    defer tx.Rollback()  // Rollback if not committed

    if err := doUpdate(tx, task); err != nil {
        return err  // Rollback happens
    }

    return tx.Commit()  // Success
}

// ✅ Context cancellation
func ProcessWithTimeout(ctx context.Context) error {
    ctx, cancel := context.WithTimeout(ctx, 30*time.Second)
    defer cancel()  // Release resources

    // Process
    return nil
}
```

**Division by zero:**

```go
// ✅ Check divisor
func Average(total, count int) (float64, error) {
    if count == 0 {
        return 0, errors.New("cannot divide by zero")
    }
    return float64(total) / float64(count), nil
}
```

**Index bounds:**

```go
// ✅ Check array bounds
func GetTaskAtIndex(tasks []Task, index int) (Task, error) {
    if index < 0 || index >= len(tasks) {
        return Task{}, errors.New("index out of bounds")
    }
    return tasks[index], nil
}
```

**Concurrent access:**

```go
// ✅ Handle concurrent access
type Cache struct {
    mu    sync.RWMutex
    items map[string]Task
}

func (c *Cache) Get(key string) (Task, bool) {
    c.mu.RLock()
    defer c.mu.RUnlock()

    task, ok := c.items[key]
    return task, ok
}

func (c *Cache) Set(key string, task Task) {
    c.mu.Lock()
    defer c.mu.Unlock()

    c.items[key] = task
}
```

**Benefits:**
- Prevents panics
- Robust code
- Clear error messages
- Predictable behavior

**Applies to**: All functions dealing with pointers, collections, boundaries
