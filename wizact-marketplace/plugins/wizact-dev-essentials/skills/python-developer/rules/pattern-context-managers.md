---
title: Context Managers
impact: MEDIUM
impactDescription: Automatic resource cleanup, prevents resource leaks
tags: python, context-manager, resource-management, async
category: pattern
---

## Context Managers

Use context managers for automatic resource cleanup.

**Incorrect:**

```python
# Manual cleanup: easy to forget, error-prone
f = open(path, 'r')
content = f.read()
f.close()  # Might not execute if error occurs
```

**Correct:**

```python
# Automatic cleanup: guaranteed even with exceptions
with open(path, 'r') as f:
    content = f.read()
# File automatically closed

# Async context managers
async with aiofiles.open(path, 'r') as f:
    content = await f.read()

# Custom resource management
with resource_manager() as resource:
    resource.process()
```

**Benefits:**
- Guaranteed cleanup even on exceptions
- Clear resource lifetime
- Pythonic resource management
- Prevents resource leaks

**Applies to**: File operations, network connections, locks, database transactions
