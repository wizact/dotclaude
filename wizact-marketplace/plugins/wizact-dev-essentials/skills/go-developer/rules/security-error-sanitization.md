---
title: Sanitize Error Messages for Users
impact: CRITICAL
impactDescription: Prevents information disclosure, protects internal system details
tags: security, error-handling, information-disclosure, go
category: security
---

## Sanitize Error Messages for Users

Never expose internal errors to users. Log detailed errors, return sanitized messages.

**Incorrect (exposes internal details):**

```go
// DANGEROUS: Exposes database structure
func GetTask(w http.ResponseWriter, r *http.Request) {
    task, err := repo.FindByID(r.Context(), taskID)
    if err != nil {
        // Exposes: "pq: relation "tasks_staging" does not exist"
        http.Error(w, err.Error(), 500)
        return
    }
}

// DANGEROUS: Exposes file paths
func LoadConfig(w http.ResponseWriter, r *http.Request) {
    cfg, err := os.ReadFile(configPath)
    if err != nil {
        // Exposes: "open /etc/myapp/secrets.yaml: permission denied"
        http.Error(w, err.Error(), 500)
        return
    }
}

// DANGEROUS: Exposes SQL queries
func DeleteTask(w http.ResponseWriter, r *http.Request) {
    err := repo.Delete(r.Context(), taskID)
    if err != nil {
        // Exposes: "pq: foreign key constraint "fk_user_tasks" violated"
        http.Error(w, err.Error(), 500)
        return
    }
}
```

**Correct (sanitized user messages):**

```go
// Safe: Generic message for user, detailed log for debugging
func GetTask(w http.ResponseWriter, r *http.Request) {
    task, err := repo.FindByID(r.Context(), taskID)
    if err != nil {
        // Log detailed error for debugging
        log.Printf("failed to find task %s: %v", taskID, err)

        // Return sanitized message to user
        if errors.Is(err, sql.ErrNoRows) {
            http.Error(w, "task not found", 404)
        } else {
            http.Error(w, "internal server error", 500)
        }
        return
    }
    json.NewEncoder(w).Encode(task)
}

// Safe: Custom error types for external use
type AppError struct {
    Internal error  // Logged, never exposed
    UserMsg  string // Safe for users
    Code     int    // HTTP status
}

func (e *AppError) Error() string {
    return e.Internal.Error()
}

func GetTaskSafe(w http.ResponseWriter, r *http.Request) {
    task, err := service.GetTask(r.Context(), taskID)
    if err != nil {
        var appErr *AppError
        if errors.As(err, &appErr) {
            log.Printf("error: %v", appErr.Internal)
            http.Error(w, appErr.UserMsg, appErr.Code)
        } else {
            log.Printf("unexpected error: %v", err)
            http.Error(w, "internal server error", 500)
        }
        return
    }
    json.NewEncoder(w).Encode(task)
}

// Service layer wraps errors
func (s *TaskService) GetTask(ctx context.Context, id string) (Task, error) {
    task, err := s.repo.FindByID(ctx, id)
    if err != nil {
        if errors.Is(err, sql.ErrNoRows) {
            return Task{}, &AppError{
                Internal: fmt.Errorf("task not found: %w", err),
                UserMsg:  "task not found",
                Code:     404,
            }
        }
        return Task{}, &AppError{
            Internal: fmt.Errorf("database error: %w", err),
            UserMsg:  "failed to retrieve task",
            Code:     500,
        }
    }
    return task, nil
}
```

**Structured logging for debugging:**

```go
import "log/slog"

func GetTask(w http.ResponseWriter, r *http.Request) {
    task, err := repo.FindByID(r.Context(), taskID)
    if err != nil {
        // Structured logging with context
        slog.Error("failed to find task",
            "task_id", taskID,
            "error", err,
            "user_id", getUserID(r),
        )

        http.Error(w, "internal server error", 500)
        return
    }
}
```

**Benefits:**
- Prevents information disclosure
- Protects database schema, file paths, internal structure
- Maintains detailed logs for debugging
- Professional error responses

**Never expose:**
- ❌ Database table/column names
- ❌ File paths
- ❌ SQL queries
- ❌ Stack traces
- ❌ Internal service names
- ❌ Configuration details

**Safe to expose:**
- ✅ "task not found"
- ✅ "invalid input"
- ✅ "unauthorized"
- ✅ "internal server error"

**Applies to**: All user-facing errors without exception
