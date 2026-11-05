---
name: babysit-pr
description: "Use when the user says \"babysit\", or asks to watch a PR through CI and review, or to act on a reviewer's comments. Fixes real findings with proof and drafts the replies."
---

# Babysit PR

Carry a PR through CI, review bots, and human review. Adapted from [tstack babysit-pr](https://github.com/t3dotgg/tstack/blob/main/skills/babysit-pr/SKILL.md); `scripts/pr-wait` is tstack's, MIT.

The user's request authorizes commits and pushes to **this PR's own branch**. Replies stay drafts ([`leaving-pr-comments`](../leaving-pr-comments/SKILL.md)). Merging, marking ready, and reviewer requests stay with the user.

## Act

Only on checks and comments newer than the latest push.

1. **Read** every new comment and failed check. Verify each finding at its source before touching code; reviewers, human or bot, are not always right.
2. **Fix** real findings and CI failures with [`review-loop`](../review-loop/SKILL.md)'s rules: smallest fix, prefer delete or narrow, proof per [ship's Proof](../ship/SKILL.md#proof). Tell a repo failure from an infra flake; a flake gets one rerun.
3. **Decline** the rest (unneeded tests, guards for cases that don't matter, extra compat, small perf) with a written reason, listed as follow-ups. Keep the PR at the size the goal needs.
4. **Re-review** what the fixes changed: `review since <last pushed sha>`.
5. **Push**, then draft one reply per thread: what changed (commit link) or why not. Hand the drafts to the user.

## Wait

One watcher per PR, never a hand-rolled poll or `sleep` loop.

- **T3 Code:** handle what's already there, then `watch_pull_request` and end the turn. A wake is news, not a decision. Delegated child tasks never watch; the parent owns the PR. `unwatch_pull_request` before handing off or asking.
- **Elsewhere:** run `scripts/pr-wait <pr> --until green` (absolute path) under the Monitor tool, `timeout_ms: 3600000`. Use `--until ready` when the repo has Greptile or Macroscope. Exit 0: condition met. Exit 1: needs you (failed check, conflict, unresolved threads, closed). Restart it after each push or exit 1; it remembers what it reported. A second watcher on the same PR exits at once.

An event that needs no action ends the turn silently.

## Rate limits

`gh pr view/checks/create` use GraphQL. When it's spent, REST usually isn't: `gh api repos/<o>/<r>/pulls/<n>`, `gh api repos/<o>/<r>/commits/<sha>/check-runs`. Check with `gh api rate_limit --jq .resources.graphql`.

## Stop

Required checks green and every thread answered (fixed, or a drafted reply) → report: commits pushed, findings fixed/declined with reasons, reply drafts, anything still waiting on a human.
