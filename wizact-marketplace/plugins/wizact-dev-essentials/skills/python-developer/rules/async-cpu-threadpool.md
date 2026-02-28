---
title: CPU-Bound Operations in Thread Pool
impact: CRITICAL
impactDescription: Prevents blocking event loop with CPU-intensive work
tags: python, async, asyncio, threadpool, cpu-bound
category: async
---

## CPU-Bound Operations in Thread Pool

Run blocking/CPU-intensive operations in thread pool to avoid blocking the event loop.

**Incorrect:**

```python
# Blocks event loop during CPU-intensive work
async def process_data(data: bytes) -> Result:
    # CPU-intensive: blocking all other tasks
    return expensive_computation(data)
```

**Correct:**

```python
import asyncio

# Run blocking operations in thread pool
async def process_data(data: bytes) -> Result:
    result = await asyncio.to_thread(
        expensive_computation,
        data
    )
    return result
```

**Benefits:**
- Event loop stays responsive
- Other async tasks can run concurrently
- Simple API for mixed sync/async code
- No need to rewrite sync libraries

**Applies to**: CPU-intensive operations, synchronous library calls, blocking operations in async code
