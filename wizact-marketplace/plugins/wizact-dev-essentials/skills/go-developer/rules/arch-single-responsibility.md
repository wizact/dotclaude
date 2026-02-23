---
title: Single Responsibility Principle
impact: CRITICAL
impactDescription: Improves maintainability, testability, reduces coupling
tags: architecture, solid, single-responsibility, go
category: arch
---

## Single Responsibility Principle

Each type/function should have one responsibility, one reason to change.

**Incorrect (multiple responsibilities):**

```go
// Too many responsibilities: HTTP, validation, business logic, persistence, response
type TaskHandler struct {
    db *sql.DB
}

func (h *TaskHandler) HandleRequest(w http.ResponseWriter, r *http.Request) {
    // HTTP parsing
    var req struct {
        Description string
    }
    json.NewDecoder(r.Body).Decode(&req)

    // Validation
    if req.Description == "" {
        http.Error(w, "description required", 400)
        return
    }

    // Business logic
    task := Task{
        ID:   uuid.New().String(),
        Done: false,
    }

    // Persistence
    _, err := h.db.Exec("INSERT INTO tasks ...")

    // HTTP response
    json.NewEncoder(w).Encode(task)
}
```

**Correct (one responsibility per type):**

```go
// Validation - one responsibility
type TaskValidator struct{}

func (v *TaskValidator) Validate(task Task) error {
    if task.Description == "" {
        return errors.New("description required")
    }
    return nil
}

// Persistence - one responsibility
type TaskRepository struct {
    db *sql.DB
}

func (r *TaskRepository) Save(ctx context.Context, task Task) error {
    _, err := r.db.ExecContext(ctx, "INSERT INTO tasks ...")
    return err
}

// Business logic - one responsibility
type TaskService struct {
    repo      TaskRepository
    validator TaskValidator
}

func (s *TaskService) CreateTask(ctx context.Context, desc string) (Task, error) {
    task := Task{
        ID:          uuid.New().String(),
        Description: desc,
        Done:        false,
    }

    if err := s.validator.Validate(task); err != nil {
        return Task{}, err
    }

    if err := s.repo.Save(ctx, task); err != nil {
        return Task{}, err
    }

    return task, nil
}

// HTTP handling - one responsibility
type TaskHandler struct {
    service TaskService
}

func (h *TaskHandler) HandleRequest(w http.ResponseWriter, r *http.Request) {
    var req struct {
        Description string
    }
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        http.Error(w, "invalid request", 400)
        return
    }

    task, err := h.service.CreateTask(r.Context(), req.Description)
    if err != nil {
        http.Error(w, err.Error(), 400)
        return
    }

    json.NewEncoder(w).Encode(task)
}
```

**Benefits:**
- Easy to test (validate, persist, handle independently)
- Easy to change (modify validation without touching HTTP)
- Clear responsibilities
- Reusable components

**Applies to**: All project sizes
