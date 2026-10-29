---
name: review
description: "Code review, one round. Autonomous (default): the axes the diff earns run in parallel, a red-team audit drops what it can't verify, then a verdict. Pair: file-by-file walkthrough, comments posted only on approval. Use when: review, code review, review a PR/branch, review new changes only, or pair review. To review and fix until clean, use review-loop."
---

# Review

One review round. `review-loop` repeats it with fixes in between.

- **Autonomous (default).** Parallel reviewers, red-team audit, verdict.
- **Pair.** File-by-file walkthrough with a comment bag, posted on approval. Protocol in [PAIR.md](PAIR.md).

## Usage

- `/review [prompt|url|path]` reviews the change against that context
- `/review since <ref>` reviews only what changed after `<ref>` (a sha, `last`, or a PR's last reviewed commit)
- `/review pair [PR-ref]` enters pair mode

Context sources: prompt as-is; GitHub issue/PR via `gh issue view` / `gh pr view --json title,body`; Linear via `lineark issues read <id>`; a path, read it. No context: ask once, then review without a spec.

---

## 1. Scope

Run `git status --short`. Leave unrelated changes alone: no stash, no discard. If they mix with this change, limit the review to this change's paths; if the paths don't separate cleanly, ask.

Find the base after `git fetch origin`:

```bash
BASE_BRANCH=$(gh pr view --json baseRefName -q .baseRefName 2>/dev/null \
  || git symbolic-ref --short refs/remotes/origin/HEAD | sed 's|^origin/||')
BASE=$(git merge-base HEAD "origin/$BASE_BRANCH")
```

The change is `$BASE` to the working tree, untracked files included. With `since <ref>`, the **delta** is `<ref>` to the working tree; reviewers read the full change for context and report only on the delta. Use one diff command for the whole round. Nothing in scope: say so and stop.

Write the **brief**:

- Intent and out of scope, 1–2 sentences.
- Checks: run the ones covering this change (typecheck, lint, the touched tests). Record results, including checks that were already failing. Fix what this change broke before review starts.

## 2. Pick the axes

Run the axes the diff earns. Say which ran and why.

- `quality-reviewer`: every diff.
- `spec-reviewer`: when the context carries a spec. Otherwise skip it and say so.
- `security-reviewer`: **mandatory** when the diff touches auth, webhooks, tokens, permissions, or deletion.
- `performance-reviewer`: loops over unbounded input, queries, network calls, sizing constants.

A one-file change usually earns one axis.

## 3. Parallel review

Launch the axes **in one message**. Each gets:

```
Review only: read and run read-only commands. Leave edits, commits, pushes, PR comments, and subagents to the caller.
Axis: {axis}. Repo: {abs path}. Base: {sha}. {Delta: <ref>..working tree, report only on it.}
Intent: {intent} Out of scope: {scope} Checks: {results}
See: git diff {base}; git status --short (read untracked). Read CLAUDE.md, AGENTS.md, .claude/rules, and the code around the diff.
Find bugs, broken callers, mismatch with intent. Style only when it hides a bug. Skip what lint, formatter, or types enforce.
Hold to the smallest change: flag code, tests, or guards the intent doesn't need. Other paths, rare cases, small perf, extra compat: nits.
blocker = intended case wrong. should = real bug callers will hit, within intent. nit = the rest.
Every claim traces to code, a run, or a primary source for the installed version. Under 500 words, ranked.
Reply:
VERDICT: APPROVE or CHANGES
{AXIS-LETTER}1 [blocker|should|nit] file:line claim. Fix: smallest fix.
```

## 4. Red-team audit

Always runs. Finders propose, the auditor decides. Launch `review-auditor` with the brief and every axis report under its own heading:

> Verify each finding at its source. Drop false positives and claims no source backs. Recalibrate severity with the definitions above. Add blind spots as new findings.

## 5. Verdict

Synthesize yourself:

1. Drop what the auditor killed, apply its severities, add its blind spots.
2. Check each surviving blocker and should yourself. Another path, rare case, or small cost is a nit whatever its label.
3. Deduplicate by file:line. Give **stable ids** (`R1`, `R2`…) and tag the source: `[quality]` `[spec]` `[security]` `[performance]` `[audit]`.

```markdown
## Review: {branch} {(delta since <ref>)}

**Diff:** {files}, +{ins} -{del} · **Axes:** {which, why} + audit · **Checks:** {results}

### Blockers
- R1 [source] **title** `file:line`. {claim}. **Test (RED first):** {test}. **Fix:** {smallest fix}

### Should
### Nits

**VERDICT:** APPROVE (no blocker or should) | CHANGES
```

## 6. Next

- The user asked to act on findings, or a skill called review: hand the findings to `review-loop`.
- Otherwise stop at the verdict. Offer, in one line: write it to `docs/reviews/{branch}.md`, run `review-loop`, or switch to pair mode.

---

## Principles

- **Smallest change.** Prefer findings whose fix deletes or narrows code over ones that add a lock, cache, helper, or option.
- **Sourced findings only.** External facts trace to a primary source for the installed version. **Drift** (departing from the documented approach with nothing explaining why) is the shape worth hunting.
- **Spec stays separate from quality.** Code can follow every convention and still build the wrong thing.
- **Adversarial.** The audit kills weak findings rather than adding noise.
- In pair mode the user owns the comment bag. Post only what they dictate, in their words.
