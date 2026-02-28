---
name: python-developer
description: Python development best practices - type safety, async patterns, testing, and Pythonic code for production-ready applications
user-invokable: true
---

# Python Developer

Production-ready Python development guidelines covering type safety, async patterns, testing, and Pythonic best practices. Contains 28 rules across 9 categories, prioritized by impact.

## When to Apply

Reference these guidelines when:
- Writing new Python packages or services
- Implementing async/await patterns
- Setting up Python project structure
- Writing tests for Python code
- Reviewing code for best practices
- Refactoring existing Python code

## Rule Categories by Priority

| Priority | Category | Impact | Prefix | Count |
|----------|----------|--------|--------|-------|
| 1 | Type Safety | CRITICAL | `type-` | 2 |
| 2 | Async Patterns | CRITICAL | `async-` | 3 |
| 3 | Error Handling | HIGH | `error-` | 2 |
| 4 | Testing | HIGH | `test-` | 3 |
| 5 | Code Style | MEDIUM | `style-` | 5 |
| 6 | Patterns | MEDIUM | `pattern-` | 6 |
| 7 | Performance | LOW | `perf-` | 2 |
| 8 | Documentation | LOW | `doc-` | 1 |
| 9 | Setup & Tooling | LOW | `setup-` | 4 |

## Quick Reference

### 1. Type Safety (CRITICAL)

- `type-hints-always` - Always use type hints on functions, enforce with mypy strict mode
- `type-immutability` - Use frozen dataclasses and Pydantic models to prevent mutation bugs

### 2. Async Patterns (CRITICAL)

- `async-io-patterns` - Use aiofiles and AsyncIterator for non-blocking I/O
- `async-cpu-threadpool` - Run CPU-bound operations in thread pool with asyncio.to_thread
- `async-concurrency` - Use asyncio.gather for concurrent I/O operations

### 3. Error Handling (HIGH)

- `error-exception-chaining` - Chain exceptions with `from err` to preserve context
- `error-guard-clauses` - Use early returns for error cases, keep happy path un-nested

### 4. Testing (HIGH)

- `test-organization` - Organize tests into unit/, integration/, fixtures/ directories
- `test-async-tests` - Use pytest.mark.asyncio for async function tests
- `test-mocking-strategy` - Mock only slow/expensive operations, use real components

### 5. Code Style (MEDIUM)

- `style-naming` - Follow PEP 8: snake_case functions, PascalCase classes, UPPER_SNAKE_CASE constants
- `style-import-organization` - Organize imports: stdlib, third-party, local
- `style-eafp-over-lbyl` - "Easier to Ask Forgiveness" - use try/except over pre-checks
- `style-dataclasses` - Use dataclasses instead of manual __init__ boilerplate
- `style-explicit-better` - Explicit types and behavior over implicit

### 6. Patterns (MEDIUM)

- `pattern-dependency-injection` - Pass dependencies through constructors
- `pattern-streaming-batching` - Process large datasets with AsyncIterator batching
- `pattern-context-managers` - Use context managers for automatic resource cleanup
- `pattern-list-comprehensions` - Use for simple transforms, explicit loops for complex logic
- `pattern-builtin-functions` - Prefer sum(), filter() over manual loops
- `pattern-no-mutable-defaults` - Use None instead of [] or {} as default arguments

### 7. Performance (LOW)

- `perf-generator-expressions` - Use generator expressions for memory-efficient iteration
- `perf-slots` - Use __slots__ for classes with many instances (>10k)

### 8. Documentation (LOW)

- `doc-google-style` - Use Google-style docstrings for public APIs

### 9. Setup & Tooling (LOW)

- `setup-uv-package-manager` - Use uv for faster dependency management (10-100x faster than pip)
- `setup-pyproject-toml` - Use pyproject.toml as single source of truth (PEP 621)
- `setup-virtual-env` - Always use virtual environments, never install globally
- `setup-tool-config` - Configure ruff/mypy/pytest in pyproject.toml

## Scalable Architecture

Structure adapts to project complexity while principles remain constant:

**Small (< 1K lines)**: Single module organization
```
app.py
models.py        # Domain models
repository.py    # Data access
service.py       # Business logic
```

**Medium (1K-10K lines)**: Package-based structure
```
src/
  package_name/
    __init__.py
    models.py       # Domain types
    repository.py   # Ports
    service.py      # Business logic
    postgres.py     # Adapters
    api.py          # HTTP handlers
tests/
  unit/
  integration/
```

**Large (10K+ lines)**: Full layer separation
```
src/
  package_name/
    domain/
      models.py
    application/
      service.py
    adapters/
      postgres_repo.py
      http_controller.py
    ports/
      repository.py
```

## Pragmatic Guidelines

**When to Use Type Hints?**

Always. Type hints are CRITICAL for:
- Static analysis (mypy)
- IDE support
- Documentation
- Preventing runtime errors

Use mypy strict mode for production code.

**When to Use Async?**

Use async/await when ANY apply:
- I/O-bound operations (API calls, database, files)
- Need concurrent operations
- Building web services/APIs
- Processing streams of data

Don't use async for:
- CPU-bound operations (use asyncio.to_thread instead)
- Simple scripts with no concurrency
- Synchronous libraries (wrap with asyncio.to_thread)

**When to Create Abstractions?**

Create interface/abstraction if ANY apply:
- Multiple implementations exist or likely will
- Need to test without external dependency
- Crossing architectural boundaries

Don't create for:
- Single implementation unlikely to change
- Internal helpers
- Simple utilities

Start simple, refactor when complexity demands it.

## How to Use

Reference individual rule files for detailed explanations and code examples:

**Type Safety (CRITICAL):**
- [Always Use Type Hints](rules/type-hints-always.md)
- [Frozen Dataclasses](rules/type-immutability.md)

**Async Patterns (CRITICAL):**
- [Async I/O Patterns](rules/async-io-patterns.md)
- [CPU-Bound in Thread Pool](rules/async-cpu-threadpool.md)
- [Async Concurrency](rules/async-concurrency.md)

**Error Handling (HIGH):**
- [Exception Chaining](rules/error-exception-chaining.md)
- [Guard Clauses](rules/error-guard-clauses.md)

**Testing (HIGH):**
- [Test Organization](rules/test-organization.md)
- [Async Tests](rules/test-async-tests.md)
- [Mocking Strategy](rules/test-mocking-strategy.md)

**Code Style (MEDIUM):**
- [Naming Conventions](rules/style-naming.md)
- [Import Organization](rules/style-import-organization.md)
- [EAFP over LBYL](rules/style-eafp-over-lbyl.md)
- [Use Dataclasses](rules/style-dataclasses.md)
- [Explicit is Better](rules/style-explicit-better.md)

**Patterns (MEDIUM):**
- [Dependency Injection](rules/pattern-dependency-injection.md)
- [Streaming with Batching](rules/pattern-streaming-batching.md)
- [Context Managers](rules/pattern-context-managers.md)
- [List Comprehensions](rules/pattern-list-comprehensions.md)
- [Built-in Functions](rules/pattern-builtin-functions.md)
- [No Mutable Defaults](rules/pattern-no-mutable-defaults.md)

**Performance (LOW):**
- [Generator Expressions](rules/perf-generator-expressions.md)
- [Use __slots__](rules/perf-slots.md)

**Documentation (LOW):**
- [Google-Style Docstrings](rules/doc-google-style.md)

**Setup & Tooling (LOW):**
- [Use uv Package Manager](rules/setup-uv-package-manager.md)
- [pyproject.toml](rules/setup-pyproject-toml.md)
- [Virtual Environments](rules/setup-virtual-env.md)
- [Tool Configuration](rules/setup-tool-config.md)

Each rule file contains:
- Why it matters explanation
- Incorrect code example with explanation
- Correct code example with explanation
- Benefits and additional context

## Full Compiled Document

For complete guide with all rules expanded: [REFERENCE.md](REFERENCE.md)

## Anti-Patterns to Avoid

**Blocking the Event Loop:**

```python
# ❌ BAD: Blocks event loop
async def process():
    with open('file.txt') as f:  # Blocking I/O
        data = f.read()
    result = expensive_cpu_work(data)  # Blocks other tasks
    return result

# ✅ GOOD: Non-blocking
async def process():
    async with aiofiles.open('file.txt') as f:  # Async I/O
        data = await f.read()
    result = await asyncio.to_thread(expensive_cpu_work, data)  # In thread
    return result
```

**Missing Type Hints:**

```python
# ❌ BAD: No type information
def process(data):
    return [x for x in data if x]

# ✅ GOOD: Clear types
def process(data: list[str]) -> list[str]:
    return [x for x in data if x]
```

**Mutable Default Arguments:**

```python
# ❌ BAD: Shared mutable default
def add_item(items: list[str] = []):
    items.append("new")
    return items

# ✅ GOOD: Safe default
def add_item(items: list[str] | None = None):
    if items is None:
        items = []
    items.append("new")
    return items
```

## Quick Checklist

Before submitting Python code:

**Type Safety**:
- [ ] All functions have type hints
- [ ] Mypy strict mode passes
- [ ] Domain models are frozen dataclasses/Pydantic

**Async Patterns**:
- [ ] I/O uses async libraries (aiofiles, httpx, etc.)
- [ ] CPU-bound work in thread pool (asyncio.to_thread)
- [ ] Concurrent operations use asyncio.gather

**Error Handling**:
- [ ] Exceptions chained with `from err`
- [ ] Guard clauses used (early returns)
- [ ] EAFP over LBYL

**Testing**:
- [ ] Tests organized (unit/, integration/)
- [ ] Async tests use pytest.mark.asyncio
- [ ] Minimal mocking (only external dependencies)

**Code Quality**:
- [ ] Imports organized (stdlib, third-party, local)
- [ ] Dataclasses used instead of manual __init__
- [ ] No mutable default arguments
- [ ] Built-in functions used (sum, filter, etc.)
- [ ] Context managers for resources

**Setup**:
- [ ] Virtual environment active
- [ ] Dependencies in pyproject.toml
- [ ] Using uv for package management
- [ ] Tools configured (ruff, mypy, pytest)
