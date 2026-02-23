---
title: Test Fixtures in testdata/
impact: HIGH
impactDescription: Improves test maintainability, separates test data from code
tags: testing, fixtures, testdata, go
category: test
---

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
