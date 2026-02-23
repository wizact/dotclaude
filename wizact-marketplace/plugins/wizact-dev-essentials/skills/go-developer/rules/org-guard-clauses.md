---
title: Guard Clauses over Nested Ifs
impact: MEDIUM
impactDescription: Improves readability, reduces nesting, clearer happy path
tags: code-organization, guard-clauses, readability, go
category: org
---

## Guard Clauses over Nested Ifs

Use early returns (guard clauses) instead of nested ifs. Keep the happy path unindented.

**Incorrect (nested ifs):**

```go
func Process(task *Task) error {
    if task != nil {
        if task.ID != "" {
            if !task.Done {
                if task.Priority > 0 {
                    // Happy path deeply nested
                    if err := validate(task); err != nil {
                        return err
                    }
                    return save(task)
                } else {
                    return errors.New("invalid priority")
                }
            } else {
                return errors.New("already done")
            }
        } else {
            return errors.New("no ID")
        }
    } else {
        return errors.New("task is nil")
    }
}
```

**Correct (guard clauses):**

```go
func Process(task *Task) error {
    // Guard clauses at the top
    if task == nil {
        return errors.New("task is nil")
    }
    if task.ID == "" {
        return errors.New("no ID")
    }
    if task.Done {
        return errors.New("already done")
    }
    if task.Priority <= 0 {
        return errors.New("invalid priority")
    }

    // Happy path not indented
    if err := validate(task); err != nil {
        return err
    }

    return save(task)
}
```

**More examples:**

```go
// ❌ Nested ifs
func GetUser(id string) (*User, error) {
    if id != "" {
        user, err := repo.FindByID(id)
        if err == nil {
            if user.Active {
                return user, nil
            } else {
                return nil, errors.New("user inactive")
            }
        } else {
            return nil, err
        }
    } else {
        return nil, errors.New("empty ID")
    }
}

// ✅ Guard clauses
func GetUser(id string) (*User, error) {
    if id == "" {
        return nil, errors.New("empty ID")
    }

    user, err := repo.FindByID(id)
    if err != nil {
        return nil, err
    }

    if !user.Active {
        return nil, errors.New("user inactive")
    }

    return user, nil
}
```

**With business logic:**

```go
// ✅ Guard clauses for validation, then business logic
func CompleteTask(task *Task, userID string) error {
    // Validation guards
    if task == nil {
        return errors.New("task is nil")
    }
    if userID == "" {
        return errors.New("user ID required")
    }
    if task.Done {
        return fmt.Errorf("task %s already completed", task.ID)
    }
    if task.AssignedTo != userID {
        return fmt.Errorf("task %s not assigned to user %s", task.ID, userID)
    }

    // Business logic not nested
    task.Done = true
    task.CompletedAt = time.Now()
    task.CompletedBy = userID

    return repo.Save(task)
}
```

**Benefits:**
- Happy path clearly visible
- Reduced nesting
- Easier to read
- Clear error conditions first

**Applies to**: All functions with multiple validations
