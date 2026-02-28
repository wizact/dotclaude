---
title: Google-Style Docstrings
impact: LOW
impactDescription: Consistent documentation, IDE support, auto-generated docs
tags: python, documentation, docstrings, google-style
category: doc
---

## Google-Style Docstrings

Use Google-style docstrings for public APIs. Focus on "why", not "what" the code obviously does.

**Example:**

```python
def transform(self, data: list[Item]) -> list[Result]:
    """Transform items into results.

    Applies business rules to convert raw items into processed results.
    Invalid items are logged and skipped.

    Args:
        data: Items to transform.

    Returns:
        List of transformation results. Empty list if all items invalid.

    Raises:
        TransformError: If transformation fails for valid items.
    """
    results = []
    for item in data:
        if not item.is_valid():
            logger.warning(f"Skipping invalid item: {item.id}")
            continue
        results.append(self._apply_rules(item))
    return results
```

**Guidelines:**
- Start with one-line summary
- Add details explaining "why" and edge cases
- Document Args, Returns, Raises
- Skip obvious docstrings
- Focus on public APIs

**Benefits:**
- IDE support (hover documentation)
- Auto-generated API docs
- Clear API contracts
- Easier onboarding

**Applies to**: Public functions, methods, and classes
