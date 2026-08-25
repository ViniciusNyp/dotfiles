---
name: review
description: "Code review in 2 modes. Autonomous (default): the review axes the diff earns, run in parallel, then a red-team audit that drops what it can't verify, then a verdict. Pair: file-by-file walkthrough, comments posted only on approval. Use when: review, code review, review a PR/branch, or pair review."
---

# Review

Two-mode code review.

- **Default (autonomous).** Parallel specialized reviewers, a red-team audit, then a verdict.
- **Pair mode.** File-by-file walkthrough with a comment bag, posted on approval.

## Usage

- `/review` asks what to review, default autonomous
- `/review <prompt|url|path>` reviews current changes against the given context, autonomous
- `/review pair <PR-ref>` enters pair mode on a PR
- `/review pair` asks for a PR reference, then enters pair mode

## Parse input

- **Prompt.** Use it as `{review_context}` directly.
- **URL.**
    - GitHub issue: `gh issue view <number> --json title,body --jq '.title + "\n\n" + .body'`
    - GitHub PR: `gh pr view <number> --json title,body --jq '.title + "\n\n" + .body'`
    - Linear: `lineark issues read <identifier>`
- **File path.** Read the file.
- **No args.** Ask "What should I review? Describe it, paste an issue URL, or point me to a spec."

---

## Autonomous mode (default)

### Phase 1: Diff

```bash
git diff main...HEAD
git diff main...HEAD --stat
```

If empty, try `git diff HEAD~1`. If still empty, say there is nothing to review and stop. Store as `{diff}` and `{diff_stat}`.

### Phase 2: Pick the axes

The diff already names where to look, so reviewers read the repo themselves rather than waiting on a scouting pass.

Run the axes the diff earns, never all of them by habit:

- `quality-reviewer` runs on every diff.
- `spec-reviewer` runs whenever `{review_context}` carries a spec. Without one, skip it and say so in the report.
- `security-reviewer` is **mandatory** when the diff touches auth, webhooks, tokens, permissions, or deletion. Optional elsewhere.
- `performance-reviewer` runs when the diff adds loops over unbounded input, queries, network calls, or sizing constants.

A one-file change usually earns one axis. Say which axes you ran and why in the report.

### Phase 3: Parallel review

Launch the chosen agents **in a single message** so they run concurrently. Each prompt takes the shape:

> Review this PR for {axis}.
>
> Read the repo for conventions: `CLAUDE.md`, `AGENTS.md`, `.claude/rules`, and the files around the diff.
>
> Findings must be **ranked, and under 500 words.** Space is scarce on purpose. Spend it on what would change the author's mind rather than on everything you noticed.
>
> ## Review Context
> {review_context}
>
> ## Diff
> {diff}

### Phase 4: Red-team audit

Always runs, whatever the axes. The confidence comes from here. Finders propose, the auditor decides.

Launch `review-auditor`:

> Audit these code review reports. Verify findings against actual code. Check for false positives, blind spots, contradictions, severity miscalibration.
>
> Re-check every cited fact at its source. A finding resting on a fact that is wrong, or that no source backs, does not survive. Say so and drop it.
>
> ## Review Context
>
> {review_context}
>
> ## Reports
>
> {each axis that ran, under its own heading}

### Phase 5: Judge and present

Synthesize this yourself, not in a subagent:

1. Drop false positives flagged by the auditor.
2. Apply severity adjustments.
3. Verify high-confidence findings.
4. Add blind spots as new findings.
5. Deduplicate (same file:line).
6. Tag each finding: `[security]`, `[performance]`, `[quality]`, `[spec]`, `[audit]`.

Present:

```markdown
## Code review: {branch name}

**Diff:** {files changed}, {insertions}+, {deletions}-
**Axes:** {the ones that ran, and why} + red-team audit

### Critical

- [{source}] **{title}** at `{file}:{line}`
  {description}
  **Test (RED first):** {failing test that proves the issue}
  **Fix:** {minimal fix}

### High / Medium / Low

- ...

### Good patterns

- ...

### Audit notes

- ...

**Verdict:** {Critical/High -> "Needs fixes" | Medium/Low only -> "Clean with suggestions" | Nothing -> "Ship it"}
```

### Phase 6: Next step

If the verdict is not "Ship it":

> **What next?**
>
> **a)** Write the full report to `docs/reviews/{branch-name}.md`
> **b)** Address findings (TDD, RED first, baby steps)
> **c)** Switch to pair mode for an interactive walkthrough

Wait for the user to choose. Option b triggers `/dev` on the prioritized fix list.

---

## Pair mode

An interactive file-by-file walkthrough. You bring context, the user dictates comments, and nothing posts without approval. Entered via `/review pair [PR-ref]`. The full six-phase protocol is in `PAIR.md`. Read it when entering pair mode.

---

## Principles

- TDD when fixing findings. RED first.
- Baby steps. One fix at a time.
- Skip findings a linter, formatter, or type-checker already enforces. Report only what tooling misses.
- Findings are sourced or they don't ship. A claim resting on an external fact traces to a **primary source** for the installed version. **Drift**, meaning a departure from the documented approach with nothing explaining why, is the shape worth hunting. The reviewers carry the mechanics, the audit drops what fails them.
- Keep the spec axis separate from quality. Code can follow every convention yet implement the wrong thing, and one axis must not mask the other.
- Stack-agnostic and project-aware. Each reviewer reads CLAUDE.md, AGENTS.md, and .claude/rules itself.
- Adversarial by default. The red-team audit kills weak findings rather than adding noise, and the auditor verifies every claim against the code rather than trusting the user or another agent.
- In pair mode the user owns the comment bag. Post only what they dictate, in their words.
