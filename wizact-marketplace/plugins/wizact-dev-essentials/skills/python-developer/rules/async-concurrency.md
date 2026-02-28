---
title: Async Concurrency with asyncio.gather
impact: CRITICAL
impactDescription: Parallel I/O operations dramatically improve performance
tags: python, async, asyncio, concurrency, performance
category: async
---

## Async Concurrency with asyncio.gather

Run independent I/O operations concurrently instead of sequentially.

**Incorrect:**

```python
# Sequential: waits for each operation to complete
async def fetch_users(ids: list[str]) -> list[User]:
    results = []
    for user_id in ids:
        user = await fetch_user(user_id)  # One at a time
        results.append(user)
    return results
```

**Correct:**

```python
import asyncio

# Concurrent: all operations run in parallel
async def fetch_users(ids: list[str]) -> list[User]:
    results = await asyncio.gather(
        fetch_user(ids[0]),
        fetch_user(ids[1]),
        fetch_user(ids[2]),
    )
    return list(results)

# Or with list comprehension
async def fetch_users(ids: list[str]) -> list[User]:
    tasks = [fetch_user(user_id) for user_id in ids]
    results = await asyncio.gather(*tasks)
    return list(results)
```

**Benefits:**
- 10-100x faster for I/O-bound operations
- Maximizes network/disk utilization
- Natural async/await syntax
- Automatic error propagation

**Applies to**: All independent async I/O operations (API calls, database queries, file reads)
