# Review, pair mode

An interactive file-by-file walkthrough. You bring context, the user reviews, comments go in a bag, and they post only on approval. Entered via `/review pair [PR-ref]`. The autonomous default lives in `SKILL.md`, and the `## Principles` there still apply.

## Phase 1: Resolve PR reference

Parse the argument:

- PR number `123` → `gh pr diff 123`, `gh pr view 123`
- PR URL → extract the number
- No arg → ask "Which PR? Number or URL."

## Phase 2: Gather context

1. `gh pr view <number> --json title,body,headRefName,baseRefName,files`
2. `gh pr diff <number>`
3. Launch `scout`:

    > Read the changed files in full and map the surrounding code. Report:
    >
    > - What each change does and why
    > - Related models, services, helpers touched
    > - Project patterns the PR should follow
    > - Concerns (thread safety, error handling, naming, tests)

4. **Rank files by review priority** yourself, not in scout:
    - Security-sensitive files first (auth, crypto, input handling, SQL)
    - Business logic before tests
    - Files with more changes first within each tier
    - New files before modifications

## Phase 3: Overview

Present:

```
## PR #{number}: {title}

{body summary in 2 or 3 lines}

### Files (ranked by review priority)
1. {file} ({new|modified|deleted}), {chars}/{lines} changed. {why this rank}
2. ...

### Scout highlights
{top 3 insights from scout}

Ready. Say 'next' to start with #1, or pick a number.
```

## Phase 4: File-by-file walkthrough

For each file, in ranked order or as the user picks:

- **File path** and status (new, modified, deleted)
- **Key chunks.** Show the 2 to 4 most important code snippets from the diff, not the full file
- **Insights.** What changed and why
- **Concerns.** Flag bugs, pattern deviations, style issues, missing tests

Then wait. The user may:

- `next` moves to the next file
- `prev` goes back
- `#N` jumps to file N
- Ask questions about the current file
- Dictate a comment: `comment <prefix>: <text> at line <N>`
- `skip` moves on without comments
- `done` jumps to phase 5

## Phase 5: Comment bag

Maintain a running table:

```
| # | File:Line | Comment |
|---|-----------|---------|
| 1 | auth/login.rb:42 | **question:** why skip the CSRF check here? |
```

Conventional prefixes, the user picks:

- `question:` asks for clarification
- `suggestion:` proposes an alternative
- `issue:` needs to change
- `nit:` minor, take it or leave it
- `thought:` context, no action needed
- `praise:` highlights something well done

Post only the comments the user dictated, in their words.

## Phase 6: Preview and post

After `done`, show the final bag:

```
Ready to post {N} comments on PR #{number}. Want me to post, edit any, or discard?
```

Post only after explicit approval ("post", "go ahead", "ship it").

On approval, use `gh api` to create PR review comments on the correct file and line using the head commit SHA. Report back with the comment URLs.
