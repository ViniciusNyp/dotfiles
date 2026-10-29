---
name: ship
description: "Use when the user says \"ship\" or \"ship it\", or asks in one go to build, live test, review, and open a draft PR. Takes settled work to a proven, reviewed draft PR and stops there."
---

# Ship

Own the work from its current state to a **draft PR** the user can mark ready. The user may not be watching: decide with sensible defaults and list each decision in the report.

A "ship" request is the user's explicit ask to branch, commit, push, and open the draft PR for this task, and the permission for the test methods Proof needs (simulator, device, running the app, screenshots), even where a project file says to ask first. Rules about *how* to test still apply.

## Stay local

Everything outside the task's own branch and draft PR stays a draft on disk: Slack and Plane messages, PR comments and replies, reviewer requests. The PR's reviewers stay empty; the user picks them. Merging, marking ready, and pushing to `dev`/`main` or to another branch belong to the user (or to `full-send`, which only the user invokes).

## Steps

1. **Build.** Bug → [`bugfix`](../bugfix/SKILL.md) in autonomous mode. Everything else → [`dev`](../dev/SKILL.md). The ship request is the plan approval: post the plan and continue. Work that isn't settled (dev Phase 3) stops here with the route to the skill that settles it. Branch off the latest base first if you're on it.
2. **Prove it.** See Proof. Every change in the diff has evidence before review starts.
3. **Review.** Run [`review-loop`](../review-loop/SKILL.md), committing each round. Re-prove behavior that review fixes touched.
4. **Open the draft PR.** Rebase onto the latest base, re-run checks. Then:
   - Title: the repo's convention (check AGENTS.md and recent merged PRs). Says why it matters, not what files changed.
   - Body: shaped by the `pr` skill, then `/unslop`. Open with the problem in the user's words, then the fix. One line on how it was proven. Nothing about review rounds, merge or deploy status.
   - `gh pr create --draft --base <base> --assignee @me --label <labels matching the change>`. Labels come from `gh label list`; pick the ones recent merged PRs of the same kind used.
5. **Watch CI.** In T3 Code, `watch_pull_request` and end the turn; elsewhere run `gh pr checks <n> --watch` under the Monitor tool. Fix real failures with proof, push, repeat. A flake gets one rerun and a note.
6. **Report.** First line: a question if one blocks you, else the PR link. Then: proof per change, review ledger summary, decisions made for the user, follow-ups, remaining risks. In T3 Code, `unwatch_pull_request` before reporting.

## Proof

Proof is evidence you observed in this session: command output, a reproduction, a screenshot. Green mocked tests do not prove a UI works.

- Bug: the original failure reproduced, then the same reproduction passing.
- The checks CI runs, scoped to what changed. The repo's AGENTS.md names them.
- One focused test that fails without the change, when the behavior has none.
- UI and runtime behavior: **live test**. Run the app on a simulator or device (T3 Code device tools, or the repo's e2e flows), exercise the changed flow and its neighbours for regressions, keep screenshots for the PR.

No way to prove a change means no full confidence: say so in the report's first line.

## Asking

Ask only when you cannot continue alone: you cannot prove a change, the goal is ambiguous in a way that changes the result, or the next step leaves the grant above. Put the question first in the final message with the PR link, the blocker, and options with your recommendation first. Decide everything else yourself.
