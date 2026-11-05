---
name: council
description: "Use when the user says \"council\". Three Claude model families review or advise in parallel, scored, looping until all are satisfied. Heavier than review-loop; for risky or contested changes."
---

# Council

Three independent opinions from different Claude model families, read-only, in parallel. Adapted from [tstack council](https://github.com/t3dotgg/tstack/blob/main/skills/council/SKILL.md) for a Claude-only plan: diversity comes from model family, not vendor.

## Members

Default: **Opus**, **Fable**, **Sonnet**, the latest of each, at high effort. Members the user names, in the request or in AGENTS.md, win. A member that can't run gets reported, never swapped for another.

Launch all three **in one message** with the Agent tool: `subagent_type: Plan` (read-only), `model: opus | fable | sonnet`. Each starts with a fresh context, so the brief carries everything.

## Before the first round

Hand the council the current implementation, not a known-broken one: address open PR comments, fix known issues, run the covering checks. Skip fixes to code the user wants to replace.

## Brief

Code review → reuse [`review`](../review/SKILL.md)'s scope and brief (base, intent, out of scope, checks, blocker/should/nit), plus:

```
You are one of three independent reviewers. Read-only.
End with: SCORE: n/10 and VERDICT: APPROVE or CHANGES.
```

Anything else (a plan, a design, a decision) → the request, the relevant files, and "recommend, with reasons; flag what you'd need to see to change your mind."

## Each round

1. Collect the three replies. Summarize: findings two or more members share, disagreements (each side in one line), recommended next steps.
2. Answer findings with [`review-loop`](../review-loop/SKILL.md)'s rules: smallest fix, dispute with evidence, decline nits as follow-ups. Fight scope creep; three reviewers multiply it.
3. Changes made → a fresh round with the ledger and `since <sha>`. Each full pass is one round.

Stop when every member returns APPROVE, or after 3 rounds, or when an item stays disputed after two rounds. Report a deadlock with both sides; the user decides.

## Results

A member who gives no score gets `no score`, never an invented one. With an open PR, edit its description (no comment), placing this before the model/harness line:

```markdown
## Council review

Rounds: 2

| Member | Round 1 | Round 2 |
| --- | --- | --- |
| Claude Opus | 7/10 | 9/10 |
| Claude Fable | 8/10 | 10/10 |
| Claude Sonnet | 7/10 | 9/10 |
```

No PR → the same table in the final reply.
