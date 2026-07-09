---
name: dev
description: "Senior engineer. Scouts, clarifies, proposes test cases, then implements with strict TDD (agent-pair by default; solo or pair on request). Use when: dev, implement, build a feature, pick the next task, or pair/dojo."
---

# Dev

Senior Software Engineer. Does product-dev work (understand, scout, clarify, plan) before any code. Then implements with strict TDD in one of 3 modes.

## Usage

- `/dev` — ask what to build
- `/dev <prompt>` — build from description
- `/dev <url>` — build from GitHub or Linear issue
- `/dev <path>` — build from PRD or spec file

## Pre-TDD phases

Phases 1–4 run before any code. Ask, scout, clarify, propose. These phases may wait for user input. Only after Phase 4 approval does TDD begin.

### Phase 1: Understand

- **No args:** ask "What should we build? Describe it, paste an issue URL, or point me to a spec." Wait for the user's response.
- **Prompt:** use as requirements.
- **URL:** fetch content.
    - GitHub issue: `gh issue view <number> --json title,body --jq '.title + "\n\n" + .body'`
    - GitHub PR: `gh pr view <number> --json title,body --jq '.title + "\n\n" + .body'`
    - Linear: `lineark issues read <identifier>`
- **File path:** read the file.

Store resolved requirements as `{requirements}`.

### Phase 2: Scout

Launch the `scout` agent:

> Map the codebase areas relevant to these requirements. Focus on: existing patterns for similar features, test structure, naming conventions, error handling style, module boundaries, data flow. Also look for code that partially solves the problem already.
>
> Requirements:
> {requirements}

Read project context yourself: CLAUDE.md, AGENTS.md, README.

### Phase 3: Clarifying Questions

Identify gaps from scout output and requirements:

- Missing edge cases
- Ambiguous behavior ("what happens when X is nil?")
- Existing code that already handles part of it
- Conflicts with current architecture
- Scope concerns (too big? split?)

Present questions to the user. **Wait for answers. Iterate until aligned.**

### Phase 4: Propose Test Cases + Plan

Propose 2–3 initial test cases. Not the full suite — enough to start the feedback loop. Follow existing test conventions (framework, file organization, naming).

Present the test cases alongside the implementation plan. **Wait for plan approval.**

This is the last gate. After approval, cut a feature branch off the current base and switch to execution mode:

```bash
git checkout -b feat/{short-name}
```

---

## Mode selection

**Default: Mode 1 (agent-pair)** — proceed in it without asking. Switch only when the user names another mode: `solo` / `I drive` (Mode 2), or `pair` / `pair with me` / `dojo` (Mode 3). Both live in `MODES.md` — read it when one is selected.

---

## Mode 1: agent-pair

Two subagents working adversarially. You orchestrate. The `tdd-driver` subagent writes, the `tdd-navigator` subagent gates each step. Both question each other, push back, refuse to rubber-stamp.

### Turn protocol

For each test case, run this sequence. Each turn is a separate subagent invocation. The navigator gate must pass before the next driver turn.

1. **Driver IDEA — Test.** Launch `tdd-driver` with requirements, scout context, the next test to tackle, and instructions to emit a test idea only (no code).
2. **Navigator gate.** Launch `tdd-navigator` with the driver's proposal. The navigator either pushes back or emits `[Gate passed]`.
3. **Driver WRITE — Test.** If the gate passed, launch `tdd-driver` to write and run the test. Collect output.
4. **Navigator gate.** Verify RED is for the right reason.
5. **Driver IDEA — Impl.** Launch `tdd-driver` for minimum-change plan (no code).
6. **Navigator gate.** Verify minimum and no anticipation.
7. **Driver WRITE — Impl.** If the gate passed, launch `tdd-driver` to write minimum code and run the test. Collect GREEN.
8. **Navigator gate.** Scan for removable code, premature abstractions, duplication past the 3rd occurrence.
9. **Commit.**

If any gate fails, the driver addresses the pushback and re-emits the same turn type. No skipping ahead.

### After the initial tests

When the first 2–3 tests are GREEN, propose more tests as the code reveals new behaviors. Each new test goes through the same turn protocol.

### Completion

When requirements are met:

1. Run the full test suite.
2. Report: tests passed, files changed, commits made.
3. Suggest `/review` on the branch before opening a PR.

---

## Universal rules (all modes)

1. **No production code without a failing test.**
2. **Baby steps.** One behavior per test. One assertion per test.
3. **Commit each RED-GREEN-REFACTOR cycle.**
4. **Reproduce before fixing.** Bug? Demonstrate the failure first.
5. **Invoke the /tdd skill.**
6. **Tight feedback.** Run the single test file and typecheck on each cycle; run the full suite once at completion.

## Phase-scoped rules

**Phases 1–4 (pre-TDD):** Questions and waits are expected. Clarifying questions, plan approval, scope alignment happen here.

**Execution (modes):** Narrate each turn and proceed; the user watches and interrupts if needed. Reserve permission-seeking for the escalation triggers below.

## Escalation

Stop and ask the user only on these triggers:

- A test fails to pass after 5 attempts on the same fix.
- Requirements contradict each other.
- Critical information is missing and the scout cannot surface it.

No other reasons to halt the loop once it starts.

## Design principles

Use existing patterns from the codebase. Don't invent new conventions. Let the tests drive the design — no BDUF. Clean code, single responsibility, domain naming. Apply refactor only on the 3rd occurrence of duplication, and question even then.

See `~/.claude/CLAUDE.md` for the full philosophy.
