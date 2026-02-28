---
title: EAFP over LBYL
impact: MEDIUM
impactDescription: Pythonic error handling, better performance in happy path
tags: python, eafp, error-handling, pythonic
category: style
---

## EAFP over LBYL

"Easier to Ask Forgiveness than Permission" - use try/except instead of pre-checking.

**Incorrect (LBYL - Look Before You Leap):**

```python
# Check before action: slower, race conditions possible
if 'key' in data:
    return data['key']
else:
    return default

if os.path.exists(filepath):
    with open(filepath) as f:
        return f.read()
```

**Correct (EAFP - Easier to Ask Forgiveness than Permission):**

```python
# Try first, handle exceptions: faster, atomic
try:
    return data['key']
except KeyError:
    return default

try:
    with open(filepath) as f:
        return f.read()
except FileNotFoundError:
    return default
```

**Benefits:**
- Faster in the happy path (no double check)
- Atomic operations (no race conditions)
- More Pythonic style
- Handles edge cases naturally

**Applies to**: Dictionary access, file operations, attribute access
