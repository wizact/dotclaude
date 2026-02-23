---
title: Error Wrapping with %w
impact: HIGH
impactDescription: Preserves error chain, enables errors.Is/As, provides context for debugging
tags: error-handling, error-wrapping, go
category: error
---

## Error Wrapping with %w

Wrap errors with context using `fmt.Errorf` with `%w`. Preserves error chain for `errors.Is` and `errors.As`.

**Incorrect (loses context):**

```go
// Raw error - no context
func GetTask(id string) (Task, error) {
    task, err := repo.FindByID(id)
    if err != nil {
        return Task{}, err  // What failed? Which ID?
    }
    return task, nil
}

// String concatenation - breaks errors.Is
func SaveTask(task Task) error {
    err := repo.Save(task)
    if err != nil {
        return fmt.Errorf("save failed: %v", err)  // %v, not %w!
    }
    return nil
}
```

**Correct (wraps with context):**

```go
func GetTask(id string) (Task, error) {
    task, err := repo.FindByID(id)
    if err != nil {
        return Task{}, fmt.Errorf("failed to get task %s: %w", id, err)
    }
    return task, nil
}

func SaveTask(task Task) error {
    if err := repo.Save(task); err != nil {
        return fmt.Errorf("failed to save task %s: %w", task.ID, err)
    }
    return nil
}

// Enables errors.Is checking
if errors.Is(err, sql.ErrNoRows) {
    // Can detect specific errors through wrapping
}
```

**Layered error wrapping:**

```go
// Repository layer
func (r *TaskRepo) FindByID(ctx context.Context, id string) (Task, error) {
    var task Task
    err := r.db.QueryRowContext(ctx, "SELECT * FROM tasks WHERE id = $1", id).Scan(&task)
    if err != nil {
        return Task{}, fmt.Errorf("query failed for task %s: %w", id, err)
    }
    return task, nil
}

// Service layer
func (s *TaskService) GetTask(ctx context.Context, id string) (Task, error) {
    task, err := s.repo.FindByID(ctx, id)
    if err != nil {
        return Task{}, fmt.Errorf("service: failed to get task: %w", err)
    }
    return task, nil
}

// Handler layer
func (h *TaskHandler) HandleGet(w http.ResponseWriter, r *http.Request) {
    task, err := h.service.GetTask(r.Context(), taskID)
    if err != nil {
        log.Printf("error: %v", err)
        // Logs: "service: failed to get task: query failed for task 123: sql: no rows"
        http.Error(w, "task not found", 404)
    }
}
```

**Benefits:**
- Clear error context at each layer
- Preserves original error for `errors.Is`/`errors.As`
- Debugging shows full error chain
- Idiomatic Go error handling

**Use %w for:**
- Wrapping errors from dependencies
- Adding context to errors
- Preserving error chain

**Use %v for:**
- Logging only (when you don't need error chain)
- When you want to hide underlying error type

**Applies to**: All error returns
