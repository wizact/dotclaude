---
title: Package Organization by Domain
impact: MEDIUM
impactDescription: Clear boundaries, better maintainability, logical structure
tags: code-organization, packages, structure, go
category: org
---

## Package Organization by Domain

Organize packages by domain/concern, not by type. Group related functionality together.

**Incorrect (organized by type):**

```
pkg/
  models/
    user.go
    task.go
    project.go
  handlers/
    user_handler.go
    task_handler.go
    project_handler.go
  services/
    user_service.go
    task_service.go
    project_service.go
  repositories/
    user_repository.go
    task_repository.go
    project_repository.go

// Everything scattered across packages
```

**Correct (organized by domain):**

```
pkg/
  user/
    user.go           # Domain model
    service.go        # Business logic
    repository.go     # Port
    handler.go        # HTTP adapter
  task/
    task.go
    service.go
    repository.go
    handler.go
  project/
    project.go
    service.go
    repository.go
    handler.go

// Related functionality grouped together
```

**Small project (<1K lines):**

```
main.go
task.go          # Domain models
repository.go    # Ports
postgres.go      # Adapters
handlers.go      # HTTP
```

**Medium project (1K-10K lines):**

```
cmd/server/main.go
pkg/
  task/
    task.go       # Domain
    repository.go # Port
    service.go
  postgres/
    task_repo.go  # Adapter
  http/
    handlers.go
```

**Large project (10K+ lines):**

```
internal/
  task/
    domain/
      task.go
    application/
      service.go
    adapters/
      postgres_repo.go
      http_controller.go
    ports/
      repository.go
  user/
    domain/
      user.go
    application/
      service.go
    adapters/
      postgres_repo.go
      http_controller.go
    ports/
      repository.go
```

**When to create a separate package:**

```go
// ✅ Can be used independently
pkg/email/      # Email sending (standalone)
pkg/auth/       # Authentication (standalone)

// ✅ Clear domain boundary
pkg/user/       # User domain
pkg/task/       # Task domain
pkg/billing/    # Billing domain

// ✅ More than 2-3 related files
pkg/notification/
  email.go
  sms.go
  push.go
  template.go

// ❌ Just one or two simple functions
pkg/helpers/
  format.go     # Just put in calling package

// ❌ Tightly coupled to another package
pkg/taskhelpers/  # Should be in task package
```

**Shared code:**

```
pkg/
  task/
    task.go
    service.go
  user/
    user.go
    service.go
  common/          # Shared utilities
    errors.go
    validation.go
  database/        # Shared infrastructure
    connection.go
```

**Benefits:**
- Related code together
- Clear boundaries
- Easy to find files
- Natural package evolution

**Applies to**: All package organization
