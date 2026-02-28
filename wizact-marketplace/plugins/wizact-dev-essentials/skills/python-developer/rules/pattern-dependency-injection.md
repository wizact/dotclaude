---
title: Dependency Injection
impact: MEDIUM
impactDescription: Testable code, flexible implementations, clear dependencies
tags: python, dependency-injection, testing, architecture
category: pattern
---

## Dependency Injection

Pass dependencies through constructors instead of creating them internally.

**Incorrect:**

```python
# Hard-coded dependencies: untestable
class Service:
    def __init__(self):
        self.repository = PostgresRepository()  # Hard-coded
        self.cache = RedisCache()  # Hard-coded
```

**Correct:**

```python
# Dependencies injected: testable and flexible
class Service:
    def __init__(
        self,
        repository: Repository,
        cache: Cache,
    ):
        self.repository = repository
        self.cache = cache

# Easy to test with mocks
service = Service(
    repository=MockRepository(),
    cache=InMemoryCache(),
)
```

**Benefits:**
- Easy to test with mocks
- Swap implementations without code changes
- Clear dependency requirements
- Supports dependency inversion principle

**Applies to**: All service classes with external dependencies
