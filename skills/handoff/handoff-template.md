<!-- Last updated: 2026-08-31T11:00+11:00 -->

# Handoff document template

Six sections. Revise them in place on every update, and **do not add more**: a seventh section is how these documents turn into knowledge bases.

Keep a header with "none" under it rather than dropping it, so the next agent can tell "none" from "not recorded".

The whole document stays under 120 lines. There is no Key Files section and no Git State section: `git diff --stat` regenerates the first and the session's environment block already carries the second.

```markdown
## Goal
What we're trying to accomplish, with acceptance criteria if any were given,
and any standing constraints the user has set. Three lines.

## Where Things Live
Pointers, never content. The findings queue and the command to count it. The
stores that routed facts went to. The specs, ADRs, issues, commits and PRs
that hold the work's own detail, by path or URL.

## Current Progress
Where the work stands now, in enough detail that the next agent doesn't
re-derive it. Completed work is one line of outcome each, not a history of how
it went. Give the command rather than its output.

## Verification
The commands that decide whether this work is sound, so the next agent can
re-run them, plus the gaps stated plainly. "Not yet run" is a useful answer.
Do not paste results: they are true of a tree that has since moved.

## Decisions and Dead Ends
Approaches that failed and why, and things noticed and consciously left alone.
One line each. Keep an entry only while it still constrains the work. One that
will still be true next month is a durable fact: route it out.

## Next Steps
Ordered, and rewritten from scratch each time. The first item must be
actionable without further investigation. Name the skill a step needs, exactly
as the Skill tool takes it.
```
