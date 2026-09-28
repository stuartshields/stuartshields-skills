---
name: handoff
description: Write, update, or resume from docs/HANDOFF.md, the short state document a fresh session uses to continue the work. Use whenever the user says "handoff", "update HANDOFF", "add to HANDOFF", "READ HANDOFF", "wrap up", "close out", "finish up", asks to save or continue work, or says they are about to /clear or exit. Also use when resuming from an existing HANDOFF.md, including any findings queue it points at.
hooks:
  PostToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "\"${CLAUDE_SKILL_DIR}/scripts/check-handoff-size.sh\""
---

<!-- Last updated: 2026-09-28T12:55+11:00 -->

# Handoff

`docs/HANDOFF.md` holds what a fresh session needs to continue, in 3,000 characters or fewer. `wc -m docs/HANDOFF.md` measures it.

## Resume: "READ HANDOFF and do X"

1. Read `docs/HANDOFF.md`.
2. Check its claims against the branch, `git status` and the files it names. Where they disagree, say so and ask.
3. State the task in one or two lines, then work toward the Goal.

## Before writing, offer a resume

The document is for a session nobody will resume: after `/clear`, on another machine, or for another person. Compaction already re-injects `CLAUDE.md`, auto memory, the plan-mode plan and invoked skills.

If the user will return to this conversation, tell them `/rename <name>` now and `claude --resume <name>` later carries everything. Write the document when they still want it.

## Write and update

1. Rewrite the whole document in place. Never append, and delete what is finished.
2. Check every claim you keep against the tree. The old document's paths, counts and statuses are claims, not facts.
3. Follow [handoff-template.md](handoff-template.md): four sections, no more.
4. Stay under 3,000 characters. Over budget, cut rather than compress: one long line costs as much as several short ones.
5. Redact keys, passwords and personal details. This file gets committed.

Give the user the path and the character count.

## What stays out

- **Anything already written down.** `CLAUDE.md`, auto memory, rules, git history and the code all load or can be read.
- **Facts still true next month.** Put them in `CLAUDE.md`, auto memory or a path-scoped rule, and do not list them here.
- **Findings.** They live in the project's findings queue. Point at it with the command that counts it.
- **Command output.** Give the command: a pasted number goes stale and still reads as fact.
- **History.** No dated headings and no session narrative.
