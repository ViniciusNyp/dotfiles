# Review — pair mode

Interactive file-by-file walkthrough. You bring context, the user reviews, comments go in a bag, posted only on approval. Entered via `/review pair [PR-ref]`. The autonomous default lives in `SKILL.md`; the `## Principles` there still apply.

## Phase 1: Resolve PR reference

Parse the argument:

- PR number `123` → `gh pr diff 123`, `gh pr view 123`
- PR URL → extract number
- No arg → ask "Which PR? Number or URL."

## Phase 2: Gather context

1. `gh pr view <number> --json title,body,headRefName,baseRefName,files`
2. `gh pr diff <number>`
3. Launch `scout`:

    > Read the changed files in full and map surrounding code. Report:
    >
    > - What each change does and why
    > - Related models, services, helpers touched
    > - Project patterns the PR should follow
    > - Concerns (thread safety, error handling, naming, tests)

4. **Rank files by review priority** (you, not scout):
    - Security-sensitive files first (auth, crypto, input handling, SQL)
    - Business logic before tests
    - Files with more changes first within each tier
    - New files before modifications

## Phase 3: Overview

Present:

```
## PR #{number}: {title}

{body summary in 2–3 lines}

### Files (ranked by review priority)
1. {file} — {new|modified|deleted} — {chars}/{lines} changed — {why this rank}
2. ...

### Scout highlights
{top 3 insights from scout}

Ready. Say 'next' to start with #1, or pick a number.
```

## Phase 4: File-by-file walkthrough

For each file (in ranked order or user-picked):

- **File path** and status (new/modified/deleted)
- **Key chunks:** show 2–4 most important code snippets from the diff, not the full file
- **Insights:** what changed and why
- **Concerns:** flag bugs, pattern deviations, style issues, missing tests

Then wait. The user may:

- `next` — move to the next file
- `prev` — go back
- `#N` — jump to file N
- Ask questions about the current file
- Dictate a comment: `comment <prefix>: <text> at line <N>`
- `skip` — move on without comments
- `done` — jump to phase 5

## Phase 5: Comment bag

Maintain a running table:

```
| # | File:Line | Comment |
|---|-----------|---------|
| 1 | auth/login.rb:42 | **question:** why skip the CSRF check here? |
```

Conventional prefixes (user picks):

- `question:` — asking clarification
- `suggestion:` — proposing an alternative
- `issue:` — needs to change
- `nit:` — minor, take it or leave it
- `thought:` — context, no action needed
- `praise:` — highlighting something well done

Post only the comments the user dictated, in their words.

## Phase 6: Preview and post

After `done`, show the final bag:

```
Ready to post {N} comments on PR #{number}. Want me to post, edit any, or discard?
```

Post only after explicit approval ("post", "go ahead", "ship it").

On approval, use `gh api` to create PR review comments on the correct file and line using the head commit SHA. Report back with the comment URLs.
