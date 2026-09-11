---
name: writing-docblocks
description: Use when adding or fixing a docblock, docstring, or inline comment in code, including PHPDoc, JSDoc, TSDoc, WordPress inline documentation, CSS section comments and SassDoc. Also use when the user says a function is undocumented, asks you to document a class or method, says the comments are stale, wrong, or disagree with the code, or asks which tags a docblock needs and in what order. Also use when a signature changes and its docblock has to follow. Not for README or prose documentation, which is writing-documentation.
---

<!-- Last updated: 2026-09-11T19:05+10:00 -->

# Writing docblocks and inline comments

The block above a declaration, and the comments inside a function body. Prose
documentation is `writing-documentation`.

`references/comments.md` decides whether a comment earns its place. This skill
decides which tags, in what order, in what syntax, and whether the block still
matches the code.

The reader is a maintainer who knows the language, the framework and the
codebase, and meets the block in editor hover or autocomplete while doing
something else. They came for the one fact the signature does not carry.
Explaining what they already know buries it.

## 1. Detect the convention

Nearest signal wins.

1. The two nearest docblocks in the same file.
2. Linter config: `.phpcs.xml*`, `phpcs.xml*`, `.eslintrc*`, `tsconfig.json`,
   `.stylelintrc*`.
3. The language reference below.

Where 1 and 2 disagree, follow the config and name the file you read it from.
Where the file has neither, name the default you applied.

| Extension | Reference |
|---|---|
| `.php` | `references/php.md` |
| `.js`, `.jsx`, `.ts`, `.tsx` | `references/javascript.md` |
| `.css`, `.scss`, `.sass` | `references/css-sass.md` |
| anything else | `references/generic.md` |

## 2. Decide whether it needs a block

Document every visible class, member and method. Skip one only where there is
nothing to say beyond its own name, such as a getter returning a stored value.
A getter that lazily initialises, hits a cache, or returns a value in a unit its
name does not state has something to say.

WordPress documents every function regardless of visibility. Check the ruleset
before applying the exception.

The gate decides whether a block should exist, not whether an existing one gets
deleted.

| Situation | What to do |
|---|---|
| You are writing or fixing that block anyway | Rewrite a name-restating summary into one that says something, or drop it where there is nothing to say |
| The function was not part of the ask | Leave the block. Name it in your reply with `file:line` |

## 3. Write the block

Three parts, in this order, in every language covered here.

1. **Summary.** One sentence. What it does, not how. Ends with a period. No
   markup.
2. **Description.** Optional. The constraint, the trap, or the reason a caller
   would get it wrong. Blank comment line above it. Two or three lines. Past
   that, it belongs in the code or an ADR.
3. **Tags.** In the order the language mandates. Read the reference. WordPress
   PHP and WordPress JavaScript use different orders.

Use the shortest form that carries a fact. The signature beats a tag, a tag
beats a description sentence, and a fact the signature already states is
written nowhere. Each fact appears once, in the part where it is most useful:
the type lives in the tag or the signature and not again in the description,
and `@return` does not restate the summary.

Summary rules:

- The summary is the only part that appears in indexes, editor hover and
  autocomplete. Front-load it. "Returns the trimmed excerpt, or an empty string
  when the post is password-protected" survives truncation.
- Never open with a phrase that delays the verb: "This method", "This function
  is used to", "A `Foo` is a", "Helper that", "Used to", "Responsible for",
  "It is important to note". Start at the verb, or at the noun the reader
  wants.
- Keep it impersonal. Spend direct address only where the block records a
  choice: "prefer `get_the_excerpt()` here; this one skips the filter
  deliberately."
- Past roughly eight tag rows with no description, the finding is that the
  function has too many parameters. Say so.

The block records the current state, and nothing the reader already knows.
Drop what the language or framework does: what `WP_Query` is, what a Promise
resolves to. Drop the history: what the code used to do, which bug the rewrite
fixed, which pass of a session produced it, what an earlier draft got wrong.
If the block is longer than the function, you are telling a story.

The reading evidence behind this section is in
`../writing-documentation/references/attention.md`.

## 4. Inline comments

- A comment sits directly above the line or block it explains, at the same
  indentation, with no blank line between. In CSS an end-of-line comment on the
  declaration is correct.
- **Multi-line comments open with `/*`, never `/**`.** A parser reads `/**` as a
  DocBlock. WordPress states this for PHP and JavaScript alike.
- A warning needs its consequence. "Careful here" says nothing. "Careful: this
  runs before `init`, so `get_option()` returns the default" says what breaks.
- Never comment out code. `references/comments.md` covers it.

## 5. Verify the block against the code

```sh
scripts/check-docblocks.sh <file> [<file>...]
```

Checks `@param` names against the signature in name, count and order across PHP,
JavaScript and TypeScript. Exits non-zero on disagreement, and names blocks it
could not parse instead of passing them. A destructured parameter is the usual
unparseable case and needs a manual read.

It does not check:

1. Declared types against the signature, including nullability and defaults.
2. `@return` against every return path. WordPress forbids `@return void` outside
   the bundled themes and the core PHP compatibility shims.
3. `@throws` against what the body can raise.

Run the project's linter for those and quote its output: `phpcs` with
WordPress-Docs, `eslint` with `eslint-plugin-jsdoc`, `tsc`.

Exit 0 means the parameter names match. The script read none of your prose. For
each sentence describing behaviour the reader cannot see in the signature, open
what it describes and name what you read. Where you cannot open it, cut the
sentence, or write the narrower claim you can defend and say which claim you
softened. Cutting is the cheaper fix.

## When a signature changes

The docblock changes in the same edit, not as a follow-up. Add the changelog tag
the language uses. WordPress wants a second `@since` with the version and a
sentence describing the change, with the original line left in place.
