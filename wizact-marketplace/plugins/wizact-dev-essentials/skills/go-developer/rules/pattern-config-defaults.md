---
title: Configuration Structs with Defaults
impact: LOW
impactDescription: Clear configuration, testable, avoids global state
tags: patterns, configuration, defaults, go
category: pattern
---

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
