<!-- Last updated: 2026-10-02T12:41+11:00 -->

# Inline comments

The rules for step 4 of `SKILL.md`: comments inside a function body, and comments beside a declaration in a stylesheet. Docblocks follow `docblocks.md`.

## Who reads it

Someone with the code already open, who can read what each line does. So a comment is worth its line when it says what the code cannot: the reason behind an approach, an exception or a value. A comment that repeats the code gives that reader nothing, and should go.

A reason describes the code as it is now: "core gives the link `display: inline-block`, so this rule needs the extra class". That stays true for as long as the code does. How the code got here is history, and history belongs in the commit.

## Comments worth writing

- A limit the code works within that the reader cannot see: a browser bug, a client's requirement, upstream behaviour that cannot be changed.
- A choice that differs, on purpose, from the one a reader would reach for.
- An override of behaviour inherited from a framework, a parent theme or a third party.
- A workaround, linked to the issue whose fix would let it be removed.
- A number or setting whose origin nobody could guess: a timeout, a breakpoint, a cap.

## Length

One line first. Two or three only when the constraint will not fit in one. A reason that needs a paragraph goes in the commit message, an ADR or the project docs, and the comment points to it in one line:

```php
// Retries stop after 30 seconds. docs/adr/0007-payment-timeouts.md has the trade-off.
```

Across a file, comments past about 15% of the lines are narration. `SKILL.md` step 6 measures it.

## Self-contained comments

A reader reaches a line from a stack trace, a search or a diff, without having read the comments above it. Each comment has to make sense on its own.

Do not lean on an earlier comment with "as above", "same reason" or "see the previous block". Do not open with a pronoun that only an earlier comment explains. Where two places share a reason, give it in both, or give it once in a docblock, an ADR or the docs and point both there.

Before:

```php
// Same reason as above.
if ( 'private' === $post->post_status ) {
	continue;
}
```

After:

```php
// The feed is public, so a private post must never reach it.
if ( 'private' === $post->post_status ) {
	continue;
}
```

The rewrite gives the reason in place. A reader who lands on the `continue` from a stack trace no longer has to hunt for "above".

## Where else it goes

| What | Where |
|---|---|
| How the code changed, and why it changed | Commit message |
| An architectural decision and its trade-offs | ADR, or the project's decision docs |
| How to call a function: parameters, return, side effects | Docblock, `docblocks.md` |
| How a feature works, for the whole team | Project documentation |

## Anti-patterns

- Leaning on an earlier comment.
- Saying what the line does: `// Loop through the posts` above a `foreach`.
- Repeating the name of the function being called.
- Explaining the language or framework instead of the decision.
- Session history: "second pass", "colour pass", "the rhythm fix", "the old version".
- Retelling the reference or the spec.
- Copying a value defined somewhere else. The copy goes stale when the original changes.
- A `TODO` without an owner and a ticket.
- A comment about behaviour the code no longer has.
- Commented-out code. Delete it. Version control is the archive: commented-out code rots, while deleted code stays gone or comes back through a revert. This covers unused exports, unreachable branches and `// old version` blocks.

## A name beats a comment

A comment explaining what a name should have said is a rename waiting to happen. Names declare what, not how, and surface side effects: `saveUser` over `processUser`. A named constant over a magic number: `MAX_RETRIES = 3` over `if (attempt < 3)` leaves nothing for a comment to explain.
