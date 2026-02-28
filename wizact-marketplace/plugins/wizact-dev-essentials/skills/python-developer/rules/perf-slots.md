---
title: Use __slots__ for Many Instances
impact: LOW
impactDescription: Reduces memory overhead when creating many instances
tags: python, slots, memory, performance, dataclasses
category: perf
---

## Use __slots__ for Many Instances

Use `__slots__` or dataclass `slots=True` when creating many instances of a class.

**When to use:**

```python
from dataclasses import dataclass

# Creating millions of instances: use slots
@dataclass(frozen=True, slots=True)
class Record:
    """Slots reduce memory overhead by ~40%."""
    id: str
    data: str
    timestamp: int

# Load millions of records
records = [Record(...) for _ in range(1_000_000)]
# Saves ~40% memory compared to without slots
```

**When NOT to use:**

```python
# Regular class with few instances: no need for slots
@dataclass(frozen=True)
class AppConfig:
    api_key: str
    timeout: int
    # Only 1 instance, slots add complexity without benefit
```

**Benefits:**
- ~40% memory reduction per instance
- Faster attribute access
- Prevents accidental attribute assignment

**Trade-offs:**
- Can't add attributes dynamically
- Slightly more complex
- Only worth it for many instances (>10,000)

**Applies to**: Classes with many instances (records, data points, events)
