---
title: Add Context to Errors
impact: HIGH
impactDescription: Improves debugging, provides actionable error messages, reduces troubleshooting time
tags: error-handling, error-context, go
category: error
---

## Add Context to Errors

Always add context explaining what failed, not just pass through raw errors.

**Incorrect (no context):**

```go
func ProcessTask(id string) error {
    task, err := GetTask(id)
    if err != nil {
        return err  // What operation failed? Which task?
    }

    err = ValidateTask(task)
    if err != nil {
        return err  // Which validation failed?
    }

    err = SaveTask(task)
    if err != nil {
        return err  // Where did save fail?
    }

    return nil
}

// Error: "connection refused"
// No idea which operation or task!
```

**Correct (adds context):**

```go
func ProcessTask(id string) error {
    task, err := GetTask(id)
    if err != nil {
        return fmt.Errorf("failed to get task %s: %w", id, err)
    }

    if err := ValidateTask(task); err != nil {
        return fmt.Errorf("validation failed for task %s: %w", id, err)
    }

    if err := SaveTask(task); err != nil {
        return fmt.Errorf("failed to save task %s: %w", id, err)
    }

    return nil
}

// Error: "failed to save task abc123: database connection refused"
// Clear which operation and task!
```

**Contextual information to include:**

```go
// Include IDs
return fmt.Errorf("failed to delete task %s: %w", taskID, err)

// Include operation
return fmt.Errorf("failed to parse config file: %w", err)

// Include values
return fmt.Errorf("invalid port %d: must be 1-65535: %w", port, err)

// Include user context
return fmt.Errorf("user %s: failed to create task: %w", userID, err)

// Include file paths
return fmt.Errorf("failed to read %s: %w", configPath, err)
```

**Guard clauses with context:**

```go
func CompleteTask(task *Task) error {
    if task == nil {
        return errors.New("task is nil")
    }

    if task.ID == "" {
        return errors.New("task ID is empty")
    }

    if task.Done {
        return fmt.Errorf("task %s already completed", task.ID)
    }

    // Happy path
    task.Done = true
    return nil
}
```

**Layered context:**

```go
// Each layer adds context

// Repository layer
func (r *TaskRepo) Save(ctx context.Context, task Task) error {
    _, err := r.db.ExecContext(ctx, "INSERT INTO tasks ...")
    if err != nil {
        return fmt.Errorf("database insert failed: %w", err)
    }
    return nil
}

// Service layer
func (s *TaskService) CreateTask(ctx context.Context, desc string) (Task, error) {
    task := Task{ID: uuid.New().String(), Description: desc}

    if err := s.repo.Save(ctx, task); err != nil {
        return Task{}, fmt.Errorf("failed to save new task: %w", err)
    }

    return task, nil
}

// Handler layer
func (h *TaskHandler) HandleCreate(w http.ResponseWriter, r *http.Request) {
    task, err := h.service.CreateTask(r.Context(), description)
    if err != nil {
        log.Printf("failed to create task for user %s: %v", userID, err)
        // Logs: "failed to create task for user u123: failed to save new task: database insert failed: connection refused"
        http.Error(w, "failed to create task", 500)
    }
}
```

**Benefits:**
- Faster debugging (know exactly what failed)
- Actionable error messages
- Clear error propagation
- Better logs and monitoring

**Applies to**: All error returns
