# Dev — alternate modes

The default is **Mode 1 (agent-pair)**, documented in `SKILL.md`. Read this file only when the user selects another mode: `solo` / `I drive` → Mode 2, or `pair` / `pair with me` / `dojo` → Mode 3. The universal and phase-scoped rules in `SKILL.md` still apply.

## Mode 2: solo

You do everything. Same strict TDD. No subagents. Self-review at each checkpoint.

### Loop per test case

1. **IDEA — Test.** Narrate: behavior, why this test, single assertion, expected setup. Self-check: is this one behavior?
2. **RED.** Write the test. Run. Share output. Confirm failure is for the right reason.
3. **IDEA — Impl.** Narrate: minimum change, files touched, what stays untouched.
4. **GREEN.** Write minimum code. Run. Confirm pass. Self-check: can any line be deleted while staying GREEN?
5. **REFACTOR.** Clean up if useful. Run tests — must stay GREEN.

Narrate each step in the chat. The user reads and will interrupt if needed.

## Mode 3: pair-with-me

You and the user pair. The user may drive or navigate — negotiate at the start of each cycle.

### Rule: Asking > Writing

No code before alignment. Every test and every implementation starts with a question or explanation. Problems before solutions. Always.

### Loop

1. **Discuss the problem.** Frame it clearly. Show related code from the codebase. Walk through edge cases. Explain why the problem exists. Wait for the user.
2. **Propose test.** One test. Explain why this one first. Wait for approval.
3. **RED.** Write or watch the user write. Explain the failure. Discuss the fix approach. Wait.
4. **GREEN.** Write or watch the user write. Minimum code. Run. Discuss any refactor. Wait.
5. **Commit.** Remind the user: "GREEN and clean. Good time to commit."

### Navigator behavior (when the user drives)

- Ask questions that provoke thinking. Hand out answers only when asked.
- When the user is stuck, ask a question that unblocks rather than handing over a snippet.
- When asked for help, teach. Explain the concept, show codebase examples. Give the smallest useful snippet only when explicitly asked.
- On GREEN: one-line summary of what's proven.
- On RED: explain the error, offer a question-as-tip.

### Driver behavior (when you drive)

- Ask before writing. "Should I write this test?" not "Here's the test I wrote."
- Narrate what you're about to do and why.
- When the user asks "why", teach. Give context, history, tradeoffs.

### Watch loop (optional)

For Mode 3 with a file watcher:

```bash
fswatch -1 <file_or_dir>
```

Cycle: spawn watcher → wait → run tests → read context → display results → spawn again. Loop ends only when the user says stop.
