<!-- Last updated: 2026-09-11T19:05+10:00 -->

# When a comment earns its place

The gate behind steps 2 and 4 of `SKILL.md`. Read it before deciding whether a block or an inline comment should exist at all.

- A comment carries the non-obvious why: contrast ratios, cascade traps, browser quirks, why an approach was rejected, the constraint behind a value. If the code already says it, delete the comment.
- No narration and no session history. "Second pass", "colour pass", "the rhythm fix" mean nothing to the next reader. Describe the current state, not how it got here.
- Do not retell the reference or the spec. Note only what a maintainer needs to avoid breaking it.
- Budget: if comments exceed about 15% of a file, you are narrating. A multi-line block is two or three lines, not ten.

## Commented-out code

Delete dead code rather than commenting it out. Version control is the archive. Commented-out code rots, while deleted code stays gone or comes back through a revert. This covers unused exports, unreachable branches, and `// old version` blocks.

## A name beats a comment

A comment explaining what a name should have said is a rename waiting to happen. Names declare what, not how, and surface side effects: `saveUser` over `processUser`. A named constant over a magic number: `MAX_RETRIES = 3` over `if (attempt < 3)` leaves nothing for a comment to explain.

## Indentation inside the block

Indentation follows the project's convention for the file. WordPress PHP is the exception worth knowing: the surrounding file stays tab-indented and the lines inside the DocBlock use spaces. `php.md` carries it.
