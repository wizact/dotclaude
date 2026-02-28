---
title: Always Use Virtual Environments
impact: LOW
impactDescription: Isolated dependencies, reproducible builds, no conflicts
tags: python, virtual-environment, venv, setup
category: setup
---

## Always Use Virtual Environments

Projects MUST run in a virtual environment. Never install packages globally.

**Setup:**

```bash
# Create virtual environment
uv venv

# Activate (Unix/macOS)
source .venv/bin/activate

# Activate (Windows)
.venv\Scripts\activate

# Install dependencies
uv sync
```

**Run commands in venv:**

```bash
# Always use `uv run` to ensure venv is active
uv run pytest tests/
uv run mypy src/
uv run ruff check src/
```

**Benefits:**
- Isolated dependencies per project
- No version conflicts
- Reproducible builds
- Safe to delete and recreate
- Industry standard practice

**Applies to**: All Python projects without exception
