---
title: Use Dataclasses
impact: MEDIUM
impactDescription: Reduces boilerplate, automatic __repr__, __eq__, etc.
tags: python, dataclasses, boilerplate, code-quality
category: style
---

## Use Dataclasses

Use dataclasses instead of manual __init__ and boilerplate methods.

**Incorrect:**

```python
# Manual boilerplate: verbose, error-prone
class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __repr__(self):
        return f"Point({self.x}, {self.y})"

    def __eq__(self, other):
        return self.x == other.x and self.y == other.y

    # ... more boilerplate
```

**Correct:**

```python
from dataclasses import dataclass

# Clean, concise, automatic methods
@dataclass(frozen=True)
class Point:
    x: float
    y: float
    # __init__, __repr__, __eq__ auto-generated
```

**Benefits:**
- Less boilerplate code
- Automatic __repr__, __eq__, __hash__
- Type hints enforced
- Immutability with frozen=True
- Standard Python (PEP 557)

**Applies to**: All data-holding classes
