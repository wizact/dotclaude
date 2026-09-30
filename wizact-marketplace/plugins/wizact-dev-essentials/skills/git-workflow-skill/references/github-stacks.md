# GitHub Stacks

Use this reference for GitHub stacked pull requests, dependent pull requests, branch layers, and `gh stack` operations. GitHub Stacks is a public-preview feature, so treat `gh stack <command> --help` as authoritative for current flags and arguments.

## Required shape

A stack is a strictly linear chain in one repository:

```text
trunk <- foundation <- api <- ui
```

- The bottom pull request targets the trunk.
- Every higher pull request targets the branch immediately below it.
- Put each concern in the lowest layer that owns it; dependent work belongs above its prerequisites.
- Stacks cannot span forks or repositories. Use separate stacks for parallel branches.

## Preflight

Before changing a stack:

1. Inspect `git status --short --branch`, `file .git`, and `git worktree list --porcelain`.
2. Verify the working tree is clean before any command that checks out or rebases branches.
3. Check whether the extension is available with `gh stack --help`. If it is missing, explain that `github/gh-stack` is required and obtain permission before installing it.
4. Inspect an existing stack with `gh stack view --json`. Exit code 2 means the current branch is not in a locally tracked stack. Exit code 9 means stacked pull requests are unavailable for the repository; report that result rather than falling back silently.
5. If the repository has multiple remotes, identify the intended remote before any networked stack command. Do not guess.

## Choose the topology

### Regular single-checkout repository

Use full local tracking when the repository uses a regular checkout and no participating branch is checked out elsewhere:

```bash
gh stack init --base main foundation
git add <intended-paths>
git commit -S -m "feat: add foundation"
gh stack add api
git add <intended-paths>
git commit -S -m "feat: add API layer"
```

Pass branch names explicitly. Do not use `gh stack add -m`, `-A`, or `-u`; those convenience flags combine branch creation, staging, and committing and do not make the required signed-commit and scope review explicit.

After explicit authorization to push and create pull requests:

```bash
gh stack submit --auto
gh stack view --json
```

`submit --auto` creates draft pull requests by default. Add `--open` only when the user asks to mark them ready for review.

### Worktree-based repository or separately managed branches

Preserve the ordinary one-branch-per-worktree invariant. Do not use locally tracked stack navigation, `gh stack rebase`, or `gh stack sync` across separate worktrees.

Create and maintain the dependent branches in their registered worktrees. Verify each parent is an ancestor of its child before linking the stack. After explicit authorization to push branches and create or update pull requests, list branches from bottom to top:

```bash
gh stack link --base main foundation api ui
```

`link` pushes branch arguments, creates missing draft pull requests, corrects their base branches, and links them on GitHub. It creates no local stack tracking, so `up`, `down`, `top`, `bottom`, `rebase`, and `sync` are unavailable for that stack. Add `--open` only when ready-for-review pull requests were requested.

When a lower worktree branch changes, rebase each child onto its updated parent from the child's registered worktree, proceeding bottom to top. History rewriting and force-pushing published branches require explicit authorization. Re-run `gh stack link` only when the GitHub stack or pull-request bases need updating.

## Editing a locally tracked stack

Make a change on the layer that owns it, then cascade the update through the layers above it:

```bash
gh stack checkout <branch>
git add <intended-paths>
git commit -S -m "fix: correct lower layer"
gh stack rebase --upstack
gh stack top
gh stack push
```

Obtain authorization before the rebase because it rewrites commits, and before the push because it updates remote branches. Use `gh stack checkout <branch>` or explicit `up`, `down`, `top`, and `bottom` commands; do not use bare interactive selectors.

## Signing

- Create commits explicitly with `git commit -S`.
- Before a cascading rebase, verify that `git config --bool commit.gpgsign` is `true`; `gh stack rebase` relies on the local Git signing configuration when it recreates commits.
- After a rebase, inspect the rewritten stack range with `git log --show-signature` before pushing.
- Do not use GitHub's server-side **Rebase stack** action when signed commits are required because server-created rebased commits are unsigned.

## Non-interactive agent commands

Use explicit, non-interactive forms:

| Purpose | Use | Avoid |
| --- | --- | --- |
| Inspect | `gh stack view --json` | bare `gh stack view` |
| Initialize | `gh stack init --base <trunk> <branch>...` | bare `gh stack init` |
| Add a layer | `gh stack add <branch>` | bare `gh stack add` |
| Submit | `gh stack submit --auto` | bare `gh stack submit` |
| Navigate | `gh stack checkout <target>`, `gh stack up`, `gh stack down`, `gh stack top`, `gh stack bottom` | `gh stack switch` |
| Merge | `gh stack merge <target> --yes` | `gh pr merge` |

`gh stack modify` is TUI-only. Do not invoke it from an agent. Restructuring a stack can rewrite history and change GitHub stack membership, so stop and obtain a reviewed, explicit restructuring plan first.

## Authorization boundaries

The user's request to work on code does not authorize every stack operation:

- `init`, `add`, checkout, and navigation change local branch or metadata state; ensure the requested workflow covers them and the worktree is clean.
- `rebase` rewrites local history; obtain explicit authorization when commits already exist or are published.
- `push`, `submit`, `link`, `sync`, `merge`, and remote `unstack` update remote state; require explicit authorization.
- `sync` combines fetch, reconciliation, rebasing, pushing, and pull-request updates. Describe those effects before requesting authorization.
- Never use `sync --prune` unless the user explicitly authorizes deletion of merged local branches.
- Merge with `gh stack merge <pull-request-or-stack> --yes`. The target determines whether GitHub merges part or all of the stack.

## Recovery

- After a `gh stack rebase` conflict, resolve the reported files, stage only those resolutions, and run `gh stack rebase --continue`. Use `gh stack rebase --abort` to restore the stack.
- If `sync` reports divergence or `Sync aborted`, do not treat exit code 0 as proof that synchronization occurred. Inspect `gh stack view --json` and ask which side should be authoritative.
- Do not use `--force`; when rewritten branches must be pushed, preserve lease protection and stop on a rejection.
- Do not unstack, delete branches, remove worktrees, or prune without explicit authorization.

## Official references

- [About stacked pull requests](https://docs.github.com/en/pull-requests/get-started/about-stacked-prs)
- [Creating stacked pull requests](https://docs.github.com/en/pull-requests/how-tos/create-pull-requests/creating-stacked-pull-requests)
- [Managing stacked pull requests](https://docs.github.com/en/pull-requests/how-tos/create-pull-requests/managing-stacked-pull-requests)
- [Stacked pull requests reference](https://docs.github.com/en/pull-requests/reference/stacked-pull-requests)
- [GitHub's `gh-stack` agent skill](https://github.com/github/gh-stack/tree/main/skills/gh-stack)
