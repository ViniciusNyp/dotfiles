---
name: modernize
description: "Use when asked to rebase, update, or \"modernize\" an old or stacked PR. Decides whether the PR should still exist before rebasing it."
---

# Modernize

Modernize the idea, not just the branch: a clean rebase doesn't prove the PR still belongs. Adapted from [tstack modernize](https://github.com/t3dotgg/tstack/blob/main/skills/modernize/SKILL.md).

## Grant

Rebasing and updating this PR's branch with `--force-with-lease` against the head sha observed before the rebase. Merging, closing, changing the base, and widening scope stay with the user. Comments go through [`leaving-pr-comments`](../leaving-pr-comments/SKILL.md). Existing worktree changes are the user's: work in a disposable worktree when the current one is dirty or busy.

## 1. Intent

`git fetch origin`. Record the PR's URL, state, **actual base** (`gh pr view --json baseRefName`; stacked PRs often sit on another PR's branch, not `dev`), head sha, checks, review state. Read title, body, linked issues, commits, threads, full diff. State the smallest coherent goal the PR was after.

## 2. What moved around it

Read what landed on the base since the merge-base. Search merged and open PRs that touch the same paths or behavior. Ask:

- Was the same user problem already solved?
- Did APIs, types, schemas, or boundaries it relies on change?
- Was the code it changes deleted, moved, or simplified?
- Would landing it restore old behavior or create two ways to do one thing?
- Is the benefit still worth the maintenance?

"No conflicts" is not "current".

## 3. Disposition

- **MODERNIZE**: goal useful, shape right. Rebase, resolve, test, push.
- **REWORK**: goal useful, a mechanical rebase keeps the wrong shape. Describe the smallest credible rewrite and stop, unless the user asked for the rework (then hand it to [`ship`](../ship/SKILL.md)).
- **CLOSE**: superseded, obsolete, or not worth it. Cite evidence and stop. Age and sunk effort are not evidence either way.

## 4. Rebase (MODERNIZE)

1. Branch or worktree at the recorded head; rebase onto the fresh base.
2. Resolve each conflict by the PR's intent and the base's newer invariants. A conflict that's really a product or architecture disagreement sends you back to step 3.
3. `git range-diff` old vs new series, then read the final diff: nothing intended lost, nothing already-landed reintroduced.
4. Focused checks for the touched area; tell real failures from pre-existing ones.
5. Push with the lease. Lease fails → fetch and reassess, never overwrite.

## Report

Lead with the disposition and why. Then: what changed on the base, conceptual conflicts (or none), rebase/push result, checks, the remaining decision, PR link. Separate observed fact from judgment.
