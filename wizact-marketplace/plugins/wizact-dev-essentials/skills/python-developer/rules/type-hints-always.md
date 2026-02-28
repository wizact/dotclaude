---
title: Always Use Type Hints
impact: CRITICAL
impactDescription: Enables static analysis, prevents runtime errors, improves code maintainability
tags: python, type-hints, mypy, static-analysis
category: type
---

## Always Use Type Hints

Type hints are essential for catching bugs early and enabling IDE support. Enforce with mypy strict mode.

**Incorrect:**

```python
# No type information
def process(data):
    pass

# Incomplete types
def fetch_items():
    return []
```

**Correct:**

```python
from typing import AsyncIterator

# Clear function contract
def process_items(self, items: list[Item]) -> list[Result]:
    pass

# Async iterators properly typed
async def fetch_data(self) -> AsyncIterator[Record]:
    pass
```

**Benefits:**
- Catch type errors before runtime
- Enable IDE autocomplete and refactoring
- Self-documenting code
- Required for production Python

**Applies to**: All functions, methods, and class attributes
