---
title: Exception Chaining
impact: HIGH
impactDescription: Preserves error context for debugging, maintains stack traces
tags: python, error-handling, exceptions, debugging
category: error
---

## Exception Chaining

Always chain exceptions using `from err` to preserve the original error context.

**Incorrect:**

```python
# Loses original error context
try:
    data = json.loads(line)
except json.JSONDecodeError:
    raise ValidationError("Invalid JSON")  # Original error lost
```

**Correct:**

```python
# Preserves full error chain
try:
    data = json.loads(line)
except json.JSONDecodeError as err:
    raise ValidationError(f"Invalid JSON at line {n}") from err
    # Full stack trace preserved, original error accessible
```

**Benefits:**
- Complete error context for debugging
- Stack traces show full error chain
- Easier to diagnose root causes
- Python best practice (PEP 3134)

**Applies to**: All exception re-raising and wrapping
