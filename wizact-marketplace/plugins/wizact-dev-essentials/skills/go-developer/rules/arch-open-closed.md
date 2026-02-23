---
title: Open/Closed Principle
impact: CRITICAL
impactDescription: Extend functionality without modifying existing code, reduces regression risk
tags: architecture, solid, open-closed, go
category: arch
---

## Open/Closed Principle

Software entities should be open for extension, closed for modification. Extend behavior via interfaces, not by changing existing code.

**Incorrect (must modify to extend):**

```go
// Must modify SaveTask every time we add storage
func SaveTask(task Task, storageType string) error {
    switch storageType {
    case "postgres":
        // Postgres logic
    case "s3":
        // S3 logic
    case "redis":  // Added later - requires modification
        // Redis logic
    }
}
```

**Correct (extend via interfaces):**

```go
// Interface defines contract
type TaskRepository interface {
    Save(ctx context.Context, task Task) error
}

// Extend by adding implementations (no modification)
type PostgresRepo struct {
    db *sql.DB
}

func (r *PostgresRepo) Save(ctx context.Context, task Task) error {
    // Postgres implementation
}

type S3Repo struct {
    client *s3.Client
}

func (r *S3Repo) Save(ctx context.Context, task Task) error {
    // S3 implementation
}

// Later: Add Redis without modifying existing code
type RedisRepo struct {
    client *redis.Client
}

func (r *RedisRepo) Save(ctx context.Context, task Task) error {
    // Redis implementation
}

// Works with ANY implementation
func ProcessTasks(repo TaskRepository) {
    // Unchanged when new implementations added
}
```

**Benefits:**
- Add new storage without changing existing code
- Reduces regression risk
- Follows Liskov Substitution Principle
- Clear extension points

**When to apply:**
- Multiple implementations exist/will exist
- Need to add behavior without modifying core logic
- Creating plugin/extension systems

**Applies to**: All project sizes
