---
title: Naming Conventions
impact: MEDIUM
impactDescription: Consistent naming improves readability, follows PEP 8
tags: python, naming, pep8, code-style
category: style
---

## Naming Conventions

Follow PEP 8 naming conventions consistently.

**Naming Rules:**
- **Modules/Packages**: `lowercase_with_underscores`
- **Classes**: `PascalCase`
- **Functions/Variables**: `snake_case`
- **Constants**: `UPPER_SNAKE_CASE`
- **Private**: `_leading_underscore`

**Examples:**

```python
# Module: user_service.py
MAX_RETRY_COUNT = 3  # Constant

class UserService:  # Class: PascalCase
    def __init__(self):
        self._cache = {}  # Private: leading underscore

    def fetch_user(self, user_id: str) -> User:  # Function: snake_case
        retry_count = 0  # Variable: snake_case
        return user
```

**Benefits:**
- Immediate recognition of identifier type
- Follows Python community standards
- Better IDE support
- Easier code review

**Applies to**: All Python code
