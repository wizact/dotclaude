---
title: Start with pyproject.toml
impact: LOW
impactDescription: Modern Python standard, single source of truth for project metadata
tags: python, pyproject, setup, pep621
category: setup
---

## Start with pyproject.toml

Use `pyproject.toml` as the single source of truth for project configuration (PEP 621).

**Benefits:**
- All metadata in one place
- No `setup.py` or `setup.cfg` needed
- Better tool integration
- Clear dependency declaration
- Modern Python standard

**Example:**

```toml
[project]
name = "my-package"
version = "0.1.0"
description = "Project description"
requires-python = ">=3.10"
dependencies = [
    "pydantic>=2.0.0",
]

[dependency-groups]  # Modern standard (PEP 735), works with uv
dev = [
    "pytest>=7.4.0",
    "mypy>=1.5.0",
    "ruff>=0.1.0",
]

[tool.ruff]
line-length = 100

[tool.mypy]
strict = true
```

**Applies to**: All Python projects
