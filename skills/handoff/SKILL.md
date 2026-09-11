---
name: handoff
description: Write, update, or resume from a handoff document (docs/HANDOFF.md) so the next session can continue with fresh context, and close a session out deliberately. Use whenever the user says "handoff", "update HANDOFF", "add to HANDOFF", "READ HANDOFF", "wrap up", "tidy up", "cleanup", "close out", "finish up", asks to save or continue work, or says they are about to /clear, compact or exit. Also use when resuming, reading an existing HANDOFF.md and picking the work back up, including any outstanding P0/P1/P2 findings it points at.
hooks:
  UserPromptSubmit:
    - hooks:
        - type: command
          command: "\"${CLAUDE_SKILL_DIR}/scripts/remind-handoff.sh\""
---

<!-- Last updated: 2026-09-11T20:35+10:00 -->

# Handoff

`docs/HANDOFF.md` carries the state a fresh agent needs to continue, and nothing else. Write it, update it, resume from it, or close a session out.

## Pick the channel first

- **Another of your sessions is running.** Message it. `/list-agents` shows what this session can reach. A message reaches your own sessions alone, leaves nothing on disk, and dies with the session.
- **The far side does not exist yet.** Write the document. A `/clear`, a compact, a crash, tomorrow morning, a colleague pulling the branch.
- **This conversation should continue elsewhere.** Resume that session instead. A cross-session message carries plain text only.

## Route durable facts out

State gets superseded. A durable fact does not: "do not remove this guard, it is load-bearing" is true next month too, so no pruning rule reaches it and the document only grows.

Send it to auto memory, or to a path-scoped rule where it binds to a file. Say where each one went.

Skip anything the code, git history, `CLAUDE.md` or an existing rule already states. Reference a spec, ADR, issue or PR by path. Do not summarise it.

## Resume: "READ HANDOFF and do X"

1. Read `docs/HANDOFF.md` in full first.
2. Reconcile it against reality: the branch, `git status`, and whether the files it names still look the way it claims.
3. State in one or two lines what you understand the task to be.
4. Work the findings queue it points at.

Where the document contradicts the working tree, say so and ask. Do not quietly follow either.

## Write and update

1. Read the existing document, then **revise it in place**. A rewrite, not an append.
2. **Reconcile before re-asserting.** Every path, count and status the old document claims is a claim, not a fact. Resolve each against the tree, then correct or delete what no longer holds.
3. Follow [handoff-template.md](handoff-template.md).
4. Route durable facts out and say where they went.
5. Redact keys, passwords and personal details. This file gets committed.

Give the user the path when you are done.

### Size

**120 lines is the ceiling.** Past it, prune before adding.

Fold new state into the existing sections. Delete what is finished. Rewrite Next Steps from scratch every time, because it describes the future.

Two tells that the document is rotting:

- **A heading naming a date or a session.** It is becoming a changelog.
- **A growing section of standing facts.** It is becoming a knowledge base. The fix is to route them out, not to prune harder.

### Give the command, not its output

A number written here goes stale with nothing noticing, then reads as fact rather than guess. "Count with `grep -c`" survives; "there are 61" does not.

Exception: a measurement taken as evidence for a decision, where the value is the point. Date it and say what produced it.

This is why the template has no Key Files or Git State section.

### Findings live in a queue

Tiered findings go in the project's findings queue, one entry each with tier, `file:line` and the one-line problem. The handoff names the queue's path and the command to count it. Never a copy: two lists disagree silently and the count rots first.

### Session history

Where a session-history store loads automatically, such as a `.remember/` directory, cite it for "what happened when" and name the file to grep. Do not narrate a timeline in the prose.

## Close out

"Wrap up and exit" ends a session on purpose, and the document is only one possible output. Report what each step did.

1. **Say what the session changed.** Files touched and the outcome reached, not a timeline.
2. **Land every loose thread.** Each observation raised along the way becomes a routed fact, a queued finding, a recorded decision, or something dropped for a reason you can state.
3. **Tidy the workspace, asking before deleting.** `git branch --merged` and `git worktree list` show the candidates. Leave unmerged branches and worktrees holding uncommitted changes alone, and name them.
4. **Pick the channel**, then write the document only if the work crosses into a session that does not exist yet.

## Common mistakes

- **Appending a new session section.**
- **Re-asserting an old claim without resolving it.** The prose is new, the facts are not.
- **Deleting a branch that only looked finished.** `git branch --merged` answers for the current HEAD alone, so a branch merged elsewhere is absent and a squash-merged one reads as unmerged. Confirm against the target, and never delete without a yes.
- **Recording "P1 fixes complete" with no queue to point at.** The next session needs the work, not a status.
- **Claiming verification that was not run.** "Not yet run" is useful.
