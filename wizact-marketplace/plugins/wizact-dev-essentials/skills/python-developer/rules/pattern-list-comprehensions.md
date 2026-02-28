---
title: List Comprehensions
impact: MEDIUM
impactDescription: Cleaner code for simple transformations, but avoid complexity
tags: python, list-comprehension, readability, pythonic
category: pattern
---

## List Comprehensions

Use list comprehensions for simple transformations, explicit loops for complex logic.

**When to use comprehensions:**

```python
# ✅ Good: Clear and Pythonic
results = [transform(x) for x in items]
filtered = [x for x in items if x.is_valid()]
```

**When to use explicit loops:**

```python
# ✅ Good: Complex logic, needs explicit loop
results = []
for item in items:
    try:
        result = transform(item)
        if result.is_valid():
            results.append(result)
    except TransformError as err:
        logger.error(f"Failed to transform {item}: {err}")
        continue
```

**Avoid:**

```python
# ❌ Bad: Too complex, hard to read
results = [transform(x) for x in items if validate(x) and check(x) or fallback(x)]
```

**Guidelines:**
- Use comprehensions when logic is 1-2 lines
- Use explicit loops when you need error handling
- Use explicit loops when readability suffers

**Applies to**: Data transformations and filtering
