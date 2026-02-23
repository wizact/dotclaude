---
title: Keep It Simple
impact: MEDIUM
impactDescription: Improves readability, reduces bugs, easier to maintain
tags: code-organization, simplicity, readability, go
category: org
---

## Keep It Simple

Three similar lines are better than a premature abstraction. Prefer guard clauses over nested ifs.

**Prefer directness over abstraction:**

**Incorrect (premature abstraction):**

```go
// Unnecessary abstraction for simple logic
type TaskMutator func(*Task)

func (s *TaskService) mutateTask(id string, m TaskMutator) error {
    task, err := s.repo.FindByID(id)
    if err != nil {
        return err
    }
    m(&task)
    return s.repo.Save(task)
}

func (s *TaskService) CompleteTask(id string) error {
    return s.mutateTask(id, func(t *Task) {
        t.Done = true
    })
}

// More complex, no real benefit
```

**Correct (direct and clear):**

```go
func (s *TaskService) CompleteTask(id string) error {
    task, err := s.repo.FindByID(id)
    if err != nil {
        return err
    }
    task.Done = true
    return s.repo.Save(task)
}

// Repeated structure is fine for clarity
func (s *TaskService) UpdateDescription(id, desc string) error {
    task, err := s.repo.FindByID(id)
    if err != nil {
        return err
    }
    task.Description = desc
    return s.repo.Save(task)
}
```

**Guard clauses over nested ifs:**

**Incorrect (nested ifs):**

```go
func Process(task *Task) error {
    if task != nil {
        if task.ID != "" {
            if !task.Done {
                if task.Priority > 0 {
                    // Happy path deeply nested
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

    // Happy path without nesting
    return save(task)
}
```

**Simple is better than clever:**

```go
// ❌ Clever but hard to understand
func (s *TaskService) bulkUpdate(ids []string, updates map[string]interface{}) error {
    return s.withTx(func(tx *Tx) error {
        for _, id := range ids {
            if err := s.applyUpdates(tx, id, updates); err != nil {
                return err
            }
        }
        return nil
    })
}

// ✅ Simple and clear
func (s *TaskService) CompleteMultiple(ids []string) error {
    for _, id := range ids {
        task, err := s.repo.FindByID(id)
        if err != nil {
            return fmt.Errorf("failed to find task %s: %w", id, err)
        }
        task.Done = true
        if err := s.repo.Save(task); err != nil {
            return fmt.Errorf("failed to save task %s: %w", id, err)
        }
    }
    return nil
}
```

**When repetition is OK:**

```go
// This is fine - clear and direct
func (h *TaskHandler) HandleCreate(w http.ResponseWriter, r *http.Request) {
    var req CreateTaskRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        http.Error(w, "invalid request", 400)
        return
    }

    task, err := h.service.CreateTask(r.Context(), req)
    if err != nil {
        http.Error(w, "failed to create task", 500)
        return
    }

    json.NewEncoder(w).Encode(task)
}

func (h *TaskHandler) HandleUpdate(w http.ResponseWriter, r *http.Request) {
    var req UpdateTaskRequest
    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        http.Error(w, "invalid request", 400)
        return
    }

    task, err := h.service.UpdateTask(r.Context(), req)
    if err != nil {
        http.Error(w, "failed to update task", 500)
        return
    }

    json.NewEncoder(w).Encode(task)
}

// Repeated structure, but each handler is clear
```

**Benefits:**
- Code is easier to read
- Fewer bugs from complex abstractions
- Easier to modify
- Clear intent
- Happy path not buried in nesting

**Applies to**: All code organization decisions
