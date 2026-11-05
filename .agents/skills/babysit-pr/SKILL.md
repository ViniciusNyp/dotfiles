---
name: babysit-pr
description: "Use when the user says \"babysit\", or asks to watch a PR through CI and review, or to act on a reviewer's comments. Fixes real findings with proof, answers threads, and re-requests review."
---

# Babysit PR

Carry a PR through CI, review bots, and human review. Adapted from [tstack babysit-pr](https://github.com/t3dotgg/tstack/blob/main/skills/babysit-pr/SKILL.md); `scripts/pr-wait` is tstack's, MIT.

The user's request authorizes commits and pushes to **this PR's own branch**, and re-requesting reviewers who already reviewed. Replies stay drafts ([`leaving-pr-comments`](../leaving-pr-comments/SKILL.md)) unless the request grants answering the reviewer ("feel free to answer"); then post them in the user's voice. Merging, marking ready, and adding new reviewers stay with the user.

## Act

Only on checks and comments newer than the latest push.

1. **Read** every new comment and failed check. Verify each finding at its source before touching code; reviewers, human or bot, are not always right.
2. **Fix** real findings and CI failures with [`review-loop`](../review-loop/SKILL.md)'s rules: smallest fix, prefer delete or narrow, proof per [ship's Proof](../ship/SKILL.md#proof). Tell a repo failure from an infra flake; a flake gets one rerun.
3. **Decline** the rest (unneeded tests, guards for cases that don't matter, extra compat, small perf) with a written reason, listed as follow-ups. Keep the PR at the size the goal needs.
4. **Re-review** what the fixes changed: `review since <last pushed sha>`.
5. **Push** each branch in its own `git push`; a multi-branch push can drop CI events, and a head with no runs reads as green. Confirm runs exist: `gh api repos/<o>/<r>/actions/runs -X GET -f head_sha=<sha>`.
6. **Reply** to each thread: what changed (commit link) or why not. Drafts go to the user. When posting is granted, post them as **one review per PR**, so the reviewer gets one notification, not one per reply (GraphQL):
   - thread ids: `pullRequest.reviewThreads { id comments(first:1) { databaseId } }`
   - `addPullRequestReview(pullRequestId)` → `addPullRequestReviewThreadReply(pullRequestReviewId, pullRequestReviewThreadId, body)` per thread → `submitPullRequestReview(event: COMMENT, body)`

   Leave threads unresolved; the reviewer resolves them.
7. **Re-request review** on every PR whose latest review is COMMENTED or CHANGES_REQUESTED and whose head changed: `gh api -X POST repos/<o>/<r>/pulls/<n>/requested_reviewers -f 'reviewers[]=<login>'`. A COMMENTED review drops the PR from the reviewer's queue until re-requested. Skip PRs APPROVED on an unchanged head.

## Wait

One watcher per PR, never a hand-rolled poll or `sleep` loop.

- **T3 Code:** handle what's already there, then `watch_pull_request` and end the turn. A wake is news, not a decision. Delegated child tasks never watch; the parent owns the PR. `unwatch_pull_request` before handing off or asking.
- **Elsewhere:** run `scripts/pr-wait <pr> --until green` (absolute path) under the Monitor tool, `timeout_ms: 3600000`. Use `--until ready` when the repo has Greptile or Macroscope. Exit 0: condition met. Exit 1: needs you (failed check, conflict, unresolved threads, closed). Restart it after each push or exit 1; it remembers what it reported. A second watcher on the same PR exits at once.

An event that needs no action ends the turn silently.

## Rate limits

`gh pr view/checks/create` use GraphQL. When it's spent, REST usually isn't: `gh api repos/<o>/<r>/pulls/<n>`, `gh api repos/<o>/<r>/commits/<sha>/check-runs`. Check with `gh api rate_limit --jq .resources.graphql`.

## Stop

Required checks green and every thread answered (fixed, or a reply drafted or posted) → report: commits pushed, findings fixed/declined with reasons, replies (drafted or posted), reviews re-requested, anything still waiting on a human.
