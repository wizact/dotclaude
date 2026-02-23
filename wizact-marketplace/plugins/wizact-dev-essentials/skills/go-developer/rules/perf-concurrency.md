---
title: Handle Concurrent Access
impact: MEDIUM
impactDescription: Prevents race conditions, ensures data safety in concurrent code
tags: performance, concurrency, mutex, go
category: perf
---

## Handle Concurrent Access

Use sync.Mutex or sync.RWMutex when data is accessed concurrently. Protect shared state.

**Incorrect (race condition):**

```go
// DANGEROUS: Concurrent map access
type Cache struct {
    items map[string]Task  // Unprotected!
}

func (c *Cache) Set(key string, task Task) {
    c.items[key] = task  // Race condition!
}

func (c *Cache) Get(key string) (Task, bool) {
    task, ok := c.items[key]  // Race condition!
    return task, ok
}
```

**Correct (protected with mutex):**

```go
type Cache struct {
    mu    sync.RWMutex
    items map[string]Task
}

// Write lock for modifications
func (c *Cache) Set(key string, task Task) {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.items[key] = task
}

// Read lock for reads (multiple readers OK)
func (c *Cache) Get(key string) (Task, bool) {
    c.mu.RLock()
    defer c.mu.RUnlock()
    task, ok := c.items[key]
    return task, ok
}
```

**Use RWMutex for read-heavy workloads:**

```go
type TaskCache struct {
    mu    sync.RWMutex  // Allows multiple readers
    tasks map[string]Task
}

// Many goroutines can read simultaneously
func (c *TaskCache) Get(id string) (Task, bool) {
    c.mu.RLock()
    defer c.mu.RUnlock()
    task, ok := c.tasks[id]
    return task, ok
}

// Only one writer at a time
func (c *TaskCache) Set(id string, task Task) {
    c.mu.Lock()
    defer c.mu.Unlock()
    c.tasks[id] = task
}
```

**Benefits:**
- Prevents race conditions
- Safe concurrent access
- Data integrity

**Applies to**: All shared mutable state accessed by multiple goroutines
