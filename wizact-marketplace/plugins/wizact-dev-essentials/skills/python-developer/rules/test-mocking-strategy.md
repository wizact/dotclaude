---
title: Mocking Strategy
impact: HIGH
impactDescription: Mock only expensive operations, test real logic
tags: python, testing, mocking, unittest
category: test
---

## Mocking Strategy

Mock only slow or expensive operations. Use real components where possible.

**Incorrect:**

```python
# Over-mocking: testing mocks, not real code
@patch('module.Service')
@patch('module.Repository')
@patch('module.Validator')
async def test_with_mocks(mock_val, mock_repo, mock_svc):
    # Testing mock behavior, not real code
    pass
```

**Correct:**

```python
from unittest.mock import patch, Mock

# Mock only external dependencies
@patch('module.ExternalService')
async def test_with_minimal_mock(mock_external):
    # Use real Service, Repository, Validator
    # Mock only slow/expensive external API
    mock_external.return_value = {"status": "ok"}

    result = await service.process()
    assert result.is_valid()
```

**Benefits:**
- Tests real code behavior
- Catches integration issues
- Faster to write and maintain
- More confidence in tests

**Applies to**: Mock external APIs, databases, file systems, network calls - not internal logic
