---
title: Async Tests
impact: HIGH
impactDescription: Properly test async code without blocking
tags: python, testing, pytest, asyncio, async
category: test
---

## Async Tests

Use pytest-asyncio for testing async functions.

**Incorrect:**

```python
# Doesn't properly await async functions
def test_async_operation():
    result = async_function()  # Returns coroutine, not result
    assert result is not None
```

**Correct:**

```python
import pytest

# Properly awaits async functions
@pytest.mark.asyncio
async def test_async_operation():
    result = await async_function()
    assert result is not None

# Multiple async operations
@pytest.mark.asyncio
async def test_multiple_operations():
    result1 = await async_op1()
    result2 = await async_op2()
    assert result1 != result2
```

Configure pytest:
```toml
[tool.pytest.ini_options]
asyncio_mode = "auto"  # Auto-detect async tests
```

**Benefits:**
- Properly tests async code
- Catches async-specific bugs
- Works with asyncio event loop
- Standard pytest integration

**Applies to**: All tests for async functions
