---
title: Parameterized Queries
impact: CRITICAL
impactDescription: Prevents SQL injection attacks, protects against data breaches
tags: security, sql-injection, database, go
category: security
---

## Parameterized Queries

Always use parameterized queries ($1, $2) for SQL. Never use string concatenation or formatting.

**Incorrect (SQL injection vulnerability):**

```go
// DANGEROUS: Allows SQL injection
func FindTask(db *sql.DB, taskID string) (Task, error) {
    query := fmt.Sprintf("SELECT * FROM tasks WHERE id = '%s'", taskID)
    // If taskID = "1' OR '1'='1", this exposes all tasks
    row := db.QueryRow(query)
    // ...
}

// DANGEROUS: String concatenation
query := "SELECT * FROM tasks WHERE id = '" + taskID + "'"
```

**Correct (protected from SQL injection):**

```go
// Safe: Parameterized query
func FindTask(db *sql.DB, taskID string) (Task, error) {
    query := "SELECT * FROM tasks WHERE id = $1"
    row := db.QueryRowContext(ctx, query, taskID)
    // Driver safely escapes taskID
    // ...
}

// Safe: Multiple parameters
func FindTasksByUser(db *sql.DB, userID string, status string) ([]Task, error) {
    query := "SELECT * FROM tasks WHERE user_id = $1 AND status = $2"
    rows, err := db.QueryContext(ctx, query, userID, status)
    // ...
}

// Safe: IN clause with parameter
func FindTasksByIDs(db *sql.DB, ids []string) ([]Task, error) {
    // Use ANY for PostgreSQL
    query := "SELECT * FROM tasks WHERE id = ANY($1)"
    rows, err := db.QueryContext(ctx, query, pq.Array(ids))
    // ...
}
```

**Benefits:**
- Prevents SQL injection attacks
- Driver handles escaping automatically
- Protects sensitive data
- Industry standard security practice

**Applies to**: All SQL queries without exception
