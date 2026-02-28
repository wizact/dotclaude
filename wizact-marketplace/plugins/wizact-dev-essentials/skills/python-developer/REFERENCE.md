# Python Developer - Complete Reference

Complete guide to production-ready Python development. All rules expanded with full context.

**Generated from individual rule files** - Edit rules/*.md, then run compile-reference.sh

## Table of Contents
1. [Type Safety (CRITICAL)](#type-safety-critical)
2. [Async Patterns (CRITICAL)](#async-patterns-critical)
3. [Error Handling (HIGH)](#error-handling-high)
4. [Testing (HIGH)](#testing-high)
5. [Code Style (MEDIUM)](#code-style-medium)
6. [Patterns (MEDIUM)](#patterns-medium)
7. [Performance (LOW)](#performance-low)
8. [Documentation (LOW)](#documentation-low)
9. [Setup & Tooling (LOW)](#setup--tooling-low)

---


## Type Safety (CRITICAL)

### type-hints-always: Always Use Type Hints


## Always Use Type Hints

Type hints are essential for catching bugs early and enabling IDE support. Enforce with mypy strict mode.

**Incorrect:**

```python
# No type information
def process(data):
    pass

# Incomplete types
def fetch_items():
    return []
```

**Correct:**

```python
from typing import AsyncIterator

# Clear function contract
def process_items(self, items: list[Item]) -> list[Result]:
    pass

# Async iterators properly typed
async def fetch_data(self) -> AsyncIterator[Record]:
    pass
```

**Benefits:**
- Catch type errors before runtime
- Enable IDE autocomplete and refactoring
- Self-documenting code
- Required for production Python

**Applies to**: All functions, methods, and class attributes

---

### type-immutability: Use Frozen Dataclasses and Pydantic Models


## Use Frozen Dataclasses and Pydantic Models

Immutable data structures prevent bugs from unexpected mutations, especially in async/concurrent code.

**Incorrect:**

```python
# Mutable dataclass - can be changed after creation
@dataclass
class DomainModel:
    id: str
    name: str

# Mutable Pydantic model
class AppConfig(BaseModel):
    api_key: str
    timeout: int = 30
```

**Correct:**

```python
from dataclasses import dataclass
from pydantic import BaseModel, ConfigDict

# Frozen dataclass - immutable
@dataclass(frozen=True)
class DomainModel:
    id: str
    name: str

# Frozen Pydantic model
class AppConfig(BaseModel):
    model_config = ConfigDict(frozen=True)
    api_key: str
    timeout: int = 30
```

**Benefits:**
- Prevents accidental mutations
- Safe to share across threads/async tasks
- Hashable (can use as dict keys)
- Clear intent: this value doesn't change

**Applies to**: All domain models, configuration objects, and data transfer objects

---


## Async Patterns (CRITICAL)

### async-concurrency: Async Concurrency with asyncio.gather


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

---

### async-cpu-threadpool: CPU-Bound Operations in Thread Pool


## CPU-Bound Operations in Thread Pool

Run blocking/CPU-intensive operations in thread pool to avoid blocking the event loop.

**Incorrect:**

```python
# Blocks event loop during CPU-intensive work
async def process_data(data: bytes) -> Result:
    # CPU-intensive: blocking all other tasks
    return expensive_computation(data)
```

**Correct:**

```python
import asyncio

# Run blocking operations in thread pool
async def process_data(data: bytes) -> Result:
    result = await asyncio.to_thread(
        expensive_computation,
        data
    )
    return result
```

**Benefits:**
- Event loop stays responsive
- Other async tasks can run concurrently
- Simple API for mixed sync/async code
- No need to rewrite sync libraries

**Applies to**: CPU-intensive operations, synchronous library calls, blocking operations in async code

---

### async-io-patterns: Async I/O Patterns


## Async I/O Patterns

Use async libraries for I/O operations to avoid blocking the event loop.

**Incorrect:**

```python
# Blocks event loop
def read_file(path: Path) -> list[str]:
    with open(path, 'r') as f:
        return [line.strip() for line in f]
```

**Correct:**

```python
import aiofiles
from pathlib import Path
from typing import AsyncIterator

# Non-blocking async file reading
async def read_file(path: Path) -> AsyncIterator[str]:
    async with aiofiles.open(path, 'r') as f:
        async for line in f:
            yield line.strip()
```

**Benefits:**
- Keeps event loop responsive
- Enables concurrent I/O operations
- Scales to handle multiple files simultaneously
- Industry standard for async Python

**Applies to**: All file I/O, network I/O, and database operations in async code

---


## Error Handling (HIGH)

### error-exception-chaining: Exception Chaining


## Exception Chaining

Always chain exceptions using `from err` to preserve the original error context.

**Incorrect:**

```python
# Loses original error context
try:
    data = json.loads(line)
except json.JSONDecodeError:
    raise ValidationError("Invalid JSON")  # Original error lost
```

**Correct:**

```python
# Preserves full error chain
try:
    data = json.loads(line)
except json.JSONDecodeError as err:
    raise ValidationError(f"Invalid JSON at line {n}") from err
    # Full stack trace preserved, original error accessible
```

**Benefits:**
- Complete error context for debugging
- Stack traces show full error chain
- Easier to diagnose root causes
- Python best practice (PEP 3134)

**Applies to**: All exception re-raising and wrapping

---

### error-guard-clauses: Guard Clauses


## Guard Clauses

Use early returns to handle error cases, keeping the happy path un-nested.

**Incorrect:**

```python
# Nested if/else creates cognitive load
def process(item: Item) -> Result:
    if item.is_valid():
        return self._transform(item)
    else:
        raise ValueError("Invalid item")
```

**Correct:**

```python
# Guard clause: fail fast, happy path clear
def process(item: Item) -> Result:
    if not item.is_valid():
        raise ValueError("Invalid item")

    # Happy path without nesting
    return self._transform(item)
```

**Benefits:**
- Reduces nesting levels
- Happy path is obvious
- Error conditions explicit
- Easier to read and maintain

**Applies to**: All functions with validation or error conditions

---


## Testing (HIGH)

### test-async-tests: Async Tests


## Async Tests

Use pytest-asyncio for testing async functions.

**Incorrect:**

```python
# Doesn't properly await async functions
def test_async_operation():
    result = async_function()  # Returns coroutine, not result
    assert result is not None
```

**Correct:**

```python
import pytest

# Properly awaits async functions
@pytest.mark.asyncio
async def test_async_operation():
    result = await async_function()
    assert result is not None

# Multiple async operations
@pytest.mark.asyncio
async def test_multiple_operations():
    result1 = await async_op1()
    result2 = await async_op2()
    assert result1 != result2
```

Configure pytest:
```toml
[tool.pytest.ini_options]
asyncio_mode = "auto"  # Auto-detect async tests
```

**Benefits:**
- Properly tests async code
- Catches async-specific bugs
- Works with asyncio event loop
- Standard pytest integration

**Applies to**: All tests for async functions

---

### test-mocking-strategy: Mocking Strategy


## Mocking Strategy

Mock only slow or expensive operations. Use real components where possible.

**Incorrect:**

```python
# Over-mocking: testing mocks, not real code
@patch('module.Service')
@patch('module.Repository')
@patch('module.Validator')
async def test_with_mocks(mock_val, mock_repo, mock_svc):
    # Testing mock behavior, not real code
    pass
```

**Correct:**

```python
from unittest.mock import patch, Mock

# Mock only external dependencies
@patch('module.ExternalService')
async def test_with_minimal_mock(mock_external):
    # Use real Service, Repository, Validator
    # Mock only slow/expensive external API
    mock_external.return_value = {"status": "ok"}

    result = await service.process()
    assert result.is_valid()
```

**Benefits:**
- Tests real code behavior
- Catches integration issues
- Faster to write and maintain
- More confidence in tests

**Applies to**: Mock external APIs, databases, file systems, network calls - not internal logic

---

### test-organization: Test Organization


## Test Organization

Organize tests by speed and dependency requirements.

**Incorrect:**

```
tests/
  test_everything.py  # Mixed fast/slow tests
  test_stuff.py
```

**Correct:**

```
tests/
├── unit/           # Fast, mocked dependencies
│   ├── test_service.py
│   └── test_models.py
├── integration/    # Real components, slower
│   ├── test_database.py
│   └── test_api.py
└── fixtures/       # Shared test data
    └── sample_data.json
```

**Benefits:**
- Run fast unit tests during development
- Integration tests for CI/CD
- Clear test boundaries
- Easy to parallelize

**Applies to**: All Python projects with tests

---


## Code Style (MEDIUM)

### style-dataclasses: Use Dataclasses


## Use Dataclasses

Use dataclasses instead of manual __init__ and boilerplate methods.

**Incorrect:**

```python
# Manual boilerplate: verbose, error-prone
class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __repr__(self):
        return f"Point({self.x}, {self.y})"

    def __eq__(self, other):
        return self.x == other.x and self.y == other.y

    # ... more boilerplate
```

**Correct:**

```python
from dataclasses import dataclass

# Clean, concise, automatic methods
@dataclass(frozen=True)
class Point:
    x: float
    y: float
    # __init__, __repr__, __eq__ auto-generated
```

**Benefits:**
- Less boilerplate code
- Automatic __repr__, __eq__, __hash__
- Type hints enforced
- Immutability with frozen=True
- Standard Python (PEP 557)

**Applies to**: All data-holding classes

---

### style-eafp-over-lbyl: EAFP over LBYL


## EAFP over LBYL

"Easier to Ask Forgiveness than Permission" - use try/except instead of pre-checking.

**Incorrect (LBYL - Look Before You Leap):**

```python
# Check before action: slower, race conditions possible
if 'key' in data:
    return data['key']
else:
    return default

if os.path.exists(filepath):
    with open(filepath) as f:
        return f.read()
```

**Correct (EAFP - Easier to Ask Forgiveness than Permission):**

```python
# Try first, handle exceptions: faster, atomic
try:
    return data['key']
except KeyError:
    return default

try:
    with open(filepath) as f:
        return f.read()
except FileNotFoundError:
    return default
```

**Benefits:**
- Faster in the happy path (no double check)
- Atomic operations (no race conditions)
- More Pythonic style
- Handles edge cases naturally

**Applies to**: Dictionary access, file operations, attribute access

---

### style-explicit-better: Explicit is Better than Implicit


## Explicit is Better than Implicit

Make types and behavior explicit for clarity and tooling support.

**Incorrect:**

```python
# Unclear types and behavior
def read_file(p):
    with open(p) as f:
        return f.read()

def process(data):
    return [x for x in data if x]
```

**Correct:**

```python
from pathlib import Path

# Clear types and intent
def read_file(path: Path) -> str:
    """Read file contents as string."""
    with path.open() as f:
        return f.read()

def process(data: list[str]) -> list[str]:
    """Filter out empty strings."""
    return [x for x in data if x]
```

**Benefits:**
- IDE autocomplete and type checking
- Self-documenting code
- Catches bugs at development time
- Easier to refactor

**Applies to**: All functions, especially public APIs

---

### style-import-organization: Import Organization


## Import Organization

Organize imports in three groups: stdlib, third-party, local.

**Incorrect:**

```python
# Mixed import order, hard to read
from package_name.domain import models
import httpx
from pathlib import Path
import asyncio
from pydantic import BaseModel
```

**Correct:**

```python
# 1. Standard library
import asyncio
from pathlib import Path

# 2. Third-party packages
import httpx
from pydantic import BaseModel

# 3. Local imports
from package_name.domain import models
```

Use `ruff format` for automatic import sorting.

**Benefits:**
- Clear dependency boundaries
- Easier to spot missing dependencies
- Prevents circular imports
- Standard Python practice (PEP 8)

**Applies to**: All Python modules

---

### style-naming: Naming Conventions


## Naming Conventions

Follow PEP 8 naming conventions consistently.

**Naming Rules:**
- **Modules/Packages**: `lowercase_with_underscores`
- **Classes**: `PascalCase`
- **Functions/Variables**: `snake_case`
- **Constants**: `UPPER_SNAKE_CASE`
- **Private**: `_leading_underscore`

**Examples:**

```python
# Module: user_service.py
MAX_RETRY_COUNT = 3  # Constant

class UserService:  # Class: PascalCase
    def __init__(self):
        self._cache = {}  # Private: leading underscore

    def fetch_user(self, user_id: str) -> User:  # Function: snake_case
        retry_count = 0  # Variable: snake_case
        return user
```

**Benefits:**
- Immediate recognition of identifier type
- Follows Python community standards
- Better IDE support
- Easier code review

**Applies to**: All Python code

---


## Patterns (MEDIUM)

### pattern-builtin-functions: Use Built-in Functions


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

---

### pattern-context-managers: Context Managers


## Context Managers

Use context managers for automatic resource cleanup.

**Incorrect:**

```python
# Manual cleanup: easy to forget, error-prone
f = open(path, 'r')
content = f.read()
f.close()  # Might not execute if error occurs
```

**Correct:**

```python
# Automatic cleanup: guaranteed even with exceptions
with open(path, 'r') as f:
    content = f.read()
# File automatically closed

# Async context managers
async with aiofiles.open(path, 'r') as f:
    content = await f.read()

# Custom resource management
with resource_manager() as resource:
    resource.process()
```

**Benefits:**
- Guaranteed cleanup even on exceptions
- Clear resource lifetime
- Pythonic resource management
- Prevents resource leaks

**Applies to**: File operations, network connections, locks, database transactions

---

### pattern-dependency-injection: Dependency Injection


## Dependency Injection

Pass dependencies through constructors instead of creating them internally.

**Incorrect:**

```python
# Hard-coded dependencies: untestable
class Service:
    def __init__(self):
        self.repository = PostgresRepository()  # Hard-coded
        self.cache = RedisCache()  # Hard-coded
```

**Correct:**

```python
# Dependencies injected: testable and flexible
class Service:
    def __init__(
        self,
        repository: Repository,
        cache: Cache,
    ):
        self.repository = repository
        self.cache = cache

# Easy to test with mocks
service = Service(
    repository=MockRepository(),
    cache=InMemoryCache(),
)
```

**Benefits:**
- Easy to test with mocks
- Swap implementations without code changes
- Clear dependency requirements
- Supports dependency inversion principle

**Applies to**: All service classes with external dependencies

---

### pattern-list-comprehensions: List Comprehensions


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

---

### pattern-no-mutable-defaults: Avoid Mutable Default Arguments


## Avoid Mutable Default Arguments

Never use mutable objects (list, dict) as default arguments.

**Incorrect:**

```python
# Dangerous: default list is shared across all calls
def process(items: list[str] = []) -> list[str]:
    items.append("new")
    return items

# Bug: each call mutates the same list!
result1 = process()  # ["new"]
result2 = process()  # ["new", "new"]  # Unexpected!
```

**Correct:**

```python
# Safe: new list created for each call
def process(items: list[str] | None = None) -> list[str]:
    if items is None:
        items = []
    items.append("new")
    return items

# Works correctly
result1 = process()  # ["new"]
result2 = process()  # ["new"]  # Correct!
```

**Why it happens:**
Default arguments are evaluated once at function definition, not at each call.

**Benefits:**
- No shared state bugs
- Predictable behavior
- Avoids classic Python gotcha

**Applies to**: All functions with list, dict, or other mutable defaults

---

### pattern-streaming-batching: Streaming with Batching


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

---


## Performance (LOW)

### perf-generator-expressions: Generator Expressions for Large Data


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

---

### perf-slots: Use __slots__ for Many Instances


## Use __slots__ for Many Instances

Use `__slots__` or dataclass `slots=True` when creating many instances of a class.

**When to use:**

```python
from dataclasses import dataclass

# Creating millions of instances: use slots
@dataclass(frozen=True, slots=True)
class Record:
    """Slots reduce memory overhead by ~40%."""
    id: str
    data: str
    timestamp: int

# Load millions of records
records = [Record(...) for _ in range(1_000_000)]
# Saves ~40% memory compared to without slots
```

**When NOT to use:**

```python
# Regular class with few instances: no need for slots
@dataclass(frozen=True)
class AppConfig:
    api_key: str
    timeout: int
    # Only 1 instance, slots add complexity without benefit
```

**Benefits:**
- ~40% memory reduction per instance
- Faster attribute access
- Prevents accidental attribute assignment

**Trade-offs:**
- Can't add attributes dynamically
- Slightly more complex
- Only worth it for many instances (>10,000)

**Applies to**: Classes with many instances (records, data points, events)

---


## Documentation (LOW)

### doc-google-style: Google-Style Docstrings


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

---


## Setup & Tooling (LOW)

### setup-pyproject-toml: Start with pyproject.toml


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

---

### setup-tool-config: Tool Configuration in pyproject.toml


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

---

### setup-uv-package-manager: Use uv for Package Management


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

---

### setup-virtual-env: Always Use Virtual Environments


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

---

