---
title: Guard Clauses
impact: HIGH
impactDescription: Reduces nesting, improves readability, clearer error paths
tags: python, error-handling, guard-clauses, early-return
category: error
---

## Guard Clauses

Use early returns to handle error cases, keeping the happy path un-nested.

**Incorrect:**

```python
# Nested if/else creates cognitive load
def process(item: Item) -> Result:
    if item.is_valid():
        return self._transform(item)
    else:
        raise ValueError("Invalid item")
```

**Correct:**

```python
# Guard clause: fail fast, happy path clear
def process(item: Item) -> Result:
    if not item.is_valid():
        raise ValueError("Invalid item")

    # Happy path without nesting
    return self._transform(item)
```

**Benefits:**
- Reduces nesting levels
- Happy path is obvious
- Error conditions explicit
- Easier to read and maintain

**Applies to**: All functions with validation or error conditions
