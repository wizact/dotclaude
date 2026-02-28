---
title: Explicit is Better than Implicit
impact: MEDIUM
impactDescription: Clear code intent, better type checking, easier debugging
tags: python, explicit, type-hints, clarity
category: style
---

## Explicit is Better than Implicit

Make types and behavior explicit for clarity and tooling support.

**Incorrect:**

```python
# Unclear types and behavior
def read_file(p):
    with open(p) as f:
        return f.read()

def process(data):
    return [x for x in data if x]
```

**Correct:**

```python
from pathlib import Path

# Clear types and intent
def read_file(path: Path) -> str:
    """Read file contents as string."""
    with path.open() as f:
        return f.read()

def process(data: list[str]) -> list[str]:
    """Filter out empty strings."""
    return [x for x in data if x]
```

**Benefits:**
- IDE autocomplete and type checking
- Self-documenting code
- Catches bugs at development time
- Easier to refactor

**Applies to**: All functions, especially public APIs
