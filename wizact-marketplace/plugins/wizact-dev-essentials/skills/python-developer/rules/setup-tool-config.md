---
title: Tool Configuration in pyproject.toml
impact: LOW
impactDescription: Centralized configuration, consistent code quality
tags: python, ruff, mypy, pytest, configuration
category: setup
---

## Tool Configuration in pyproject.toml

Configure all tools in `pyproject.toml` for consistency.

**Example:**

```toml
[tool.ruff]
line-length = 100
target-version = "py310"

[tool.ruff.lint]
select = [
    "E",   # pycodestyle errors
    "W",   # pycodestyle warnings
    "F",   # pyflakes
    "I",   # isort
    "UP",  # pyupgrade
    "B",   # flake8-bugbear
    "SIM", # flake8-simplify
]

[tool.mypy]
python_version = "3.10"
strict = true
warn_return_any = true
disallow_untyped_defs = true

[tool.pytest.ini_options]
testpaths = ["tests"]
asyncio_mode = "auto"
addopts = "-v --cov=package_name"
```

**Usage:**

```bash
# Format code
uv run ruff format src/ tests/

# Lint
uv run ruff check src/ tests/

# Type check
uv run mypy src/

# Test
uv run pytest tests/ --cov=package_name
```

**Benefits:**
- All tool config in one place
- Consistent across team
- Version controlled
- Easy to update

**Applies to**: All Python projects
