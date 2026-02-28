---
title: Use Frozen Dataclasses and Pydantic Models
impact: CRITICAL
impactDescription: Prevents mutation bugs, enables safe sharing across async tasks
tags: python, immutability, dataclasses, pydantic
category: type
---

## Use Frozen Dataclasses and Pydantic Models

Immutable data structures prevent bugs from unexpected mutations, especially in async/concurrent code.

**Incorrect:**

```python
# Mutable dataclass - can be changed after creation
@dataclass
class DomainModel:
    id: str
    name: str

# Mutable Pydantic model
class AppConfig(BaseModel):
    api_key: str
    timeout: int = 30
```

**Correct:**

```python
from dataclasses import dataclass
from pydantic import BaseModel, ConfigDict

# Frozen dataclass - immutable
@dataclass(frozen=True)
class DomainModel:
    id: str
    name: str

# Frozen Pydantic model
class AppConfig(BaseModel):
    model_config = ConfigDict(frozen=True)
    api_key: str
    timeout: int = 30
```

**Benefits:**
- Prevents accidental mutations
- Safe to share across threads/async tasks
- Hashable (can use as dict keys)
- Clear intent: this value doesn't change

**Applies to**: All domain models, configuration objects, and data transfer objects
