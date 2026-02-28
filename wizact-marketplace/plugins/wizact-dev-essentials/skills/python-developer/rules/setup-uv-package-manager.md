---
title: Use uv for Package Management
impact: LOW
impactDescription: 10-100x faster than pip, better dependency resolution
tags: python, uv, package-management, setup
category: setup
---

## Use uv for Package Management

Use `uv` for all dependency management - it's faster and more reliable than pip/poetry.

**Incorrect:**

```bash
# Using pip directly: slower, worse resolution
pip install requests
pip install -r requirements.txt
```

**Correct:**

```bash
# Using uv: fast and modern
uv sync                 # Install from lockfile
uv add requests         # Add dependency
uv add --dev pytest     # Add dev dependency
uv run pytest           # Run in venv
```

**Benefits:**
- 10-100x faster than pip
- Better dependency resolution
- Modern Python tooling standard
- Works with pyproject.toml
- Built-in virtual environment management

**Applies to**: All Python projects
