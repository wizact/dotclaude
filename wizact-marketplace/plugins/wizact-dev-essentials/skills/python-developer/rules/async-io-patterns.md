---
title: Async I/O Patterns
impact: CRITICAL
impactDescription: Proper async file I/O prevents blocking event loop
tags: python, async, aiofiles, async-iterator
category: async
---

## Async I/O Patterns

Use async libraries for I/O operations to avoid blocking the event loop.

**Incorrect:**

```python
# Blocks event loop
def read_file(path: Path) -> list[str]:
    with open(path, 'r') as f:
        return [line.strip() for line in f]
```

**Correct:**

```python
import aiofiles
from pathlib import Path
from typing import AsyncIterator

# Non-blocking async file reading
async def read_file(path: Path) -> AsyncIterator[str]:
    async with aiofiles.open(path, 'r') as f:
        async for line in f:
            yield line.strip()
```

**Benefits:**
- Keeps event loop responsive
- Enables concurrent I/O operations
- Scales to handle multiple files simultaneously
- Industry standard for async Python

**Applies to**: All file I/O, network I/O, and database operations in async code
