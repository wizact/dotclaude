# speculator

Comprehensive specification builder that transforms GitHub issues and PRs into detailed, verifiable specs with requirements (EARS notation), design docs, and tracked tasks.

## Overview

8-phase spec workflow:

1. **spec-setup** - Create context-driven documentation structure (CLAUDE.md, constitution, templates)
2. **spec-context** - Parse GitHub issue/PR, gather project context
3. **spec-requirements** - Generate requirements.md with EARS notation
4. **spec-design** - Create design.md with architecture and components
5. **spec-tasks** - Build tasks.md with trackable work items
6. **spec-finalize** - Cross-link all documents, add metadata
7. **spec-verify** - Verify implementation against requirements
8. **specbuilder** (agent) - Orchestrates entire workflow end-to-end

## Workflow

```
GitHub URL → spec-context → spec-requirements → spec-design → spec-tasks → spec-finalize
                                                                                 ↓
                                                                         Implementation
                                                                                 ↓
                                                                           spec-verify
```

## Dependencies

### Required
- **gh CLI** - GitHub issue/PR parsing
- **git** - Commit signing (`-S` flag)

### Recommended
- **wizact-dev-essentials** - fd-search and ripgrep-search auto-invoke used by spec-context for codebase analysis

## Installation

Plugin auto-detected from wizact-marketplace. No manual installation needed.

## Usage

### Individual Skills

```bash
# Setup project documentation (optional, run once per project)
/spec-setup

# Parse GitHub issue/PR
/spec-context https://github.com/owner/repo/issues/123

# Generate requirements (after spec-context)
/spec-requirements

# Generate design (after spec-requirements)
/spec-design

# Generate tasks (after spec-design)
/spec-tasks

# Finalize spec package (after spec-tasks)
/spec-finalize

# Verify implementation (after implementation complete)
/spec-verify
```

### Agent Orchestration

Let specbuilder agent run the entire workflow:

```bash
# Provide GitHub URL - agent handles all phases
@specbuilder https://github.com/owner/repo/issues/123

# Or just mention URL in conversation
# Auto-invokes on GitHub URLs
```

## Auto-Invoke

**spec-context** auto-invokes when:
- GitHub issue/PR URLs mentioned in conversation
- User asks to "create spec from issue"

**specbuilder** agent auto-invokes when:
- GitHub URLs in requests for specs
- Keywords: "spec builder", "requirements doc", "EARS notation"

## Features

### EARS Notation
Requirements written in Event-driven Atomic Requirements Specification format:
- **Ubiquitous**: "The system SHALL..."
- **Event-driven**: "WHEN condition, the system SHALL..."
- **Unwanted behavior**: "IF condition, the system SHALL..."
- **State-driven**: "WHILE condition, the system SHALL..."
- **Optional**: "WHERE condition, the system SHALL..."

### Verification Support
- Requirement-to-task traceability
- Implementation verification checklist
- Automated completeness checking
- PR-ready workflow (tasks → branches → PRs)

### GitHub Integration
- Parses issue/PR bodies, comments, linked issues
- Extracts user stories, acceptance criteria
- Preserves original context and references

## Output Structure

```
specs/
├── context.md          # GitHub issue/PR context, project background
├── requirements.md     # User stories + EARS requirements
├── design.md          # Architecture, components, dependencies
└── tasks.md           # Work items with requirement cross-refs
```

## Examples

### Feature Spec
```bash
/spec-context https://github.com/acme/api/issues/42
# → Generates full spec: context → requirements → design → tasks
```

### Bug Fix Spec
```bash
@specbuilder https://github.com/acme/web/issues/108
# → Agent orchestrates: parses issue → requirements → fix design → test tasks
```

### Implementation Verification
```bash
# After implementing features from tasks.md
/spec-verify
# → Validates all requirements implemented, tasks complete
```

## Best Practices

1. **Start with context** - Always run spec-context first to gather project knowledge
2. **Sequential workflow** - Follow phase order (context → requirements → design → tasks)
3. **Iterative refinement** - Revise requirements/design before generating tasks
4. **Verification last** - Run spec-verify only after implementation complete
5. **Agent for full workflow** - Use specbuilder agent for complete automation

## Limitations

- Requires GitHub authentication (gh CLI configured)
- fd-search/ripgrep-search auto-invoke needs wizact-dev-essentials
- EARS notation learning curve for requirements review

## Support

Issues and contributions: https://github.com/wizact/dotclaude
