---
title: Break Down Functions Judiciously
impact: MEDIUM
impactDescription: Improves readability without over-abstraction
tags: code-organization, functions, readability, go
category: org
---

## Break Down Functions Judiciously

Break functions down where it improves clarity, but avoid over-abstraction into too many tiny pieces.

**Incorrect (one giant function):**

```go
// 200+ lines in one function
func (s *UserService) RegisterUser(ctx context.Context, req RegisterRequest) (*User, error) {
    // 50 lines of validation
    if req.Email == "" {
        return nil, errors.New("email required")
    }
    emailRegex := regexp.MustCompile(...)
    if !emailRegex.MatchString(req.Email) {
        return nil, errors.New("invalid email")
    }
    if len(req.Password) < 8 {
        return nil, errors.New("password too short")
    }
    // ... 40 more lines of validation

    // 50 lines of business logic
    hash, _ := bcrypt.GenerateFromPassword(...)
    user := &User{
        ID:        uuid.New().String(),
        Email:     req.Email,
        Password:  string(hash),
        CreatedAt: time.Now(),
    }
    // ... more logic

    // 50 lines of persistence
    tx, _ := s.db.Begin()
    _, err := tx.ExecContext(...)
    // ... more persistence

    // 50 lines of email sending
    // ... email logic

    // Too complex to follow!
}
```

**Incorrect (over-abstracted):**

```go
// Too granular - harder to follow
func (s *UserService) RegisterUser(ctx context.Context, req RegisterRequest) (*User, error) {
    if err := s.checkEmailNotEmpty(req.Email); err != nil {
        return nil, err
    }
    if err := s.checkPasswordLength(req.Password); err != nil {
        return nil, err
    }
    if err := s.checkEmailFormat(req.Email); err != nil {
        return nil, err
    }
    if err := s.checkPasswordComplexity(req.Password); err != nil {
        return nil, err
    }
    if err := s.checkEmailNotTaken(ctx, req.Email); err != nil {
        return nil, err
    }
    // Jumping through too many tiny functions
}
```

**Correct (balanced breakdown):**

```go
// Main function - clear flow
func (s *UserService) RegisterUser(ctx context.Context, req RegisterRequest) (*User, error) {
    if err := s.validateRegistration(req); err != nil {
        return nil, err
    }

    user := s.buildUser(req)

    if err := s.repo.Save(ctx, user); err != nil {
        return nil, fmt.Errorf("failed to save user: %w", err)
    }

    s.sendWelcomeEmail(user)

    return user, nil
}

// Grouped validation - logical chunk
func (s *UserService) validateRegistration(req RegisterRequest) error {
    if req.Email == "" {
        return errors.New("email required")
    }

    emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
    if !emailRegex.MatchString(req.Email) {
        return errors.New("invalid email format")
    }

    if len(req.Password) < 8 {
        return errors.New("password too short (min 8 chars)")
    }

    return nil
}

// User construction - logical chunk
func (s *UserService) buildUser(req RegisterRequest) *User {
    hash, _ := bcrypt.GenerateFromPassword([]byte(req.Password), 14)
    return &User{
        ID:           uuid.New().String(),
        Email:        req.Email,
        PasswordHash: string(hash),
        CreatedAt:    time.Now(),
    }
}

// Email sending - can be async, separate concern
func (s *UserService) sendWelcomeEmail(user *User) {
    go func() {
        // Send in background
    }()
}
```

**When to create a separate function:**

```go
// ✅ Repeated logic (DRY)
func hashPassword(password string) (string, error) {
    hash, err := bcrypt.GenerateFromPassword([]byte(password), 14)
    if err != nil {
        return "", err
    }
    return string(hash), nil
}

// ✅ Complex logic that benefits from naming
func (s *UserService) isValidEmail(email string) bool {
    emailRegex := regexp.MustCompile(`^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$`)
    return emailRegex.MatchString(email)
}

// ✅ Improves testability
func buildQuery(filters map[string]string) string {
    // Complex query building
}

// ✅ Chunks complexity for readability
func (s *TaskService) processTaskBatch(tasks []Task) error {
    validated := s.filterValidTasks(tasks)
    sorted := s.sortByPriority(validated)
    return s.saveAll(sorted)
}
```

**When NOT to create a separate function:**

```go
// ❌ One-liner that's already clear
func getTaskID(task Task) string {
    return task.ID  // Just use task.ID directly!
}

// ❌ Used only once and simple
func incrementCounter() {
    counter++  // Just increment directly
}

// ❌ Over-abstraction
func add(a, b int) int {
    return a + b  // Use + operator!
}
```

**Benefits:**
- Clear flow in main function
- Logical grouping of related code
- Testable chunks
- Not over-abstracted

**Applies to**: All function organization
