---
title: YAGNI - You Aren't Gonna Need It
impact: MEDIUM
impactDescription: Reduces complexity, faster development, easier maintenance
tags: code-organization, yagni, simplicity, go
category: org
---

## YAGNI - You Aren't Gonna Need It

Implement only what's needed now. Don't add features for hypothetical future requirements.

**Incorrect (over-engineering):**

```go
// OVER-ENGINEERED: Adding features "just in case"
func CompleteTask(taskID string, opts ...Option) error {
    cfg := applyOptions(opts)      // "for flexibility"

    if cached := cache.Get(...) {} // "for performance" (not measured)

    eventBus.Publish(TaskCompletedEvent{ID: taskID})  // "for future integrations"

    auditLog.Record(AuditEntry{...})  // "just in case we need audit"

    metrics.Increment("task.completed")  // "for monitoring" (not set up)

    // NONE OF THIS WAS REQUESTED!
    task, err := repo.FindByID(taskID)
    if err != nil {
        return err
    }
    task.Done = true
    return repo.Save(task)
}
```

**Correct (implements requirements):**

```go
// Implements exactly what's needed
func CompleteTask(taskID string) error {
    task, err := repo.FindByID(taskID)
    if err != nil {
        return fmt.Errorf("failed to find task: %w", err)
    }

    task.Done = true

    if err := repo.Save(task); err != nil {
        return fmt.Errorf("failed to save task: %w", err)
    }

    return nil
}

// Add features when actually needed:
// - Caching → when performance is measured as a problem
// - Events → when integrations are actually built
// - Audit log → when compliance requires it
// - Metrics → when monitoring is set up
```

**When to add complexity:**

```go
// ✅ GOOD: Add what's actually needed

// Security is NEVER over-engineering
func CreateUser(email, password string) error {
    if email == "" {
        return errors.New("email required")
    }
    hashedPassword, _ := bcrypt.GenerateFromPassword([]byte(password), 14)
    // ...
}

// Error handling is NEVER over-engineering
func SaveTask(task Task) error {
    if err := validate(task); err != nil {
        return fmt.Errorf("validation failed: %w", err)
    }
    // ...
}

// Input validation is NEVER over-engineering
func SetPriority(priority int) error {
    if priority < 1 || priority > 5 {
        return errors.New("priority must be 1-5")
    }
    // ...
}
```

**Examples of YAGNI violations:**

```go
// ❌ Generic abstraction for one use case
type TaskMutator func(*Task)

func (s *TaskService) mutateTask(id string, m TaskMutator) error {
    // Premature abstraction
}

// ✅ Direct implementation
func (s *TaskService) CompleteTask(id string) error {
    task, err := s.repo.FindByID(id)
    if err != nil {
        return err
    }
    task.Done = true
    return s.repo.Save(task)
}

// ❌ Configuration for one value
type TaskOptions struct {
    EnableCaching    bool
    CacheTTL         time.Duration
    EnableMetrics    bool
    EnableAudit      bool
    EnableValidation bool  // Validation should always be on!
}

// ✅ Simple, required functionality
func CompleteTask(taskID string) error {
    // Just do it
}

// ❌ Plugin system with no plugins
type TaskPlugin interface {
    OnComplete(task Task) error
}

func (s *TaskService) RegisterPlugin(p TaskPlugin) {
    // No plugins exist!
}

// ✅ Direct implementation
func (s *TaskService) CompleteTask(id string) error {
    // Actual logic
}
```

**Add features when:**
- ✅ Actually requested
- ✅ Measured need (performance issue)
- ✅ Compliance requirement (audit, security)
- ✅ Integration exists (events, webhooks)

**Don't add "just in case":**
- ❌ Caching without measured performance issue
- ❌ Plugin system with no plugins
- ❌ Configuration options not used
- ❌ Abstractions for one implementation
- ❌ "Future-proof" interfaces

**Exception: Always add:**
- Security (password hashing, input validation, SQL params)
- Error handling (wrap errors, add context)
- Critical edge cases (nil checks, boundary validation)

**Benefits:**
- Faster development
- Simpler code
- Easier maintenance
- Fewer bugs
- Clearer intent

**Applies to**: All features and abstractions
