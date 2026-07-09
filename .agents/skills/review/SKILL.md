---
name: review
description: "Code review in 2 modes. Autonomous (default): parallel security/performance/quality/spec reviewers + red-team auditor → verdict. Pair: file-by-file walkthrough, comments posted only on approval. Use when: review, code review, review a PR/branch, or pair review."
---

# Review

Two-mode code review.

- **Default (autonomous):** parallel specialized reviewers + red-team audit + verdict.
- **Pair mode:** file-by-file walkthrough with comment bag and post-on-approval.

## Usage

- `/review` — ask what to review, default autonomous
- `/review <prompt|url|path>` — review current changes against the given context, autonomous
- `/review pair <PR-ref>` — enter pair mode on a PR
- `/review pair` — ask for PR reference, enter pair mode

## Parse input

- **Prompt:** use as `{review_context}` directly.
- **URL:**
    - GitHub issue: `gh issue view <number> --json title,body --jq '.title + "\n\n" + .body'`
    - GitHub PR: `gh pr view <number> --json title,body --jq '.title + "\n\n" + .body'`
    - Linear: `lineark issues read <identifier>`
- **File path:** read the file.
- **No args:** ask "What should I review? Describe it, paste an issue URL, or point me to a spec."

---

## Autonomous mode (default)

### Phase 1: Diff

```bash
git diff main...HEAD
git diff main...HEAD --stat
```

If empty, try `git diff HEAD~1`. If still empty, say nothing to review and stop. Store as `{diff}` and `{diff_stat}`.

### Phase 2: Scout

Launch the `scout` agent:

> Map the codebase areas touched by these changed files. Report: architecture, patterns, conventions, test structure, error handling, project rules from CLAUDE.md/AGENTS.md/.claude/rules.
>
> Changed files:
> {diff_stat}

Store as `{scout_context}`.

### Phase 3: Parallel review

Launch **4 agents in parallel** (single message, 4 Agent tool calls):

- `security-reviewer`: "Review this PR for security issues.\n\n## Review Context\n{review_context}\n\n## Codebase Context\n{scout_context}\n\n## Diff\n{diff}"
- `performance-reviewer`: "Review this PR for performance issues.\n\n## Review Context\n{review_context}\n\n## Codebase Context\n{scout_context}\n\n## Diff\n{diff}"
- `quality-reviewer`: "Review this PR for quality (design, testing, DDD, SOLID, clean code).\n\n## Review Context\n{review_context}\n\n## Codebase Context\n{scout_context}\n\n## Diff\n{diff}"
- `spec-reviewer`: "Review whether this PR faithfully implements the intended spec.\n\n## Spec / Issue\n{review_context}\n\n## Codebase Context\n{scout_context}\n\n## Diff\n{diff}"

All 4 in the same message so they run concurrently. If `{review_context}` carries no spec (bare prompt, no issue/PRD), skip `spec-reviewer` and note "no spec available" in the report.

### Phase 4: Red-team audit

Launch `review-auditor`:

> Audit these code review reports. Verify findings against actual code. Check for false positives, blind spots, contradictions, severity miscalibration.
>
> ## Review Context
>
> {review_context}
>
> ## Security Review
>
> {security_report}
>
> ## Performance Review
>
> {performance_report}
>
> ## Quality Review
>
> {quality_report}
>
> ## Spec Review
>
> {spec_report}  (omit if no spec was available)

### Phase 5: Judge and present

Synthesize (you, not a subagent):

1. Drop false positives flagged by the auditor.
2. Apply severity adjustments.
3. Verify high-confidence findings.
4. Add blind spots as new findings.
5. Deduplicate (same file:line).
6. Tag each finding: `[security]`, `[performance]`, `[quality]`, `[spec]`, `[audit]`.

Present:

```markdown
## Code Review: {branch name}

**Diff:** {files changed}, {insertions}+, {deletions}-
**Reviewers:** security, performance, quality, spec + red-team audit

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

If verdict is not "Ship it":

> **What next?**
>
> **a)** Write full report to `docs/reviews/{branch-name}.md`
> **b)** Address findings (TDD, RED first, baby steps)
> **c)** Switch to pair mode for interactive walkthrough

Wait for the user to choose. Option b triggers `/dev` on the prioritized fix list.

---

## Pair mode

Interactive file-by-file walkthrough — you bring context, the user dictates comments, and nothing posts without approval. Entered via `/review pair [PR-ref]`. The full six-phase protocol is in `PAIR.md` — read it when entering pair mode.

---

## Principles

- TDD when fixing findings. RED first.
- Baby steps. One fix at a time.
- Skip findings a linter, formatter, or type-checker already enforces. Report only what tooling misses.
- Keep the spec axis separate from quality. Code can follow every convention yet implement the wrong thing — one axis must not mask the other.
- Stack-agnostic. Project-aware (scout reads CLAUDE.md/.claude/rules).
- Adversarial by default: the red-team audit kills weak findings rather than adding noise, and every claim is verified against the code — not taken on trust from the user or another agent.
- In pair mode the user owns the comment bag — post only what they dictate, in their words.
