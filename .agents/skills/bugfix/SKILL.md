---
name: bugfix
description: "Bug hunter. Reproduces a bug with a failing test (RED), then fixes it with TDD. Simpler than /dev, focused solely on fixing bugs. Use when: bugfix, fix a bug, regression, something's broken. For hard-to-reproduce or diagnostic work, reach for /diagnosing-bugs instead."
---

# Bugfix

Bug hunter. Reproduces the bug with a failing test, then fixes it with strict TDD. Focused and surgical — no feature work, just fix and move on.

## Usage

- `/bugfix` — asks what's broken
- `/bugfix <prompt>` — fix from description
- `/bugfix <url>` — fix from GitHub/Linear issue
- `/bugfix <path>` — fix from bug report file

## Workflow

### Phase 1: Understand the Bug

**No arguments:** Ask: "What's broken? Describe the bug, paste an issue URL, or point me to a report."

**Wait for the user's response.**

**Prompt:** Use as bug description.

**URL:** Fetch:
- GitHub: `gh issue view <number> --json title,body --jq '.title + "\n\n" + .body'`
- Linear: `lineark issues read <identifier>`

**File path:** Read the file.

Restate the bug back to the user in your own words:

> My understanding: {what's broken, when it happens, expected vs actual behavior}
>
> Is that right? Anything else I should know?

**Wait.** Confirm understanding before proceeding.

### Phase 2: Scout the Bug

Explore the codebase to understand the area where the bug lives:

- Read the relevant source files
- Read existing tests for that area
- Trace the data/control flow where the bug occurs
- Check git log for recent changes that might have introduced it

Report findings:

> Here's what I found:
>
> - **Where it happens:** {file(s), function(s), line(s)}
> - **Root cause hypothesis:** {what I think is wrong and why}
> - **Existing test coverage:** {what's tested, what's missing}
> - **Recent changes:** {any suspicious recent commits, or "nothing recent"}
>
> Does this match what you're seeing?

**Wait.** The user may have more context.

### Phase 3: Reproduce with a tight, red-capable loop

**This is the skill.** Spend disproportionate effort here — a loop that goes **red** on this bug finds the cause for you; without one, no amount of reading code will.

Build a **tight** feedback loop that goes red on this exact bug: a signal you can run in seconds that asserts the user's exact symptom and turns green once fixed. A failing test at the right seam is the default — reach for a curl script, CLI invocation with a fixture, or a replayed trace when one lands a sharper signal faster. `/diagnosing-bugs` Phase 1 ranks ten ways to construct one; read it when the obvious two don't fit.

**Seam check.** A correct seam exercises the real bug pattern *as it occurs at the call site*. If the only reachable seam is too shallow to do that — a unit test where the bug needs several callers — say so: **that itself is a finding**, and the regression test there would buy false confidence. Note it for Phase 7.

Phase 3 is done when you can name **one command**, already run at least once, that is:

- [ ] **Red-capable** — drives the real code path and asserts the user's exact symptom, not "didn't crash"
- [ ] **Red for the right reason** — the bug, not a setup or import error
- [ ] **Deterministic** — same verdict every run
- [ ] **Fast** — seconds, not minutes
- [ ] **Named for the behaviour** — `test "correct behavior that is currently broken"`

Reading code to build a theory before that command exists is the failure this phase prevents.

**Hard bug?** If a tight loop resists you (non-deterministic, no clean seam, needs environment access you don't have), stop hand-rolling it here — hand off to `/diagnosing-bugs` for the full reproduce → minimise → hypothesise → instrument discipline, then return to fix.

> Reproduction test:
>
> ```
> {test_code}
> ```
>
> This proves: {what broken behavior it captures}
> Expected: {what should happen}
> Actual: {what happens now}
>
> Write it?

**Wait.** The user may adjust the test or the approach.

Write the test. Run it. **Confirm RED.**

> RED — {error message or assertion failure}
>
> The bug is now captured in a test. Proceeding to fix.

Before fixing, shrink the repro to the smallest input and setup that still goes red. Fewer moving parts narrow the fix and leave a cleaner regression test.

**If the test passes (GREEN unexpectedly):** The test doesn't reproduce the bug. Don't proceed. Investigate:
- Is the test targeting the right scenario?
- Is the bug environment-specific?
- Are we missing a specific input or state?

Adjust and try again. **Persist until you have a failing test.** Ask the user for help if stuck after 3 attempts.

### Phase 4: Fix (GREEN)

Write the **minimum code** to make the failing test pass — touch only the lines that test requires. Leave unrelated code, features, and refactors alone; note any other bugs you spot for later. Stay surgical.

Run tests. **Confirm GREEN.**

> GREEN — Bug fix verified. {n} tests passing.

If the fix is non-obvious, explain briefly:

> The fix: {one-line explanation of what changed and why}

### Phase 5: Check for Collateral

Run the **full test suite** (not just the new test):

```bash
# Try project test commands
make test 2>/dev/null || mix test 2>/dev/null || cargo test 2>/dev/null || npm test 2>/dev/null
```

If other tests break:
- The fix introduced a regression → adjust the fix
- The other tests were wrong → note it, fix them too with the same RED-GREEN approach

> Full suite: {pass/fail}. {details if any breakage}

### Phase 6: Refactor (if needed)

Only if the fix is ugly or the area needs cleanup:
- Clean up, run tests, confirm GREEN
- Keep it minimal — this is a bugfix, not a rewrite

### Phase 7: Commit and close out

Stage only the changed files. Commit with:

```
fix(<scope>): <what was fixed>
```

If multiple tests were needed (complex bug), that's fine — commit them together as one logical fix. State the cause in the message, so the next person to touch this reads why it broke rather than guessing.

**Offer `/review`.** A surgical fix behind a red loop and a green suite usually doesn't need one. Say so plainly and let the user decide — but recommend it, with the reason, when the fix grew past its repro:

- it touched more than the loop demanded
- it landed in shared code, or changed a seam others depend on
- Phase 6 refactored anything
- Phase 3 found no correct seam, so the regression test is weaker than it looks

Then ask: **what would have prevented this bug?** Answer it now, with everything you just learned:

- No correct seam to lock the fix down (the Phase 3 finding) → hand off to `/improve-codebase-architecture`
- A test that should have caught it but asserted the wrong altitude → say which, and what it should assert
- Nothing structural, just a mistake → say so and stop; a forced lesson is worse than none

---

## Multiple Bugs

If the input describes multiple bugs:

1. List them
2. Ask the user which to tackle first
3. Fix one at a time, full cycle each (reproduce → fix → verify)
4. Commit each fix separately

---

## Pairing Modes

**Solo by default** — Phases 3 through 8 run with checkpoints, and the rest of this file describes it.

The user can name another mode at any point: `you drive` (driver), `I'll drive` (navigator), `vibe` / `just fix it` (autonomous). All three live in [MODES.md](MODES.md) — read it when one is named.

---

## Non-negotiables

1. **A red loop first.** No red-capable signal, no fix — tighten the loop or hand off to `/diagnosing-bugs` before touching production code.
2. **Minimum fix, one bug at a time.** Smallest change that goes green; note other bugs for later, don't batch.
3. **Full suite before done.** The fix must not break anything else. If stuck reproducing after 3 attempts, ask for more context.
