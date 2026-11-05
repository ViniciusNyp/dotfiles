---
name: takeover
description: "Use when the user asks to take over, continue, or finish someone else's PR, branch, or agent thread. Finishes the original goal and keeps the original contributors' credit."
---

# Takeover

Own the original goal from here, keep the original contributors' credit. Adapted from [tstack takeover](https://github.com/t3dotgg/tstack/blob/main/skills/takeover/SKILL.md).

## 1. Inherit

Read the source PR, branch, or thread: the code at its current head, uncommitted work, review findings, and the user's later corrections. The handoff is context, not proof. Defend nothing just because someone already built it.

## 2. Continue

- Replacement PR (default): branch from the original commits, add your fixes as separate commits.
- In-place or stacked continuation: only when the user asked for it. Leave the original PR and unrelated work untouched unless authorized.
- Bring it current with [`modernize`](../modernize/SKILL.md). Rework only what the same goal needs; simplify without dropping intended behavior. Recheck the source before filing; it may have moved.

## 3. Credit

Keep Git authorship and existing `Co-authored-by` trailers. Credit original contributors in the PR body and link the original PR. If it will be squashed, the squash keeps human co-author trailers with verified identities, never guessed emails. Model attribution doesn't replace contributor credit.

## 4. Finish

Run [`ship`](../ship/SKILL.md) from its Prove step: independently verify the original failure and realistic flows, review-loop, draft PR. Replies go through [`leaving-pr-comments`](../leaving-pr-comments/SKILL.md). Closing or merging the original PR stays with the user.

Report: what you inherited, what you changed, how you verified it, how credit was kept, the remaining decision.
