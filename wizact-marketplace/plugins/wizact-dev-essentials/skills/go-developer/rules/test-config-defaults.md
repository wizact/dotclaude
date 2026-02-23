---
title: Configuration with Defaults (No Global State)
impact: HIGH
impactDescription: Enables test isolation, prevents global state issues, improves testability
tags: testing, configuration, global-state, go
category: test
---

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
