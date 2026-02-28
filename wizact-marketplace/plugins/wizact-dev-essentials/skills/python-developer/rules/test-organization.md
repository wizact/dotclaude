---
title: Test Organization
impact: HIGH
impactDescription: Clear separation enables faster test runs, easier maintenance
tags: python, testing, pytest, test-structure
category: test
---

## Test Organization

Organize tests by speed and dependency requirements.

**Incorrect:**

```
tests/
  test_everything.py  # Mixed fast/slow tests
  test_stuff.py
```

**Correct:**

```
tests/
├── unit/           # Fast, mocked dependencies
│   ├── test_service.py
│   └── test_models.py
├── integration/    # Real components, slower
│   ├── test_database.py
│   └── test_api.py
└── fixtures/       # Shared test data
    └── sample_data.json
```

**Benefits:**
- Run fast unit tests during development
- Integration tests for CI/CD
- Clear test boundaries
- Easy to parallelize

**Applies to**: All Python projects with tests
