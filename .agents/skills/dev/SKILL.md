---
name: dev
description: "Senior engineer. Scouts, checks the work is settled, agrees seams and test cases, then implements with strict TDD (agent-pair by default; solo or pair on request). Use when: dev, implement, build a feature, pick the next task, or pair/dojo."
---

# Dev

Senior Software Engineer. Does product-dev work (understand, scout, clarify, plan) before any code. Then implements with strict TDD in one of 3 modes.

## Usage

- `/dev` asks what to build
- `/dev <prompt>` builds from a description
- `/dev <url>` builds from a GitHub or Linear issue
- `/dev <path>` builds from a PRD or spec file

## Pre-TDD phases

Phases 1 to 4 run before any code. Ask, scout, gate, agree. These phases may wait for user input. Only after Phase 4 approval does TDD begin.

Design is not among them. `dev` builds settled work and routes the rest to the skills that settle it.

### Phase 1: Understand

- **No args.** Ask "What should we build? Describe it, paste an issue URL, or point me to a spec." Wait for the user's response.
- **Prompt.** Use it as the requirements.
- **URL.** Fetch the content.
    - GitHub issue: `gh issue view <number> --json title,body --jq '.title + "\n\n" + .body'`
    - GitHub PR: `gh pr view <number> --json title,body --jq '.title + "\n\n" + .body'`
    - Linear: `lineark issues read <identifier>`
- **File path.** Read the file.

Store resolved requirements as `{requirements}`.

### Phase 2: Scout

Launch the `scout` agent:

> Map the codebase areas relevant to these requirements. Focus on: existing patterns for similar features, test structure, naming conventions, error handling style, module boundaries, data flow. Also look for code that partially solves the problem already.
>
> Requirements:
> {requirements}

Read project context yourself: CLAUDE.md, AGENTS.md, README.

### Phase 3: Is the work settled?

Build what is **settled**. Three checks:

- The behaviour is precise enough to write a failing test for.
- The seams it touches are identifiable.
- Nothing is still open that would change the design.

A question you can settle in one exchange is settled. Ask it and carry on. What fails these checks is design work, and the skills built for it do it better than a gate in the middle of a build. Name the one that fits and stop there:

- fuzzy requirements, or competing options with no clear winner → `/grill-with-docs`
- the way from here to the destination isn't visible yet → `/wayfinder`
- the answer has to be runnable to be believed → `/prototype`
- the module's shape is itself the question → `/codebase-design`
- more than one session of building → `/to-spec`, then `/to-tickets`

Tell the user which one and why. `/ask-matt` maps the rest.

A question that needs reading rather than a decision goes to `/research`. That is a background agent that traces the question to **primary sources** and leaves a cited file. Fire it and carry on, it runs off the critical path.

### Phase 4: Agree seams, tests, and sources

Name the **seams** under test and confirm them. `/tdd` writes no test at an unconfirmed seam. Prefer seams that already exist. Propose new ones at the highest point you can reach. Fewer is better, one is ideal.

Propose 2 or 3 initial test cases at those seams. Not the full suite, just enough to start the feedback loop. Follow existing test conventions (framework, file organization, naming).

Every limit, timeout, retry count, model id, and SDK option in the plan traces to a primary source for the **installed** version. Read the package's own types and source first, vendor docs second. Anything you could not trace is presented as a guess, so approval covers it knowingly.

Present the test cases alongside the implementation plan. **Wait for plan approval.** Under `ship`, the ship request is the approval: post the plan and continue.

This is the last gate. After approval, cut a feature branch off the current base and switch to execution mode:

```bash
git checkout -b feat/{short-name}
```

---

## Mode selection

**Default: Mode 1 (agent-pair).** Proceed in it without asking. Switch only when the user names another mode: `solo` / `I drive` (Mode 2), or `pair` / `pair with me` / `dojo` (Mode 3). Both live in `MODES.md`. Read it when one is selected.

---

## Mode 1: agent-pair

Two subagents working adversarially. You orchestrate. The `tdd-driver` subagent writes, the `tdd-navigator` subagent gates each step. Both question each other, push back, refuse to rubber-stamp.

### Turn protocol

For each test case, run this sequence. Each turn is a separate subagent invocation. The navigator gate must pass before the next driver turn.

1. **Driver: test idea.** Launch `tdd-driver` with requirements, scout context, the next test to tackle, and instructions to emit a test idea only (no code).
2. **Navigator gate.** Launch `tdd-navigator` with the driver's proposal. The navigator either pushes back or emits `[Gate passed]`.
3. **Driver: write test.** If the gate passed, launch `tdd-driver` to write and run the test. Collect output.
4. **Navigator gate.** Verify RED is for the right reason.
5. **Driver: impl idea.** Launch `tdd-driver` for a minimum-change plan (no code).
6. **Navigator gate.** Verify minimum and no anticipation.
7. **Driver: write impl.** If the gate passed, launch `tdd-driver` to write minimum code and run the test. Collect GREEN.
8. **Navigator gate.** Scan for removable code and premature abstraction. Did this turn write the minimum? Extraction waits for `/review`. `/tdd` keeps refactoring out of the loop.
9. **Commit.**

If any gate fails, the driver addresses the pushback and re-emits the same turn type. No skipping ahead.

### After the initial tests

When the first 2 or 3 tests are GREEN, propose more tests as the code reveals new behaviors. Each new test goes through the same turn protocol.

### Completion

When requirements are met:

1. Run the full test suite.
2. **Prove it** per [ship's Proof](../ship/SKILL.md#proof). UI or runtime changes get a live test on a simulator or device.
3. Report: tests passed, proof, files changed, commits made.
4. Under `ship`, return to it. Otherwise offer `ship` (review loop and draft PR) or `review-loop` alone.

---

## Universal rules (all modes)

1. **No production code without a failing test.**
2. **Baby steps.** One behavior per test. One assertion per test.
3. **Commit each RED-GREEN-REFACTOR cycle.**
4. **Reproduce before fixing.** Bug? Demonstrate the failure first.
5. **Invoke the /tdd skill.**
6. **Tight feedback.** Run the single test file and typecheck on each cycle. Run the full suite once at completion.

## Phase-scoped rules

**Phases 1 to 4 (pre-TDD).** Questions and waits are expected. Clarifying questions, plan approval, and scope alignment happen here.

**Execution (modes).** Narrate each turn and proceed. The user watches and interrupts if needed. Reserve permission-seeking for the escalation triggers below.

## Escalation

Stop and ask the user only on these triggers:

- A test fails to pass after 5 attempts on the same fix.
- Requirements contradict each other.
- Critical information is missing and the scout cannot surface it.

No other reasons to halt the loop once it starts.

## Design principles

Use existing patterns from the codebase. Don't invent new conventions. Let the tests drive the design, no BDUF. Clean code, single responsibility, domain naming. Apply refactor only on the 3rd occurrence of duplication, and question even then.

**Drift.** Departing from the documented approach is a decision, so record it where the next reader lands. A comment at the site, or an ADR when the choice is hard to reverse. `/domain-modeling` holds the test for which.

See `~/.claude/CLAUDE.md` for the full philosophy.
