---
title: Avoid Mutable Default Arguments
impact: MEDIUM
impactDescription: Prevents shared state bugs, classic Python gotcha
tags: python, mutable-defaults, bugs, best-practices
category: pattern
---

## Avoid Mutable Default Arguments

Never use mutable objects (list, dict) as default arguments.

**Incorrect:**

```python
# Dangerous: default list is shared across all calls
def process(items: list[str] = []) -> list[str]:
    items.append("new")
    return items

# Bug: each call mutates the same list!
result1 = process()  # ["new"]
result2 = process()  # ["new", "new"]  # Unexpected!
```

**Correct:**

```python
# Safe: new list created for each call
def process(items: list[str] | None = None) -> list[str]:
    if items is None:
        items = []
    items.append("new")
    return items

# Works correctly
result1 = process()  # ["new"]
result2 = process()  # ["new"]  # Correct!
```

**Why it happens:**
Default arguments are evaluated once at function definition, not at each call.

**Benefits:**
- No shared state bugs
- Predictable behavior
- Avoids classic Python gotcha

**Applies to**: All functions with list, dict, or other mutable defaults
