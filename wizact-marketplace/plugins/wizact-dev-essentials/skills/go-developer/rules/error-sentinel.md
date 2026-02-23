---
title: Sentinel Errors
impact: HIGH
impactDescription: Enables explicit error checking, clear error types, better error handling
tags: error-handling, sentinel-errors, go
category: error
---

## Sentinel Errors

Define package-level sentinel errors for expected error conditions. Use `errors.Is` to check them.

**Pattern:**

```go
// Define sentinel errors at package level
var (
    ErrTaskNotFound    = errors.New("task not found")
    ErrInvalidTask     = errors.New("invalid task")
    ErrTaskAlreadyDone = errors.New("task already completed")
)

// Return sentinel errors
func (r *TaskRepo) FindByID(ctx context.Context, id string) (Task, error) {
    var task Task
    err := r.db.QueryRowContext(ctx, "SELECT * FROM tasks WHERE id = $1", id).Scan(&task)
    if err == sql.ErrNoRows {
        return Task{}, ErrTaskNotFound
    }
    if err != nil {
        return Task{}, fmt.Errorf("database error: %w", err)
    }
    return task, nil
}

// Check with errors.Is
func (s *TaskService) GetTask(ctx context.Context, id string) (Task, error) {
    task, err := s.repo.FindByID(ctx, id)
    if err != nil {
        if errors.Is(err, ErrTaskNotFound) {
            // Handle specific error
            return Task{}, ErrTaskNotFound
        }
        return Task{}, fmt.Errorf("failed to get task: %w", err)
    }
    return task, nil
}

// HTTP handler uses sentinel errors
func (h *TaskHandler) HandleGet(w http.ResponseWriter, r *http.Request) {
    task, err := h.service.GetTask(r.Context(), taskID)
    if err != nil {
        if errors.Is(err, ErrTaskNotFound) {
            http.Error(w, "task not found", 404)
            return
        }
        log.Printf("error getting task: %v", err)
        http.Error(w, "internal server error", 500)
        return
    }
    json.NewEncoder(w).Encode(task)
}
```

**Wrapped sentinel errors:**

```go
// Sentinel errors work through wrapping
func (s *TaskService) CompleteTask(ctx context.Context, id string) error {
    task, err := s.repo.FindByID(ctx, id)
    if err != nil {
        // Wraps ErrTaskNotFound
        return fmt.Errorf("complete: %w", err)
    }

    if task.Done {
        return fmt.Errorf("task %s: %w", id, ErrTaskAlreadyDone)
    }

    task.Done = true
    if err := s.repo.Save(ctx, task); err != nil {
        return fmt.Errorf("failed to save: %w", err)
    }

    return nil
}

// errors.Is finds wrapped sentinel
err := service.CompleteTask(ctx, "task-1")
if errors.Is(err, ErrTaskNotFound) {
    // Detects even through wrapping
}
if errors.Is(err, ErrTaskAlreadyDone) {
    // Also detects
}
```

**Custom error types (advanced):**

```go
// When you need to attach data to errors
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation error on %s: %s", e.Field, e.Message)
}

// Return custom error
func ValidateTask(task Task) error {
    if task.Description == "" {
        return &ValidationError{
            Field:   "description",
            Message: "description required",
        }
    }
    return nil
}

// Check with errors.As
var validErr *ValidationError
if errors.As(err, &validErr) {
    log.Printf("validation failed on field: %s", validErr.Field)
}
```

**Benefits:**
- Explicit error checking
- Survives error wrapping
- Clear error types for callers
- Better error handling in HTTP/API layers

**When to use:**
- Expected error conditions (not found, invalid input, already exists)
- Errors that callers should handle differently
- Domain-specific errors

**Applies to**: Expected error conditions that need special handling
