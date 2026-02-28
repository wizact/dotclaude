---
title: Streaming with Batching
impact: MEDIUM
impactDescription: Memory-efficient processing of large datasets
tags: python, async, streaming, batching, memory
category: pattern
---

## Streaming with Batching

Process large datasets in batches using async iterators.

**Example:**

```python
from typing import AsyncIterator, TypeVar

T = TypeVar('T')

async def _batch_items(
    source: AsyncIterator[T],
    batch_size: int
) -> AsyncIterator[list[T]]:
    """Group items into batches for efficient processing."""
    batch = []
    async for item in source:
        batch.append(item)
        if len(batch) >= batch_size:
            yield batch
            batch = []

    if batch:  # Don't forget partial batch
        yield batch

# Usage
async for batch in _batch_items(data_stream, batch_size=100):
    await process_batch(batch)
```

**Benefits:**
- Constant memory usage regardless of data size
- Efficient bulk operations (batch inserts)
- Backpressure handling
- Scalable to billions of records

**Applies to**: Large file processing, data pipelines, ETL operations
