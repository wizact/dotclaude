---
title: Generator Expressions for Large Data
impact: LOW
impactDescription: Memory-efficient iteration, prevents loading everything into RAM
tags: python, generators, memory, performance
category: perf
---

## Generator Expressions for Large Data

Use generator expressions (parentheses) instead of list comprehensions (brackets) for large datasets.

**Incorrect:**

```python
# Loads entire file into memory
total = sum([len(line) for line in large_file])

# Creates list of all results first
results = [expensive_operation(x) for x in huge_dataset]
```

**Correct:**

```python
# Processes one line at a time
total = sum(len(line) for line in large_file)

# Lazy evaluation: one item at a time
results = (expensive_operation(x) for x in huge_dataset)
for result in results:
    process(result)
```

**Benefits:**
- Constant memory usage
- Faster start time (lazy evaluation)
- Can process infinite streams
- More efficient for large datasets

**Applies to**: Large files, large datasets, streaming data
