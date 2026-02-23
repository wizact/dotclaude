# Go Developer - Complete Reference

Complete guide to production-ready Go development. All rules expanded with full context.

**Generated from individual rule files** - Edit rules/*.md, then run compile-reference.sh

## Table of Contents
1. [Architecture (CRITICAL)](#architecture-critical)
2. [Security (CRITICAL)](#security-critical)
3. [Testing (HIGH)](#testing-high)
4. [Error Handling (HIGH)](#error-handling-high)
5. [Code Organization (MEDIUM)](#code-organization-medium)
6. [Performance (MEDIUM)](#performance-medium)
7. [Patterns (LOW)](#patterns-low)

---


## Architecture (CRITICAL)

### arch-dependency-direction: Dependencies Flow Inward


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

---

### arch-dependency-inversion: Dependency Inversion


## Dependency Inversion

Depend on abstractions (interfaces), not concretions (structs). High-level modules should not depend on low-level modules.

**Incorrect (depends on concretion):**

```go
// Tightly coupled to PostgreSQL
type TaskService struct {
    repo *PostgresTaskRepository
}

// Can't test without database
// Can't swap to different storage
func NewTaskService(db *sql.DB) *TaskService {
    return &TaskService{
        repo: &PostgresTaskRepository{db: db},
    }
}
```

**Correct (depends on abstraction):**

```go
// Depends on interface (abstraction)
type TaskService struct {
    repo TaskRepository  // Interface
}

// Accepts any implementation of TaskRepository
func NewTaskService(repo TaskRepository) *TaskService {
    return &TaskService{repo: repo}
}

// Production code
func main() {
    db := openDB()
    repo := &PostgresTaskRepository{db: db}
    service := NewTaskService(repo)  // Inject concrete adapter
}

// Test code
func TestTaskService(t *testing.T) {
    repo := &MemoryTaskRepository{tasks: make(map[string]Task)}
    service := NewTaskService(repo)  // Inject test adapter
    // Test without database
}
```

**Benefits:**
- Swap implementations at runtime
- Test without external dependencies
- Clear separation of concerns
- Follows Open/Closed principle

**When to use:**
- External dependencies (databases, APIs, file systems)
- Multiple implementations exist/will exist
- Need testability without real dependency

**Don't create interfaces for:**
- One implementation, unlikely to change
- Internal helpers
- Simple utilities

**Applies to**: All project sizes

---

### arch-open-closed: Open/Closed Principle


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

---

### arch-ports-adapters: Ports and Adapters Pattern


## Ports and Adapters Pattern

Define interfaces (ports) for external dependencies. Implement concrete adapters that satisfy those interfaces.

**Incorrect (depends on concrete type):**

```go
// Locked to Postgres, can't swap or test easily
type TaskService struct {
    repo *PostgresTaskRepository
}
```

**Correct (depends on interface):**

```go
// ✅ Port (interface) - defines the contract
type TaskRepository interface {
    Save(ctx context.Context, task Task) error
    FindByID(ctx context.Context, id string) (Task, error)
}

// ✅ Adapter 1 - in-memory (implements TaskRepository)
type MemoryTaskRepository struct {
    tasks map[string]Task
    mu    sync.RWMutex
}

func (r *MemoryTaskRepository) Save(ctx context.Context, task Task) error {
    r.mu.Lock()
    defer r.mu.Unlock()
    r.tasks[task.ID] = task
    return nil
}

func (r *MemoryTaskRepository) FindByID(ctx context.Context, id string) (Task, error) {
    r.mu.RLock()
    defer r.mu.RUnlock()
    task, ok := r.tasks[id]
    if !ok {
        return Task{}, errors.New("task not found")
    }
    return task, nil
}

// ✅ Adapter 2 - PostgreSQL (implements TaskRepository)
type PostgresTaskRepository struct {
    db *sql.DB
}

func (r *PostgresTaskRepository) Save(ctx context.Context, task Task) error {
    _, err := r.db.ExecContext(ctx,
        "INSERT INTO tasks (id, description, done) VALUES ($1, $2, $3)",
        task.ID, task.Description, task.Done)
    return err
}

func (r *PostgresTaskRepository) FindByID(ctx context.Context, id string) (Task, error) {
    var task Task
    err := r.db.QueryRowContext(ctx,
        "SELECT id, description, done FROM tasks WHERE id = $1", id).
        Scan(&task.ID, &task.Description, &task.Done)
    if err == sql.ErrNoRows {
        return Task{}, errors.New("task not found")
    }
    return task, err
}

// ✅ Business logic depends on PORT (interface), not concrete adapter
type TaskService struct {
    repo TaskRepository  // Can use MemoryTaskRepository OR PostgresTaskRepository
}
```

**Benefits:**
- Swap implementations without changing business logic
- Test with in-memory adapter, run with PostgreSQL
- Clear contracts between layers
- Duck typing - both adapters satisfy interface automatically

**When to create ports:**
- External dependencies (databases, APIs, file systems)
- Multiple implementations exist/will exist
- Need to test without real dependency

**Applies to**: All project sizes

---

### arch-single-responsibility: Single Responsibility Principle


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

---


## Security (CRITICAL)

### security-error-sanitization: Sanitize Error Messages for Users


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

---

### security-input-validation: Input Validation at Boundaries


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

---

### security-password-hashing: Password Hashing with bcrypt


## Password Hashing with bcrypt

Use bcrypt with cost factor ≥12 for password hashing. Never store plaintext passwords.

**Incorrect (insecure password storage):**

```go
// DANGEROUS: Plaintext passwords
func CreateUser(email, password string) error {
    _, err := db.Exec("INSERT INTO users (email, password) VALUES ($1, $2)",
        email, password)  // Storing plaintext!
    return err
}

// DANGEROUS: MD5/SHA256 without salt
import "crypto/md5"

func HashPassword(password string) string {
    hash := md5.Sum([]byte(password))  // Fast, easily cracked
    return hex.EncodeToString(hash[:])
}

// DANGEROUS: Custom hashing
func CustomHash(password string) string {
    // Don't roll your own crypto!
}
```

**Correct (bcrypt with proper cost):**

```go
import "golang.org/x/crypto/bcrypt"

// Hash password with cost factor 14 (recommended: 12-14)
func HashPassword(password string) (string, error) {
    hash, err := bcrypt.GenerateFromPassword([]byte(password), 14)
    if err != nil {
        return "", err
    }
    return string(hash), nil
}

// Verify password
func VerifyPassword(hashedPassword, password string) error {
    return bcrypt.CompareHashAndPassword(
        []byte(hashedPassword),
        []byte(password),
    )
}

// Usage in user registration
func CreateUser(email, password string) error {
    hashedPassword, err := HashPassword(password)
    if err != nil {
        return fmt.Errorf("failed to hash password: %w", err)
    }

    _, err = db.ExecContext(ctx,
        "INSERT INTO users (email, password_hash) VALUES ($1, $2)",
        email, hashedPassword)
    return err
}

// Usage in authentication
func AuthenticateUser(email, password string) (User, error) {
    var user User
    err := db.QueryRowContext(ctx,
        "SELECT id, email, password_hash FROM users WHERE email = $1",
        email).Scan(&user.ID, &user.Email, &user.PasswordHash)

    if err != nil {
        return User{}, err
    }

    if err := VerifyPassword(user.PasswordHash, password); err != nil {
        return User{}, errors.New("invalid credentials")
    }

    return user, nil
}
```

**Benefits:**
- Protects passwords even if database is compromised
- Adaptive cost factor (increases with computing power)
- Salted automatically (unique hash per password)
- Industry standard (OWASP recommended)

**Cost Factor Guidelines:**
- **12**: Minimum acceptable
- **14**: Recommended for most applications
- **16+**: High-security applications (slower login)

**Never:**
- Store plaintext passwords
- Use fast hashes (MD5, SHA256) for passwords
- Roll your own password hashing

**Applies to**: All password storage without exception

---

### security-sql-injection: Parameterized Queries


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

---


## Testing (HIGH)

### test-config-defaults: Configuration with Defaults (No Global State)


## Configuration with Defaults (No Global State)

Use configuration structs with sensible defaults. Avoid global variables that make tests unpredictable.

**Incorrect (global state):**

```go
// ANTI-PATTERN: Global configuration
var (
    GlobalPort     = 8080
    GlobalHost     = "localhost"
    GlobalMaxRetry = 3
    GlobalTimeout  = time.Second * 30
)

func StartServer() {
    // Uses globals - can't run tests in parallel
    http.ListenAndServe(fmt.Sprintf("%s:%d", GlobalHost, GlobalPort), nil)
}

// Tests interfere with each other
func TestServerPort9000(t *testing.T) {
    GlobalPort = 9000  // Modifies global state!
    // ...
}

func TestServerPort9001(t *testing.T) {
    GlobalPort = 9001  // Race condition if parallel!
    // ...
}
```

**Correct (configuration struct with defaults):**

```go
// Configuration struct
type Config struct {
    Port     int
    Host     string
    MaxRetry int
    Timeout  time.Duration
}

// Function to create default config
func DefaultConfig() Config {
    return Config{
        Port:     8080,
        Host:     "localhost",
        MaxRetry: 3,
        Timeout:  time.Second * 30,
    }
}

// Optional: Functional options pattern
type Option func(*Config)

func WithPort(port int) Option {
    return func(c *Config) {
        c.Port = port
    }
}

func WithHost(host string) Option {
    return func(c *Config) {
        c.Host = host
    }
}

// Server accepts config
type Server struct {
    config Config
}

func NewServer(config Config) *Server {
    return &Server{config: config}
}

// Or with options
func NewServerWithOptions(opts ...Option) *Server {
    cfg := DefaultConfig()
    for _, opt := range opts {
        opt(&cfg)
    }
    return &Server{config: cfg}
}
```

**Tests with isolated configuration:**

```go
func TestServer_DefaultConfig(t *testing.T) {
    cfg := DefaultConfig()
    server := NewServer(cfg)

    assert.Equal(t, 8080, server.config.Port)
}

func TestServer_CustomPort(t *testing.T) {
    cfg := DefaultConfig()
    cfg.Port = 9999  // Isolated change

    server := NewServer(cfg)
    assert.Equal(t, 9999, server.config.Port)
}

// Can run in parallel - no shared state
func TestServer_Parallel(t *testing.T) {
    t.Run("port 9000", func(t *testing.T) {
        t.Parallel()
        cfg := DefaultConfig()
        cfg.Port = 9000
        server := NewServer(cfg)
        // Test isolated
    })

    t.Run("port 9001", func(t *testing.T) {
        t.Parallel()
        cfg := DefaultConfig()
        cfg.Port = 9001
        server := NewServer(cfg)
        // Test isolated
    })
}
```

**With functional options:**

```go
func TestServer_FunctionalOptions(t *testing.T) {
    server := NewServerWithOptions(
        WithPort(9999),
        WithHost("0.0.0.0"),
    )

    assert.Equal(t, 9999, server.config.Port)
    assert.Equal(t, "0.0.0.0", server.config.Host)
    assert.Equal(t, 3, server.config.MaxRetry) // Default value
}
```

**Environment-based configuration (still no globals):**

```go
// Load from environment but return struct
func LoadConfig() Config {
    cfg := DefaultConfig()

    if port := os.Getenv("PORT"); port != "" {
        if p, err := strconv.Atoi(port); err == nil {
            cfg.Port = p
        }
    }

    if host := os.Getenv("HOST"); host != "" {
        cfg.Host = host
    }

    return cfg
}

// Production
func main() {
    cfg := LoadConfig()  // Loads from environment
    server := NewServer(cfg)
    server.Start()
}

// Test
func TestServerWithEnv(t *testing.T) {
    t.Setenv("PORT", "9999")  // Test-scoped env var

    cfg := LoadConfig()
    assert.Equal(t, 9999, cfg.Port)
}
```

**Benefits:**
- Tests can run in parallel
- No race conditions
- Easy to override config per test
- Clear configuration dependencies
- Predictable test behavior

**Avoid:**
- ❌ Global variables
- ❌ `init()` functions that set state
- ❌ Package-level mutable state
- ❌ Singleton patterns with global instance

**Prefer:**
- ✅ Configuration structs
- ✅ Constructor injection
- ✅ Functional options pattern
- ✅ Explicit dependencies

**Applies to**: All configurable code, especially in tests

---

### test-fixtures: Test Fixtures in testdata/


## Test Fixtures in testdata/

Store test data files in `testdata/` directory. Go build tools ignore this directory.

**Incorrect (inline test data):**

```go
func TestParseConfig(t *testing.T) {
    // Hard-coded JSON in test
    configJSON := `{
        "port": 8080,
        "host": "localhost",
        "database": {
            "host": "db.example.com",
            "port": 5432,
            "name": "testdb"
        }
    }`

    config, err := ParseConfig([]byte(configJSON))
    // ... test logic
}

// Difficult to maintain, hard to read
```

**Correct (testdata/ directory):**

```
mypackage/
├── config.go
├── config_test.go
└── testdata/
    ├── valid_config.json
    ├── invalid_config.json
    ├── minimal_config.yaml
    └── sample_data.csv
```

```go
func TestParseConfig(t *testing.T) {
    // Load from testdata
    data, err := os.ReadFile("testdata/valid_config.json")
    if err != nil {
        t.Fatalf("failed to read fixture: %v", err)
    }

    config, err := ParseConfig(data)
    require.NoError(t, err)
    assert.Equal(t, 8080, config.Port)
}

// Table-driven with multiple fixtures
func TestParseConfig_MultipleFixtures(t *testing.T) {
    tests := []struct {
        name     string
        fixture  string
        wantErr  bool
        validate func(*testing.T, Config)
    }{
        {
            name:    "valid config",
            fixture: "testdata/valid_config.json",
            wantErr: false,
            validate: func(t *testing.T, cfg Config) {
                assert.Equal(t, 8080, cfg.Port)
                assert.Equal(t, "localhost", cfg.Host)
            },
        },
        {
            name:    "invalid JSON",
            fixture: "testdata/invalid_config.json",
            wantErr: true,
        },
        {
            name:    "minimal config with defaults",
            fixture: "testdata/minimal_config.yaml",
            wantErr: false,
            validate: func(t *testing.T, cfg Config) {
                assert.Equal(t, 8080, cfg.Port) // default
            },
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            data, err := os.ReadFile(tt.fixture)
            require.NoError(t, err, "failed to read fixture")

            config, err := ParseConfig(data)

            if tt.wantErr {
                assert.Error(t, err)
                return
            }

            require.NoError(t, err)
            if tt.validate != nil {
                tt.validate(t, config)
            }
        })
    }
}
```

**Helper for loading fixtures:**

```go
func loadFixture(t *testing.T, filename string) []byte {
    t.Helper()
    data, err := os.ReadFile(filename)
    if err != nil {
        t.Fatalf("failed to load fixture %s: %v", filename, err)
    }
    return data
}

// Usage
func TestParseJSON(t *testing.T) {
    data := loadFixture(t, "testdata/sample.json")
    result, err := ParseJSON(data)
    require.NoError(t, err)
}
```

**testdata/ examples:**

```
testdata/
├── valid_user.json          # Valid input
├── invalid_email.json       # Invalid input test
├── empty_fields.json        # Edge case
├── large_dataset.csv        # Performance test
├── unicode_names.txt        # Unicode handling
└── api_responses/
    ├── success.json
    ├── error_404.json
    └── error_500.json
```

**Benefits:**
- Separates test data from code
- Easy to update test data
- Version control for test files
- Reusable across tests
- Supports multiple formats (JSON, YAML, CSV, etc.)

**Note**: `testdata/` is special in Go - build tools ignore it automatically

**Applies to**: Tests with file-based data, configuration files, API responses

---

### test-gomock: Use gomock for Mocking


## Use gomock for Mocking

Use gomock for generating type-safe mocks of interfaces. Provides compile-time safety and clear test expectations.

**Setup:**

```bash
go install github.com/golang/mock/mockgen@latest

# Generate mocks
mockgen -source=repository.go -destination=mocks/mock_repository.go -package=mocks
```

**Interface to mock:**

```go
package task

type TaskRepository interface {
    Save(ctx context.Context, task Task) error
    FindByID(ctx context.Context, id string) (Task, error)
    Delete(ctx context.Context, id string) error
}
```

**Incorrect (manual mock implementation):**

```go
// Manual mock - must maintain as interface changes
type MockTaskRepository struct {
    SaveFunc     func(ctx context.Context, task Task) error
    FindByIDFunc func(ctx context.Context, id string) (Task, error)
    DeleteFunc   func(ctx context.Context, id string) error
}

func (m *MockTaskRepository) Save(ctx context.Context, task Task) error {
    if m.SaveFunc != nil {
        return m.SaveFunc(ctx, task)
    }
    return nil
}

// ... repeat for each method
// Error-prone, no compile-time safety
```

**Correct (gomock-generated mock):**

```go
import (
    "testing"
    "github.com/golang/mock/gomock"
    "myapp/mocks"
)

func TestTaskService_Complete(t *testing.T) {
    // Setup
    ctrl := gomock.NewController(t)
    defer ctrl.Finish()

    mockRepo := mocks.NewMockTaskRepository(ctrl)

    // Set expectations
    mockRepo.EXPECT().
        FindByID(gomock.Any(), "task-1").
        Return(Task{ID: "task-1", Done: false}, nil).
        Times(1)

    mockRepo.EXPECT().
        Save(gomock.Any(), gomock.Eq(Task{ID: "task-1", Done: true})).
        Return(nil).
        Times(1)

    // Test
    service := NewTaskService(mockRepo)
    err := service.Complete(context.Background(), "task-1")

    // Verify
    require.NoError(t, err)
    // gomock automatically verifies expectations via ctrl.Finish()
}
```

**Common gomock patterns:**

```go
// Any argument matcher
mockRepo.EXPECT().
    Save(gomock.Any(), gomock.Any()).
    Return(nil)

// Specific value matcher
mockRepo.EXPECT().
    FindByID(gomock.Any(), gomock.Eq("task-1")).
    Return(Task{ID: "task-1"}, nil)

// Custom matcher
mockRepo.EXPECT().
    Save(gomock.Any(), gomock.AssignableToTypeOf(Task{})).
    Return(nil)

// Call count
mockRepo.EXPECT().
    Save(gomock.Any(), gomock.Any()).
    Return(nil).
    Times(3)  // Must be called exactly 3 times

// At least/most
mockRepo.EXPECT().
    FindByID(gomock.Any(), gomock.Any()).
    Return(Task{}, nil).
    MinTimes(1).
    MaxTimes(5)

// Return different values on multiple calls
mockRepo.EXPECT().
    FindByID(gomock.Any(), "task-1").
    Return(Task{}, errors.New("not found")).
    Times(1)

mockRepo.EXPECT().
    FindByID(gomock.Any(), "task-1").
    Return(Task{ID: "task-1"}, nil).
    Times(1)

// Call order matters
gomock.InOrder(
    mockRepo.EXPECT().FindByID(gomock.Any(), "task-1").Return(Task{ID: "task-1"}, nil),
    mockRepo.EXPECT().Save(gomock.Any(), gomock.Any()).Return(nil),
)
```

**Table-driven tests with gomock:**

```go
func TestTaskService_Complete_TableDriven(t *testing.T) {
    tests := []struct {
        name        string
        taskID      string
        setupMock   func(*mocks.MockTaskRepository)
        wantErr     bool
    }{
        {
            name:   "complete pending task successfully",
            taskID: "task-1",
            setupMock: func(m *mocks.MockTaskRepository) {
                m.EXPECT().
                    FindByID(gomock.Any(), "task-1").
                    Return(Task{ID: "task-1", Done: false}, nil)
                m.EXPECT().
                    Save(gomock.Any(), gomock.Any()).
                    Return(nil)
            },
            wantErr: false,
        },
        {
            name:   "error when task not found",
            taskID: "task-99",
            setupMock: func(m *mocks.MockTaskRepository) {
                m.EXPECT().
                    FindByID(gomock.Any(), "task-99").
                    Return(Task{}, errors.New("not found"))
            },
            wantErr: true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            ctrl := gomock.NewController(t)
            defer ctrl.Finish()

            mockRepo := mocks.NewMockTaskRepository(ctrl)
            tt.setupMock(mockRepo)

            service := NewTaskService(mockRepo)
            err := service.Complete(context.Background(), tt.taskID)

            if (err != nil) != tt.wantErr {
                t.Errorf("Complete() error = %v, wantErr %v", err, tt.wantErr)
            }
        })
    }
}
```

**Benefits:**
- Type-safe (compile-time verification)
- Auto-updates when interface changes
- Clear expectations in tests
- Verifies call count, order, arguments
- Standard tool in Go ecosystem

**When to use:**
- Testing code that depends on interfaces
- Unit testing services with repository dependencies
- Testing error handling paths

**Applies to**: All interface mocking in tests

---

### test-helpers: Test Helpers Never Return Errors


## Test Helpers Never Return Errors

Test helpers should fail the test (t.Fatalf) instead of returning errors. This keeps test code clean.

**Incorrect (returns error):**

```go
// Forces every caller to check error
func createTask(t *testing.T, desc string) (Task, error) {
    t.Helper()
    return NewTask(desc)
}

// Test must handle error
func TestTaskCompletion(t *testing.T) {
    task, err := createTask(t, "test task")
    if err != nil {
        t.Fatalf("failed to create task: %v", err)  // Boilerplate!
    }

    // Actual test logic
    err = task.Complete()
    if err != nil {
        t.Errorf("Complete() failed: %v", err)
    }
}
```

**Correct (fails test immediately):**

```go
// Fails test immediately on error
func mustCreateTask(t *testing.T, desc string) Task {
    t.Helper()
    task, err := NewTask(desc)
    if err != nil {
        t.Fatalf("failed to create task: %v", err)
    }
    return task
}

// Clean test code
func TestTaskCompletion(t *testing.T) {
    task := mustCreateTask(t, "test task")  // No error handling!

    // Focus on actual test logic
    err := task.Complete()
    if err != nil {
        t.Errorf("Complete() failed: %v", err)
    }
}
```

**Test helper with cleanup:**

```go
// Returns cleanup function
func createTempFile(t *testing.T, content string) (string, func()) {
    t.Helper()

    tmpFile, err := os.CreateTemp("", "test-*.txt")
    if err != nil {
        t.Fatalf("failed to create temp file: %v", err)
    }

    if _, err := tmpFile.WriteString(content); err != nil {
        tmpFile.Close()
        os.Remove(tmpFile.Name())
        t.Fatalf("failed to write to temp file: %v", err)
    }
    tmpFile.Close()

    cleanup := func() {
        os.Remove(tmpFile.Name())
    }

    return tmpFile.Name(), cleanup
}

// Usage
func TestReadFile(t *testing.T) {
    path, cleanup := createTempFile(t, "test content")
    defer cleanup()  // Cleanup automatically

    content, err := ReadFile(path)
    require.NoError(t, err)
    assert.Equal(t, "test content", content)
}
```

**Multiple helpers:**

```go
func mustCreateUser(t *testing.T, email string) *User {
    t.Helper()
    user, err := NewUser(email)
    if err != nil {
        t.Fatalf("failed to create user: %v", err)
    }
    return user
}

func mustHashPassword(t *testing.T, password string) string {
    t.Helper()
    hash, err := HashPassword(password)
    if err != nil {
        t.Fatalf("failed to hash password: %v", err)
    }
    return hash
}

// Clean test using multiple helpers
func TestUserAuthentication(t *testing.T) {
    user := mustCreateUser(t, "test@example.com")
    user.PasswordHash = mustHashPassword(t, "secret123")

    // Test logic without error handling clutter
    err := AuthenticateUser(user.Email, "secret123")
    assert.NoError(t, err)
}
```

**Benefits:**
- Cleaner test code (no error handling boilerplate)
- Fails fast with clear message
- t.Helper() shows correct line number in failure
- Focus on test logic, not setup

**Always use t.Helper():**
```go
func mustDoSomething(t *testing.T) Result {
    t.Helper()  // Reports error at caller's line, not here
    // ...
}
```

**Applies to**: All test helper functions

---

### test-no-mock-netconn: Never Mock net.Conn


## Never Mock net.Conn

Never mock `net.Conn` or low-level network types. Use real connections or test at a higher abstraction level.

**Incorrect (mocking net.Conn):**

```go
// ANTI-PATTERN: Mocking net.Conn
type MockConn struct {
    ReadFunc  func(b []byte) (n int, err error)
    WriteFunc func(b []byte) (n int, err error)
    CloseFunc func() error
    // ... more methods
}

func (m *MockConn) Read(b []byte) (int, error) {
    return m.ReadFunc(b)
}

// Brittle, doesn't test real network behavior
func TestServer(t *testing.T) {
    mockConn := &MockConn{
        ReadFunc: func(b []byte) (int, error) {
            copy(b, []byte("GET / HTTP/1.1\r\n"))
            return 16, nil
        },
    }
    // Tests mock, not real network
}
```

**Correct Option 1: Test at HTTP level (httptest):**

```go
// Test HTTP handlers without mocking network
func TestHTTPHandler(t *testing.T) {
    req := httptest.NewRequest("GET", "/tasks", nil)
    w := httptest.NewRecorder()

    handler := NewTaskHandler(service)
    handler.ServeHTTP(w, req)

    assert.Equal(t, 200, w.Code)
    assert.Contains(t, w.Body.String(), "tasks")
}

// Test HTTP client
func TestHTTPClient(t *testing.T) {
    server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        w.WriteHeader(200)
        json.NewEncoder(w).Encode(Task{ID: "1"})
    }))
    defer server.Close()

    client := NewTaskClient(server.URL)
    task, err := client.GetTask(context.Background(), "1")

    require.NoError(t, err)
    assert.Equal(t, "1", task.ID)
}
```

**Correct Option 2: Real TCP connections:**

```go
// Use real TCP connections for integration tests
func TestTCPServer(t *testing.T) {
    // Start real listener
    listener, err := net.Listen("tcp", "127.0.0.1:0")
    require.NoError(t, err)
    defer listener.Close()

    // Start server in background
    go func() {
        conn, _ := listener.Accept()
        defer conn.Close()
        // Handle connection
        io.Copy(conn, conn) // Echo server
    }()

    // Connect with real TCP connection
    conn, err := net.Dial("tcp", listener.Addr().String())
    require.NoError(t, err)
    defer conn.Close()

    // Test with real connection
    _, err = conn.Write([]byte("hello"))
    require.NoError(t, err)

    buf := make([]byte, 5)
    _, err = conn.Read(buf)
    require.NoError(t, err)
    assert.Equal(t, "hello", string(buf))
}
```

**Correct Option 3: Test at protocol level:**

```go
// Test custom protocol handler with real connection
func TestProtocolHandler(t *testing.T) {
    // Use net.Pipe for in-process connection
    server, client := net.Pipe()
    defer server.Close()
    defer client.Close()

    // Run handler in background
    go func() {
        handler := NewProtocolHandler()
        handler.Handle(server)
    }()

    // Test from client side with real connection
    _, err := client.Write([]byte("COMMAND\n"))
    require.NoError(t, err)

    buf := make([]byte, 1024)
    n, err := client.Read(buf)
    require.NoError(t, err)
    assert.Equal(t, "OK\n", string(buf[:n]))
}
```

**Correct Option 4: Test at application level:**

```go
// Mock at higher abstraction (repository, not network)
func TestTaskService_FetchRemote(t *testing.T) {
    ctrl := gomock.NewController(t)
    defer ctrl.Finish()

    // Mock the repository interface, not net.Conn
    mockRepo := mocks.NewMockTaskRepository(ctrl)
    mockRepo.EXPECT().
        FetchFromRemote(gomock.Any()).
        Return([]Task{{ID: "1"}}, nil)

    service := NewTaskService(mockRepo)
    tasks, err := service.GetRemoteTasks(context.Background())

    require.NoError(t, err)
    assert.Len(t, tasks, 1)
}
```

**Benefits:**
- Tests real network behavior
- Catches timing, buffering, connection issues
- More robust tests
- Tests actual integration
- Avoids brittle mock implementations

**Use these instead of mocking net.Conn:**
- ✅ `httptest.Server` for HTTP servers
- ✅ `httptest.NewRecorder` for HTTP handlers
- ✅ `net.Pipe()` for in-process connections
- ✅ Real TCP connections on `127.0.0.1:0`
- ✅ Mock at higher abstraction (repository/client interface)

**Applies to**: All network-related testing

---

### test-table-driven: Table-Driven Tests


## Table-Driven Tests

Use table-driven tests with descriptive test case names. Preferred pattern for Go testing.

**Incorrect (repetitive test functions):**

```go
func TestCompleteTask_Success(t *testing.T) {
    task := Task{ID: "1", Done: false}
    err := task.Complete()
    if err != nil {
        t.Errorf("expected no error, got %v", err)
    }
}

func TestCompleteTask_AlreadyDone(t *testing.T) {
    task := Task{ID: "2", Done: true}
    err := task.Complete()
    if err == nil {
        t.Error("expected error, got nil")
    }
}

func TestCompleteTask_NoID(t *testing.T) {
    task := Task{ID: "", Done: false}
    err := task.Complete()
    if err == nil {
        t.Error("expected error, got nil")
    }
}
```

**Correct (table-driven with descriptive names):**

```go
func TestTask_Complete(t *testing.T) {
    tests := []struct {
        name    string
        task    Task
        wantErr bool
    }{
        {
            name:    "complete pending task successfully",
            task:    Task{ID: "1", Done: false},
            wantErr: false,
        },
        {
            name:    "error when completing already done task",
            task:    Task{ID: "2", Done: true},
            wantErr: true,
        },
        {
            name:    "error when task has no ID",
            task:    Task{ID: "", Done: false},
            wantErr: true,
        },
        {
            name:    "complete task with description",
            task:    Task{ID: "3", Done: false, Description: "Test task"},
            wantErr: false,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := tt.task.Complete()
            if (err != nil) != tt.wantErr {
                t.Errorf("Complete() error = %v, wantErr %v", err, tt.wantErr)
            }
            if !tt.wantErr && !tt.task.Done {
                t.Error("task should be marked as done")
            }
        })
    }
}
```

**Complex assertions:**

```go
func TestTaskService_Create(t *testing.T) {
    tests := []struct {
        name        string
        description string
        repoErr     error
        want        *Task
        wantErr     bool
    }{
        {
            name:        "create task successfully",
            description: "New task",
            repoErr:     nil,
            want:        &Task{Description: "New task", Done: false},
            wantErr:     false,
        },
        {
            name:        "error when description is empty",
            description: "",
            repoErr:     nil,
            want:        nil,
            wantErr:     true,
        },
        {
            name:        "error when repository fails",
            description: "New task",
            repoErr:     errors.New("db error"),
            want:        nil,
            wantErr:     true,
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            mockRepo := &MockTaskRepository{err: tt.repoErr}
            service := NewTaskService(mockRepo)

            got, err := service.Create(context.Background(), tt.description)

            if (err != nil) != tt.wantErr {
                t.Errorf("Create() error = %v, wantErr %v", err, tt.wantErr)
                return
            }

            if !tt.wantErr {
                if got.Description != tt.want.Description {
                    t.Errorf("Description = %v, want %v", got.Description, tt.want.Description)
                }
                if got.Done != tt.want.Done {
                    t.Errorf("Done = %v, want %v", got.Done, tt.want.Done)
                }
            }
        })
    }
}
```

**Benefits:**
- Descriptive test case names (shows in output)
- Easy to add new test cases
- Reduces code duplication
- Clear structure for reviewers
- t.Run provides isolated subtests

**When to use:**
- Testing functions with multiple scenarios
- Validating edge cases
- Testing error conditions

**Applies to**: All test scenarios with multiple cases

---


## Error Handling (HIGH)

### error-context: Add Context to Errors


## Add Context to Errors

Always add context explaining what failed, not just pass through raw errors.

**Incorrect (no context):**

```go
func ProcessTask(id string) error {
    task, err := GetTask(id)
    if err != nil {
        return err  // What operation failed? Which task?
    }

    err = ValidateTask(task)
    if err != nil {
        return err  // Which validation failed?
    }

    err = SaveTask(task)
    if err != nil {
        return err  // Where did save fail?
    }

    return nil
}

// Error: "connection refused"
// No idea which operation or task!
```

**Correct (adds context):**

```go
func ProcessTask(id string) error {
    task, err := GetTask(id)
    if err != nil {
        return fmt.Errorf("failed to get task %s: %w", id, err)
    }

    if err := ValidateTask(task); err != nil {
        return fmt.Errorf("validation failed for task %s: %w", id, err)
    }

    if err := SaveTask(task); err != nil {
        return fmt.Errorf("failed to save task %s: %w", id, err)
    }

    return nil
}

// Error: "failed to save task abc123: database connection refused"
// Clear which operation and task!
```

**Contextual information to include:**

```go
// Include IDs
return fmt.Errorf("failed to delete task %s: %w", taskID, err)

// Include operation
return fmt.Errorf("failed to parse config file: %w", err)

// Include values
return fmt.Errorf("invalid port %d: must be 1-65535: %w", port, err)

// Include user context
return fmt.Errorf("user %s: failed to create task: %w", userID, err)

// Include file paths
return fmt.Errorf("failed to read %s: %w", configPath, err)
```

**Guard clauses with context:**

```go
func CompleteTask(task *Task) error {
    if task == nil {
        return errors.New("task is nil")
    }

    if task.ID == "" {
        return errors.New("task ID is empty")
    }

    if task.Done {
        return fmt.Errorf("task %s already completed", task.ID)
    }

    // Happy path
    task.Done = true
    return nil
}
```

**Layered context:**

```go
// Each layer adds context

// Repository layer
func (r *TaskRepo) Save(ctx context.Context, task Task) error {
    _, err := r.db.ExecContext(ctx, "INSERT INTO tasks ...")
    if err != nil {
        return fmt.Errorf("database insert failed: %w", err)
    }
    return nil
}

// Service layer
func (s *TaskService) CreateTask(ctx context.Context, desc string) (Task, error) {
    task := Task{ID: uuid.New().String(), Description: desc}

    if err := s.repo.Save(ctx, task); err != nil {
        return Task{}, fmt.Errorf("failed to save new task: %w", err)
    }

    return task, nil
}

// Handler layer
func (h *TaskHandler) HandleCreate(w http.ResponseWriter, r *http.Request) {
    task, err := h.service.CreateTask(r.Context(), description)
    if err != nil {
        log.Printf("failed to create task for user %s: %v", userID, err)
        // Logs: "failed to create task for user u123: failed to save new task: database insert failed: connection refused"
        http.Error(w, "failed to create task", 500)
    }
}
```

**Benefits:**
- Faster debugging (know exactly what failed)
- Actionable error messages
- Clear error propagation
- Better logs and monitoring

**Applies to**: All error returns

---

### error-sentinel: Sentinel Errors


## Sentinel Errors

Define package-level sentinel errors for expected error conditions. Use `errors.Is` to check them.

**Pattern:**

```go
// Define sentinel errors at package level
var (
    ErrTaskNotFound    = errors.New("task not found")
    ErrInvalidTask     = errors.New("invalid task")
    ErrTaskAlreadyDone = errors.New("task already completed")
)

// Return sentinel errors
func (r *TaskRepo) FindByID(ctx context.Context, id string) (Task, error) {
    var task Task
    err := r.db.QueryRowContext(ctx, "SELECT * FROM tasks WHERE id = $1", id).Scan(&task)
    if err == sql.ErrNoRows {
        return Task{}, ErrTaskNotFound
    }
    if err != nil {
        return Task{}, fmt.Errorf("database error: %w", err)
    }
    return task, nil
}

// Check with errors.Is
func (s *TaskService) GetTask(ctx context.Context, id string) (Task, error) {
    task, err := s.repo.FindByID(ctx, id)
    if err != nil {
        if errors.Is(err, ErrTaskNotFound) {
            // Handle specific error
            return Task{}, ErrTaskNotFound
        }
        return Task{}, fmt.Errorf("failed to get task: %w", err)
    }
    return task, nil
}

// HTTP handler uses sentinel errors
func (h *TaskHandler) HandleGet(w http.ResponseWriter, r *http.Request) {
    task, err := h.service.GetTask(r.Context(), taskID)
    if err != nil {
        if errors.Is(err, ErrTaskNotFound) {
            http.Error(w, "task not found", 404)
            return
        }
        log.Printf("error getting task: %v", err)
        http.Error(w, "internal server error", 500)
        return
    }
    json.NewEncoder(w).Encode(task)
}
```

**Wrapped sentinel errors:**

```go
// Sentinel errors work through wrapping
func (s *TaskService) CompleteTask(ctx context.Context, id string) error {
    task, err := s.repo.FindByID(ctx, id)
    if err != nil {
        // Wraps ErrTaskNotFound
        return fmt.Errorf("complete: %w", err)
    }

    if task.Done {
        return fmt.Errorf("task %s: %w", id, ErrTaskAlreadyDone)
    }

    task.Done = true
    if err := s.repo.Save(ctx, task); err != nil {
        return fmt.Errorf("failed to save: %w", err)
    }

    return nil
}

// errors.Is finds wrapped sentinel
err := service.CompleteTask(ctx, "task-1")
if errors.Is(err, ErrTaskNotFound) {
    // Detects even through wrapping
}
if errors.Is(err, ErrTaskAlreadyDone) {
    // Also detects
}
```

**Custom error types (advanced):**

```go
// When you need to attach data to errors
type ValidationError struct {
    Field   string
    Message string
}

func (e *ValidationError) Error() string {
    return fmt.Sprintf("validation error on %s: %s", e.Field, e.Message)
}

// Return custom error
func ValidateTask(task Task) error {
    if task.Description == "" {
        return &ValidationError{
            Field:   "description",
            Message: "description required",
        }
    }
    return nil
}

// Check with errors.As
var validErr *ValidationError
if errors.As(err, &validErr) {
    log.Printf("validation failed on field: %s", validErr.Field)
}
```

**Benefits:**
- Explicit error checking
- Survives error wrapping
- Clear error types for callers
- Better error handling in HTTP/API layers

**When to use:**
- Expected error conditions (not found, invalid input, already exists)
- Errors that callers should handle differently
- Domain-specific errors

**Applies to**: Expected error conditions that need special handling

---

### error-wrapping: Error Wrapping with %w


## Error Wrapping with %w

Wrap errors with context using `fmt.Errorf` with `%w`. Preserves error chain for `errors.Is` and `errors.As`.

**Incorrect (loses context):**

```go
// Raw error - no context
func GetTask(id string) (Task, error) {
    task, err := repo.FindByID(id)
    if err != nil {
        return Task{}, err  // What failed? Which ID?
    }
    return task, nil
}

// String concatenation - breaks errors.Is
func SaveTask(task Task) error {
    err := repo.Save(task)
    if err != nil {
        return fmt.Errorf("save failed: %v", err)  // %v, not %w!
    }
    return nil
}
```

**Correct (wraps with context):**

```go
func GetTask(id string) (Task, error) {
    task, err := repo.FindByID(id)
    if err != nil {
        return Task{}, fmt.Errorf("failed to get task %s: %w", id, err)
    }
    return task, nil
}

func SaveTask(task Task) error {
    if err := repo.Save(task); err != nil {
        return fmt.Errorf("failed to save task %s: %w", task.ID, err)
    }
    return nil
}

// Enables errors.Is checking
if errors.Is(err, sql.ErrNoRows) {
    // Can detect specific errors through wrapping
}
```

**Layered error wrapping:**

```go
// Repository layer
func (r *TaskRepo) FindByID(ctx context.Context, id string) (Task, error) {
    var task Task
    err := r.db.QueryRowContext(ctx, "SELECT * FROM tasks WHERE id = $1", id).Scan(&task)
    if err != nil {
        return Task{}, fmt.Errorf("query failed for task %s: %w", id, err)
    }
    return task, nil
}

// Service layer
func (s *TaskService) GetTask(ctx context.Context, id string) (Task, error) {
    task, err := s.repo.FindByID(ctx, id)
    if err != nil {
        return Task{}, fmt.Errorf("service: failed to get task: %w", err)
    }
    return task, nil
}

// Handler layer
func (h *TaskHandler) HandleGet(w http.ResponseWriter, r *http.Request) {
    task, err := h.service.GetTask(r.Context(), taskID)
    if err != nil {
        log.Printf("error: %v", err)
        // Logs: "service: failed to get task: query failed for task 123: sql: no rows"
        http.Error(w, "task not found", 404)
    }
}
```

**Benefits:**
- Clear error context at each layer
- Preserves original error for `errors.Is`/`errors.As`
- Debugging shows full error chain
- Idiomatic Go error handling

**Use %w for:**
- Wrapping errors from dependencies
- Adding context to errors
- Preserving error chain

**Use %v for:**
- Logging only (when you don't need error chain)
- When you want to hide underlying error type

**Applies to**: All error returns

---


## Code Organization (MEDIUM)

### org-function-breakdown: Break Down Functions Judiciously


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

---

### org-guard-clauses: Guard Clauses over Nested Ifs


## Guard Clauses over Nested Ifs

Use early returns (guard clauses) instead of nested ifs. Keep the happy path unindented.

**Incorrect (nested ifs):**

```go
func Process(task *Task) error {
    if task != nil {
        if task.ID != "" {
            if !task.Done {
                if task.Priority > 0 {
                    // Happy path deeply nested
                    if err := validate(task); err != nil {
                        return err
                    }
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
    // Guard clauses at the top
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

    // Happy path not indented
    if err := validate(task); err != nil {
        return err
    }

    return save(task)
}
```

**More examples:**

```go
// ❌ Nested ifs
func GetUser(id string) (*User, error) {
    if id != "" {
        user, err := repo.FindByID(id)
        if err == nil {
            if user.Active {
                return user, nil
            } else {
                return nil, errors.New("user inactive")
            }
        } else {
            return nil, err
        }
    } else {
        return nil, errors.New("empty ID")
    }
}

// ✅ Guard clauses
func GetUser(id string) (*User, error) {
    if id == "" {
        return nil, errors.New("empty ID")
    }

    user, err := repo.FindByID(id)
    if err != nil {
        return nil, err
    }

    if !user.Active {
        return nil, errors.New("user inactive")
    }

    return user, nil
}
```

**With business logic:**

```go
// ✅ Guard clauses for validation, then business logic
func CompleteTask(task *Task, userID string) error {
    // Validation guards
    if task == nil {
        return errors.New("task is nil")
    }
    if userID == "" {
        return errors.New("user ID required")
    }
    if task.Done {
        return fmt.Errorf("task %s already completed", task.ID)
    }
    if task.AssignedTo != userID {
        return fmt.Errorf("task %s not assigned to user %s", task.ID, userID)
    }

    // Business logic not nested
    task.Done = true
    task.CompletedAt = time.Now()
    task.CompletedBy = userID

    return repo.Save(task)
}
```

**Benefits:**
- Happy path clearly visible
- Reduced nesting
- Easier to read
- Clear error conditions first

**Applies to**: All functions with multiple validations

---

### org-package-structure: Package Organization by Domain


## Package Organization by Domain

Organize packages by domain/concern, not by type. Group related functionality together.

**Incorrect (organized by type):**

```
pkg/
  models/
    user.go
    task.go
    project.go
  handlers/
    user_handler.go
    task_handler.go
    project_handler.go
  services/
    user_service.go
    task_service.go
    project_service.go
  repositories/
    user_repository.go
    task_repository.go
    project_repository.go

// Everything scattered across packages
```

**Correct (organized by domain):**

```
pkg/
  user/
    user.go           # Domain model
    service.go        # Business logic
    repository.go     # Port
    handler.go        # HTTP adapter
  task/
    task.go
    service.go
    repository.go
    handler.go
  project/
    project.go
    service.go
    repository.go
    handler.go

// Related functionality grouped together
```

**Small project (<1K lines):**

```
main.go
task.go          # Domain models
repository.go    # Ports
postgres.go      # Adapters
handlers.go      # HTTP
```

**Medium project (1K-10K lines):**

```
cmd/server/main.go
pkg/
  task/
    task.go       # Domain
    repository.go # Port
    service.go
  postgres/
    task_repo.go  # Adapter
  http/
    handlers.go
```

**Large project (10K+ lines):**

```
internal/
  task/
    domain/
      task.go
    application/
      service.go
    adapters/
      postgres_repo.go
      http_controller.go
    ports/
      repository.go
  user/
    domain/
      user.go
    application/
      service.go
    adapters/
      postgres_repo.go
      http_controller.go
    ports/
      repository.go
```

**When to create a separate package:**

```go
// ✅ Can be used independently
pkg/email/      # Email sending (standalone)
pkg/auth/       # Authentication (standalone)

// ✅ Clear domain boundary
pkg/user/       # User domain
pkg/task/       # Task domain
pkg/billing/    # Billing domain

// ✅ More than 2-3 related files
pkg/notification/
  email.go
  sms.go
  push.go
  template.go

// ❌ Just one or two simple functions
pkg/helpers/
  format.go     # Just put in calling package

// ❌ Tightly coupled to another package
pkg/taskhelpers/  # Should be in task package
```

**Shared code:**

```
pkg/
  task/
    task.go
    service.go
  user/
    user.go
    service.go
  common/          # Shared utilities
    errors.go
    validation.go
  database/        # Shared infrastructure
    connection.go
```

**Benefits:**
- Related code together
- Clear boundaries
- Easy to find files
- Natural package evolution

**Applies to**: All package organization

---

### org-simplicity: Keep It Simple


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

---

### org-yagni: YAGNI - You Aren't Gonna Need It


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

---


## Performance (MEDIUM)

### perf-concurrency: Handle Concurrent Access


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

---

### perf-edge-cases: Handle Edge Cases


## Handle Edge Cases

Always handle nil checks, empty collections, boundary values, and resource cleanup.

**Nil checks:**

```go
// ✅ Check for nil
func Process(task *Task) error {
    if task == nil {
        return errors.New("task is nil")
    }
    // Safe to use task
    task.Done = true
    return nil
}

// ❌ No nil check - will panic
func Process(task *Task) error {
    task.Done = true  // Panic if task is nil!
    return nil
}
```

**Empty collections:**

```go
// ✅ Check for empty
func ProcessTasks(tasks []Task) error {
    if len(tasks) == 0 {
        return errors.New("no tasks to process")
    }

    for _, task := range tasks {
        // Process
    }
    return nil
}

// ✅ Empty map handling
func GetUserTasks(tasksByUser map[string][]Task, userID string) []Task {
    tasks, ok := tasksByUser[userID]
    if !ok || len(tasks) == 0 {
        return []Task{}  // Return empty slice, not nil
    }
    return tasks
}
```

**Boundary values:**

```go
// ✅ Validate boundaries
func SetPriority(priority int) error {
    if priority < 1 || priority > 5 {
        return errors.New("priority must be 1-5")
    }
    // Safe to use
    return nil
}

func SetLimit(limit int) error {
    if limit <= 0 {
        return errors.New("limit must be positive")
    }
    if limit > 1000 {
        return errors.New("limit too large (max 1000)")
    }
    return nil
}

// ✅ String length validation
func SetDescription(desc string) error {
    if len(desc) == 0 {
        return errors.New("description required")
    }
    if len(desc) > 1000 {
        return errors.New("description too long (max 1000 chars)")
    }
    return nil
}
```

**Resource cleanup:**

```go
// ✅ Always defer cleanup
func ProcessFile(path string) error {
    file, err := os.Open(path)
    if err != nil {
        return err
    }
    defer file.Close()  // Cleanup on all exit paths

    // Process file
    return nil
}

// ✅ Database transaction cleanup
func UpdateTask(db *sql.DB, task Task) error {
    tx, err := db.Begin()
    if err != nil {
        return err
    }
    defer tx.Rollback()  // Rollback if not committed

    if err := doUpdate(tx, task); err != nil {
        return err  // Rollback happens
    }

    return tx.Commit()  // Success
}

// ✅ Context cancellation
func ProcessWithTimeout(ctx context.Context) error {
    ctx, cancel := context.WithTimeout(ctx, 30*time.Second)
    defer cancel()  // Release resources

    // Process
    return nil
}
```

**Division by zero:**

```go
// ✅ Check divisor
func Average(total, count int) (float64, error) {
    if count == 0 {
        return 0, errors.New("cannot divide by zero")
    }
    return float64(total) / float64(count), nil
}
```

**Index bounds:**

```go
// ✅ Check array bounds
func GetTaskAtIndex(tasks []Task, index int) (Task, error) {
    if index < 0 || index >= len(tasks) {
        return Task{}, errors.New("index out of bounds")
    }
    return tasks[index], nil
}
```

**Concurrent access:**

```go
// ✅ Handle concurrent access
type Cache struct {
    mu    sync.RWMutex
    items map[string]Task
}

func (c *Cache) Get(key string) (Task, bool) {
    c.mu.RLock()
    defer c.mu.RUnlock()

    task, ok := c.items[key]
    return task, ok
}

func (c *Cache) Set(key string, task Task) {
    c.mu.Lock()
    defer c.mu.Unlock()

    c.items[key] = task
}
```

**Benefits:**
- Prevents panics
- Robust code
- Clear error messages
- Predictable behavior

**Applies to**: All functions dealing with pointers, collections, boundaries

---


## Patterns (LOW)

### pattern-config-defaults: Configuration Structs with Defaults


## Configuration Structs with Defaults

Use configuration structs with default values. Avoid global variables.

**Pattern:**

```go
type Config struct {
    Port     int
    Host     string
    MaxRetry int
    Timeout  time.Duration
}

func DefaultConfig() Config {
    return Config{
        Port:     8080,
        Host:     "localhost",
        MaxRetry: 3,
        Timeout:  30 * time.Second,
    }
}

// Usage
cfg := DefaultConfig()
cfg.Port = 9000  // Override as needed
server := NewServer(cfg)
```

**With functional options:**

```go
type Option func(*Config)

func WithPort(port int) Option {
    return func(c *Config) {
        c.Port = port
    }
}

func NewServerWithOptions(opts ...Option) *Server {
    cfg := DefaultConfig()
    for _, opt := range opts {
        opt(&cfg)
    }
    return &Server{config: cfg}
}

// Usage
server := NewServerWithOptions(
    WithPort(9000),
    WithHost("0.0.0.0"),
)
```

**Benefits:**
- No global state
- Easy to test
- Clear dependencies

**Applies to**: All configuration

---

