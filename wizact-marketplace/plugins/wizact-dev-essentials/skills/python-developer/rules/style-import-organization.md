---
title: Import Organization
impact: MEDIUM
impactDescription: Clean imports improve readability, prevent circular dependencies
tags: python, imports, pep8, code-organization
category: style
---

## Import Organization

Organize imports in three groups: stdlib, third-party, local.

**Incorrect:**

```python
# Mixed import order, hard to read
from package_name.domain import models
import httpx
from pathlib import Path
import asyncio
from pydantic import BaseModel
```

**Correct:**

```python
# 1. Standard library
import asyncio
from pathlib import Path

# 2. Third-party packages
import httpx
from pydantic import BaseModel

# 3. Local imports
from package_name.domain import models
```

Use `ruff format` for automatic import sorting.

**Benefits:**
- Clear dependency boundaries
- Easier to spot missing dependencies
- Prevents circular imports
- Standard Python practice (PEP 8)

**Applies to**: All Python modules
