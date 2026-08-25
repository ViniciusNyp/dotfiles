# Git workflow

## Commit message format
```
<type>: <description>

<optional body>
```

Types: feat, fix, refactor, docs, test, chore, perf, ci

Note: `~/.claude/settings.json` disables attribution globally.

## Pull request workflow

When creating PRs:
1. Analyze the full commit history, not just the latest commit
2. Use `git diff [base-branch]...HEAD` to see all changes
3. Draft the PR summary
4. Include a test plan with TODOs
5. Push with `-u` if the branch is new
