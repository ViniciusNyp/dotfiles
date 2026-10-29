---
name: review-loop
description: "Use when the user says \"review loop\", \"review and act on all findings\", or \"review again\". Runs review, fixes, and re-reviews only the new changes until approved or the budget ends."
---

# Review loop

Make the change correct with the smallest possible diff. Each round is one [`review`](../review/SKILL.md) run. Push back on findings that grow scope.

## Budget

- 3 rounds. Round 1 reviews the full change. Later rounds run `review since <last round's sha>`, scoped to changed code and open ids.
- Extend to 5 only for security, auth, permissions, data loss, or state/concurrency, while a blocker or should stays open with evidence. Or when the user asks.
- Stop early when a round returns only nits. Declined nits and comment, doc, or format-only fixes need no new round.
- Budget end is not approval.

## Ledger

Keep one table across rounds. Every finding gets an outcome; "act on all findings" means every row is decided, not that every row is fixed.

| id | severity | outcome | evidence |
|---|---|---|---|
| R1 | blocker | fixed | `pnpm test foo` red → green |
| R2 | should | disputed | `api.ts:40` already guards null |
| R3 | nit | declined | follow-up: rename helper |

## Each round

1. **Review.** Run `review` (autonomous). Round 2+: pass `since <sha>` and the ledger; reviewers mark each old id `resolved` or `still open: <reason>`.
2. **Answer every finding.** Check it yourself first.
   - Agree: smallest fix. Prefer delete or narrow over a new lock, cache, helper, or option. Fix the case that happened. Add one focused test that fails without the fix when the intent needs it (`/tdd`, RED first).
   - Disagree: say why with evidence (file:line, test, output).
   - Nit or out of scope: decline in one line, list as follow-up.
3. **Re-check.** Re-run the covering checks and `git diff --shortstat $BASE`. If review grew the diff, cut first. Agreeing just to end the loop is a failure.
4. **Snapshot** the round so the next one has a `since` sha. Commit (`fix: address review R1, R4`) when commits are allowed, as under `ship`. Otherwise `git stash create` returns a sha of the working tree without touching it (it skips untracked files; list those in the next brief).

## Stop

- **Approved:** APPROVE on the current diff, no blocker or should open, no concern of your own.
- **Deadlock:** an item stays disputed after two rounds, or budget ends. Show both sides in 2–3 lines each. The user decides.

Leave pushing to the caller: push only when the user or a calling skill asked to push or update the PR.

Report: rounds run, verdict, diff size before/after, the ledger, follow-ups.
