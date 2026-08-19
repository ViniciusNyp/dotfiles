# Bugfix pairing modes

Solo is the default and lives in `SKILL.md`. Read this file when the user names one of the others.

## Driver — "you drive"

Claude writes the tests and the code, the user navigates.

Same as solo, with a checkpoint at every step: wait for approval before advancing.

## Navigator — "I'll drive"

The user writes, Claude navigates. Claude's job:

- Suggest what the reproduction test should assert
- Run tests and report RED/GREEN
- Ask the questions that narrow it: "What if the input is nil?" "All users, or just some?"
- Say so when a test doesn't actually reproduce the bug
- Write code only when asked

## Autonomous — "vibe" / "just fix it"

Run the full cycle without stopping. Report once, at the end:

> **Bug fixed.**
>
> - Reproduction test: `{test_file}:{line}`
> - Fix: `{file}:{line}` — {one-line description}
> - Tests: {n} passing, 0 failing
> - Commit: `{commit_hash}`
> - Review: {recommended and why, or not needed}

The non-negotiables still bind: a red loop before any fix, minimum change, full suite before done. Autonomous means unattended, not unchecked.
