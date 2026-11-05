---
name: leaving-pr-comments
description: "Use whenever writing a GitHub PR comment, review reply, or dismissal reason on the user's behalf."
---

# Leaving PR comments

Adapted from [tstack](https://github.com/t3dotgg/tstack/blob/main/skills/leaving-pr-comments/SKILL.md).

## Draft first

Comments are drafts until the user says post. Show each one with its target (`file:line` or thread link). Post only the ones approved, in the approved wording.

## Write

- Lead with the conclusion.
- Cite the code, behavior, check, or reproduction.
- Separate verified fact from judgment.
- Short. No thanks, filler, or status narration. Run it through `/unslop`.
- Check the whole comment, quotes and attachments included, for secrets and private details.

## Post

Prefix every agent-written comment with this callout, attribution inside, reply outside:

```md
> [!NOTE]
> 🤖 **<model> responding on behalf of <user>**

Actual comment starts here.
```

`<model>` is the public model name the harness reports (else the harness name; never a guess). `<user>` is the user's GitHub login. No headings, rules, or signatures. Skip the callout on PR descriptions, commit messages, and text the user asked to post verbatim.

Preview the Markdown before posting. Confirm GitHub returned the comment URL. Resolve a thread only after its reply posted.
