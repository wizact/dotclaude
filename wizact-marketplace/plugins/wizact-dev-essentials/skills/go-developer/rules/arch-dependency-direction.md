---
title: Dependencies Flow Inward
impact: CRITICAL
impactDescription: Enables testing, prevents circular dependencies, maintains clear architecture
tags: architecture, dependency-direction, clean-architecture, go
category: arch
---

## Dependencies Flow Inward

Outer layers depend on inner layers. Inner layers NEVER depend on outer layers. This is the foundation of clean architecture.

**Incorrect (domain depends on HTTP):**

```go
package todo

import "net/http"

type Task struct {
    ID   string
    Done bool
}

// WRONG: Business logic depends on HTTP layer
func (t *Task) CompleteFromRequest(r *http.Request) error {
    // Domain shouldn't know about HTTP
    userID := r.Header.Get("User-ID")
    t.Done = true
    return nil
}
```

**Correct (HTTP depends on domain):**

```go
package todo

// Domain has NO external dependencies
type Task struct {
    ID   string
    Done bool
}

func (t *Task) Complete() error {
    if t.Done {
        return errors.New("already completed")
    }
    t.Done = true
    return nil
}

// HTTP handler depends on domain (outer → inner)
package handler

import (
    "net/http"
    "myapp/todo"
)

func completeTaskHandler(w http.ResponseWriter, r *http.Request) {
    task := getTask(r)
    if err := task.Complete(); err != nil {
        http.Error(w, err.Error(), 400)
        return
    }
    saveTask(task)
}
```

**Benefits:**
- Business logic testable without HTTP server
- Can change HTTP framework without touching domain
- Clear separation of concerns
- Prevents import cycles

**Architecture Layers:**
```
┌─────────────────────────────────────┐
│  Frameworks & Drivers               │
│  (HTTP handlers, DB, external APIs) │
└──────────────────┬──────────────────┘
                   │ depends on
                   ▼
┌──────────────────────────────────────┐
│  Business Logic                      │
│  (domain rules, use cases)           │
│  - NO imports of HTTP, DB, etc.      │
└──────────────────────────────────────┘
```

**Applies to**: All project sizes (small tools to large systems)
