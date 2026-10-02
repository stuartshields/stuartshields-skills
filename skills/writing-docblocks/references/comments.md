<!-- Last updated: 2026-10-02T12:41+11:00 -->

# When a comment earns its place

The gate behind steps 2 and 4 of `SKILL.md`. Read it before deciding whether a block or an inline comment should exist at all.

- A comment is worth its line when it says what the code cannot: the reason behind an approach, an exception or a value. A comment restating what the code does adds nothing the code does not already say, so delete it.
- A reason is about the code as it stands: "core sets `display: inline-block` on the link, so this needs the extra class". It names the constraint the code answers to, which outlives any commit message about it.
- No narration and no session history. "Second pass", "colour pass", "the rhythm fix" mean nothing to the next reader. Describe the current state, not how it got here.
- Do not retell the reference or the spec.
- One line beats a paragraph. Budget: if comments exceed about 15% of a file, you are narrating.

## Commented-out code

Delete dead code rather than commenting it out. Version control is the archive. Commented-out code rots, while deleted code stays gone or comes back through a revert. This covers unused exports, unreachable branches, and `// old version` blocks.

## A name beats a comment

A comment explaining what a name should have said is a rename waiting to happen. Names declare what, not how, and surface side effects: `saveUser` over `processUser`. A named constant over a magic number: `MAX_RETRIES = 3` over `if (attempt < 3)` leaves nothing for a comment to explain.

## Indentation inside the block

Indent with tabs inside the block, as in the rest of the file: the leading whitespace, a wrapped tag description, and nested `@type` rows. Aligning the type, variable and description columns within a tag group is the one place spaces go, because a tab's width varies by editor and breaks the alignment. A file in a format that requires spaces, such as Python or YAML, keeps them.
