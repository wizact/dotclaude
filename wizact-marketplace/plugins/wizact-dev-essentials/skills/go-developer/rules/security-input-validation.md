---
title: Input Validation at Boundaries
impact: CRITICAL
impactDescription: Prevents injection attacks, data corruption, invalid state
tags: security, validation, input-validation, go
category: security
---

## Input Validation at Boundaries

Validate all input at system boundaries (user input, external APIs). Don't trust internal code - trust guarantees.

**Incorrect (missing boundary validation):**

```go
// DANGEROUS: No validation before processing
func CreateTask(w http.ResponseWriter, r *http.Request) {
    var req struct {
        Description string
        Priority    int
    }
    json.NewDecoder(r.Body).Decode(&req)

    // What if Description is empty?
    // What if Priority is negative?
    task := Task{
        ID:          uuid.New().String(),
        Description: req.Description,  // Unchecked!
        Priority:    req.Priority,     // Unchecked!
    }
    repo.Save(task)
}
```

**Correct (validate at boundary):**

```go
// Validate at system boundary (HTTP handler)
func CreateTask(w http.ResponseWriter, r *http.Request) {
    var req struct {
        Description string `json:"description"`
        Priority    int    `json:"priority"`
    }

    if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
        http.Error(w, "invalid request", 400)
        return
    }

    // Validate user input
    if req.Description == "" {
        http.Error(w, "description required", 400)
        return
    }

    if req.Priority < 1 || req.Priority > 5 {
        http.Error(w, "priority must be 1-5", 400)
        return
    }

    // Now safe to process
    task := Task{
        ID:          uuid.New().String(),
        Description: req.Description,
        Priority:    req.Priority,
    }

    if err := service.CreateTask(r.Context(), task); err != nil {
        http.Error(w, "failed to create task", 500)
        return
    }

    json.NewEncoder(w).Encode(task)
}

// Internal code can trust the data
func (s *TaskService) CreateTask(ctx context.Context, task Task) error {
    // No need to re-validate - boundary already validated
    // Trust internal code guarantees
    return s.repo.Save(ctx, task)
}
```

**Validation types:**

```go
// Empty checks
if email == "" {
    return errors.New("email required")
}

// Format validation
emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
if !emailRegex.MatchString(email) {
    return errors.New("invalid email format")
}

// Range validation
if age < 0 || age > 150 {
    return errors.New("age must be 0-150")
}

// Length validation
if len(description) > 1000 {
    return errors.New("description too long (max 1000 chars)")
}

// Whitelist validation
allowedStatuses := map[string]bool{"pending": true, "done": true}
if !allowedStatuses[status] {
    return errors.New("invalid status")
}
```

**Benefits:**
- Prevents injection attacks (SQL, XSS, command)
- Ensures data integrity
- Fails fast with clear errors
- Protects downstream code

**Validate at boundaries:**
- ✅ HTTP request handlers
- ✅ External API calls
- ✅ File uploads
- ✅ CLI arguments

**Don't validate internally:**
- ❌ Service layer (trust boundary validation)
- ❌ Repository layer (trust internal code)
- ❌ Between internal functions (trust guarantees)

**Applies to**: All system boundaries without exception
