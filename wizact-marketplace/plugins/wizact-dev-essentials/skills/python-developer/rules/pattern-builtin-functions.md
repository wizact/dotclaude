---
title: Use Built-in Functions
impact: MEDIUM
impactDescription: Faster, more readable, idiomatic Python
tags: python, builtins, pythonic, performance
category: pattern
---

## Use Built-in Functions

Prefer built-in functions over manual loops.

**Incorrect:**

```python
# Manual loops: verbose, slower
found = False
for x in collection:
    if x == item:
        found = True
        break

total = 0
for v in values:
    total += v

filtered = []
for x in data:
    if predicate(x):
        filtered.append(x)
```

**Correct:**

```python
# Built-ins: clear, fast, Pythonic
found = item in collection

total = sum(values)

filtered = list(filter(predicate, data))
# Or use comprehension for simple cases
filtered = [x for x in data if predicate(x)]
```

**Common built-ins:**
- `sum()`, `min()`, `max()`, `any()`, `all()`
- `filter()`, `map()`, `zip()`
- `sorted()`, `reversed()`
- `enumerate()`, `range()`

**Benefits:**
- Faster (C implementation)
- More readable
- Less code to maintain
- Idiomatic Python

**Applies to**: Common operations like searching, summing, filtering
