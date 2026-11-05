---
name: full-send
description: "Ship, then mark ready, babysit, and merge. Only when the user explicitly invokes /full-send."
disable-model-invocation: true
---

# Full send

Run [`ship`](../ship/SKILL.md) end to end, with these overrides. The user invoked this by hand, so they are not watching: stay active until merged or blocked.

## Extra grant

- Mark the PR ready for review so bots and required checks run.
- Force-push this PR's own branch with `--force-with-lease` after a rebase.
- Merge once the merge gate passes, with the method the repo uses (check allowed methods and recent merged PRs). Through branch protection as configured, never `--admin`.

Everything else in ship's "Stay local" still binds: no messages, no reviewer requests, no production changes, no other branches.

## Babysit

After ship's step 5, keep running [`babysit-pr`](../babysit-pr/SKILL.md) (`--until ready` when the repo has Greptile or Macroscope) until the merge gate passes. Dismissal reasons follow [`leaving-pr-comments`](../leaving-pr-comments/SKILL.md); posting them is part of this grant.

## Merge gate

All true on the latest commit:

- Proof covers every change in the diff.
- Required checks green.
- Review bots finished; each finding fixed or dismissed with a reason.
- No human review requesting changes, and required human approval given.
- Up to date with the base; GitHub reports it mergeable.

Gate passes → merge. Gate can't pass and you can't fix it → stop, unwatch, and lead the final message with the blocker. Report: PR link, merge commit, proof, decisions made for the user.
