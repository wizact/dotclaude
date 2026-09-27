---
title: Go Naming Conventions
impact: IMPORTANT
impactDescription: Consistent names make Go applications predictable, readable, and idiomatic
tags: naming, files, packages, identifiers, go
category: naming
---

## Go Naming Conventions

Use consistent names across the application. Capitalization communicates whether a Go identifier is exported, while concise names and predictable file placement make code easier to navigate.

### Files and directories

Project-owned file and directory names must use only lowercase letters and numbers. Join multiple words without delimiters: do not use hyphens or underscores.

The only filename delimiter exception is the required `_test.go` suffix for Go test files.

| Good | Bad |
|------|-----|
| `actorevent.go` | `actor_event.go` |
| `actorevent.go` | `actor-event.go` |
| `actorevent_test.go` | `actor_event_test.go` |
| `actorevent/` | `actor_event/` |
| `oauth2/` | `oauth-2/` |

Keep package names aligned with their directories: concise, lowercase, and unbroken. Prefer a meaningful domain name such as `actorevent` over generic names such as `util`, `common`, or `helpers`.

External test packages may use Go's required `_test` package suffix, for example `package actorevent_test`.

### Identifiers

Use `MixedCaps` or `mixedCaps` for multiword Go identifiers. Do not use snake case or hyphens.

- Exported identifiers start with an uppercase letter: `ActorEvent`, `NewActorEvent`, `MaxRetryCount`.
- Unexported identifiers and local variables start with a lowercase letter: `actorEvent`, `newActorEvent`, `maxRetryCount`.
- Preserve common initialisms: `ID`, `HTTP`, `URL`, and `JSON`; use `actorID`, `httpClient`, and `jsonData`, not `actorId`, `httpclient`, or `json_data`.
- Prefer whole words; use abbreviations only when they are established and unambiguous.
- Choose variable-name length according to scope. Short idiomatic names such as `ctx`, `db`, `i`, and `err` are appropriate when their meaning is clear.
- Keep receiver names to one or two lowercase letters derived from the type, and use the same receiver name for every method on that type: `func (e *Event) Save()`.

Test, benchmark, and example function names may use underscores to separate the subject, method, and scenario, for example `TestActorEvent_Create`.

### Constants

Name constants by their role and use the same MixedCaps rules as other identifiers.

```go
const MaxRetryCount = 3
const defaultTimeout = 30 * time.Second
```

Do not use screaming snake case or a `K` prefix:

```go
// Bad
const MAX_RETRY_COUNT = 3
const kDefaultTimeout = 30 * time.Second
```

### Structs and other types

Use concise noun or role names. Apply normal exportedness rules and avoid repeating context already supplied by the package.

```go
package actorevent

type Event struct {
    ActorID string
}

type validationError struct {
    Field string
}
```

Prefer `actorevent.Event` over `actorevent.ActorEvent`, and do not add suffixes such as `Struct` or `Type` merely to describe the declaration kind.

### Interfaces

Name interfaces for the behavior or role they describe. Do not add an `I` prefix or an `Interface` suffix.

- Name a one-method interface after its method with an `-er` form when it reads naturally: `Reader`, `Writer`, `Validator`.
- Name a focused multi-method interface for its role: `TaskRepository`.
- Keep internal-only interfaces unexported: `validator`.

### Functions and methods

Use noun-like names for functions that return a value and verb-like names for actions. Avoid redundant package, receiver, parameter, and return-type words.

- Prefer `Name()` over `GetName()`.
- Use `Fetch` or `Compute` when a call may block, fail, or perform substantial work.
- Use conventional constructor and option names such as `New`, `NewServer`, `DefaultConfig`, and `WithTimeout`.
- Prefer `actorevent.New()` over `actorevent.NewActorEvent()` when the package already supplies the missing context.

### Errors and tests

- Prefix exported sentinel errors with `Err`: `ErrActorNotFound`.
- Suffix concrete error types with `Error`: `ValidationError`.
- Use `err` for ordinary local errors and descriptive MixedCaps names such as `wantErr` when multiple error values are in scope.
- Give table-driven test cases descriptive, readable names rather than numeric indexes.

## Checklist

- [ ] Project-owned file and directory names are lowercase and delimiter-free, except for `_test.go`
- [ ] Package names are concise, lowercase, and aligned with their directories
- [ ] Exported identifiers use `MixedCaps`; unexported identifiers use `mixedCaps`
- [ ] Initialisms retain their standard capitalization
- [ ] Constants use MixedCaps rather than screaming snake case
- [ ] Struct, interface, function, and method names describe their role without redundant context
- [ ] Sentinel errors use `Err...`, and concrete error types use `...Error`
