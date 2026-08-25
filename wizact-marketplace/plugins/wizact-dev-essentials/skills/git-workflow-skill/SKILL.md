---
name: git-workflow-skill
description: Apply the repository's Git workflow when creating branches, isolating work with worktrees, preparing commits, or recovering from worktree state. Detect worktree-based and regular repositories before choosing a branching strategy.
user-invokable: true
---

# Git Workflow Guidelines

Apply the highest relevant practice level. Level 1 always applies. Add Level 2 when changing or committing code. Use Level 3 only for exceptional state or explicitly requested cleanup.

## Level 1: Required Invariants

### Detect repository topology before branch operations

Inspect the actual repository rather than assuming its layout:

```bash
file .git
git worktree list --porcelain
```

Treat the current checkout as part of a worktree-based layout when `.git` is a file containing a `gitdir:` pointer and `git worktree list` confirms the repository's registered worktrees. A regular checkout normally has a `.git` directory and only its current worktree registered.

### Isolate branches correctly

For a worktree-based repository:

- Each branch has a dedicated worktree.
- Never create or switch to another branch inside an existing worktree.
- If the target branch is already checked out, use its registered worktree.
- Create a new branch and worktree together:

  ```bash
  git worktree add -b feat/my-feature ../feat-my-feature <start-point>
  ```

- For an existing branch that is not checked out elsewhere:

  ```bash
  git worktree add ../feat-my-feature feat/my-feature
  ```

For a regular repository, use ordinary branching:

```bash
git switch -c feat/my-feature
```

### Preserve user work

- Inspect status before branch, worktree, staging, or commit operations.
- Do not overwrite, discard, stash, move, or mix unrelated changes.
- Do not remove a worktree or delete a branch unless the user explicitly asks.

## Level 2: Delivery Practices

Apply these when making a repository change:

- Infer the worktree location convention from `git worktree list`; do not assume every repository uses the same directory structure.
- By default, derive the worktree directory from the branch name by replacing `/` with `-`, for example `feat/user-auth` becomes `feat-user-auth`.
- Keep each change and commit focused on one logical outcome.
- Run relevant local validation before committing.
- Review the staged paths and diff before committing.
- Use Conventional Commits and describe the reason for the change.
- Sign every commit with the repository's configured key:

  ```bash
  git commit -S -m "feat: add new feature"
  ```

- Treat this skill as workflow guidance, not authorization to commit, push, create a pull request, or mutate remote state.

## Level 3: Recovery and Cleanup

Use this level only when Git reports exceptional worktree state or the user explicitly requests cleanup.

### Branch already checked out

Use `git worktree list --porcelain` to locate the existing worktree and continue there. Do not remove it merely to make the branch available elsewhere.

### Locked worktree

Inspect why it is locked and whether the path is still valid. Unlock only when the lock is stale or no longer needed and the requested task requires it:

```bash
git worktree unlock <path>
```

### Stale registration

Verify that the registered path is genuinely gone before pruning stale metadata:

```bash
git worktree prune
```

### Requested removal

Before removing a worktree, verify its exact path, branch, status, and whether its commits are retained elsewhere. Never remove the current worktree or use forced removal without explicit authorization.

## References

- [Git worktree documentation](https://git-scm.com/docs/git-worktree)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Signing commits](https://docs.github.com/en/authentication/managing-commit-signature-verification/signing-commits)
