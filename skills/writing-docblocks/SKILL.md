---
name: writing-docblocks
description: Use when adding or fixing a docblock, docstring, or inline comment in code, including PHPDoc, JSDoc, TSDoc, WordPress inline documentation, CSS section comments and SassDoc. Also use when the user says a function is undocumented, asks you to document a class or method, says the comments are stale, wrong, or disagree with the code, or asks which tags a docblock needs and in what order. Also use when a signature changes and its docblock has to follow. Also use before authoring a new file, class or module that will carry docblocks, because the comment budget is easier to hold while writing than to recover afterwards. Also use whenever an edit adds or rewrites a comment while the stated task is something else, such as a bug fix, a refactor, a rename, or a styling change. The comment is almost never the headline of the request that produces it, so this is the case that gets missed. Not for README or prose documentation.
hooks:
  PreToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "\"${CLAUDE_SKILL_DIR}/scripts/docblock-guard.sh\""
---

<!-- Last updated: 2026-09-27T13:05+10:00 -->

# Writing docblocks and inline comments

The block above a declaration, and the comments inside a function body. Prose
documentation is a different standard and is not covered here.

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

Write a block only where it tells the reader something the name and signature
do not. A getter returning a stored value needs nothing. A getter that lazily
initialises, hits a cache, or returns a value in a unit its name does not state
has something to say.

Where the ruleset requires a block on every function, as WordPress does, write
the one-line summary and the tags it requires. Nothing more.

The gate decides whether a block should exist, not whether an existing one gets
deleted.

| Situation | What to do |
|---|---|
| You are writing or fixing that block anyway | Rewrite a name-restating summary into one that says something, or drop it where there is nothing to say |
| The function was not part of the ask | Leave the block. Name it in your reply with `file:line` |

## 3. Write the block

Default to the summary line and the required tags. A block that is one line
long reads faster than a paragraph, and says more.

1. **Summary.** One line. What it does, or for a hook, when it fires. Ends with
   a period. No markup.
2. **Description.** Usually omitted. One or two lines, only when the code does
   something the summary cannot hold, such as a side effect or an edge-case
   return. Blank comment line above it.
3. **Tags.** Only those the language or ruleset requires, in the order it
   mandates. Read the reference. WordPress PHP and WordPress JavaScript use
   different orders. Each tag description is a short phrase.

Say what the code does, not why. The WordPress standard: "Avoid describing
"why" an element exists, rather, focus on documenting "what" and "when" it does
something." A reason for the approach goes in the commit or the PR, because it
outlives the code it defends and nothing in the build notices.

Each fact appears once. The signature beats a tag, a tag beats a description
sentence, and a fact the signature already states is written nowhere. The type
lives in the tag or the signature, and `@return` does not restate the summary.

```php
/**
 * Calculates the reading time for a post.
 *
 * This function is used to work out how long a post takes to read. It uses
 * 200 words per minute because that is the average adult reading speed, and
 * rounds up so that short posts never show zero minutes.
 *
 * @param int $post_id The ID of the post to calculate the reading time for.
 * @return int The reading time for the post in minutes.
 */
```

becomes:

```php
/**
 * Returns the reading time in minutes at 200 words per minute, minimum 1.
 *
 * @param int $post_id Post ID.
 * @return int Minutes.
 */
```

Summary rules:

- The summary is the only part that appears in indexes, editor hover and
  autocomplete. Front-load it. "Returns the trimmed excerpt, or an empty string
  when the post is password-protected" survives truncation.
- Never open with a phrase that delays the verb: "This method", "This function
  is used to", "A `Foo` is a", "Helper that", "Used to", "Responsible for",
  "It is important to note". Start at the verb, or at the noun the reader
  wants.
- Past roughly eight tag rows, the finding is that the function has too many
  parameters. Say so.

Drop what the reader already knows: what the language or framework does, what
`WP_Query` is, what a Promise resolves to. Drop history: what the code used to
do, which bug the rewrite fixed. If the block is longer than the function, cut
it.

## 4. Inline comments

- One line, directly above the line or block it describes, at the same
  indentation, with no blank line between. In CSS an end-of-line comment on the
  declaration is correct.
- It says what the code does, where the code does not make that plain. If a
  better name would make the comment unnecessary, rename instead.
- **Multi-line comments open with `/*`, never `/**`.** A parser reads `/**` as a
  DocBlock. WordPress states this for PHP and JavaScript alike.
- A warning names what happens. "Careful here" says nothing. "Runs before
  `init`, so `get_option()` returns the default" does.
- Never comment out code. `references/comments.md` covers it.

`scripts/docblock-guard.sh` flags reasons, history, and runs over three prose
lines on every code write. It is declared in this file's frontmatter, so it
registers the first time this skill is invoked in a session and stays on for
the rest of it. Advisory, never blocking.

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

## 6. Measure the budget

`references/comments.md` puts it at about 15% of a file. Count it rather than
judge it, because the ratio is invisible while you write and obvious afterwards.

```sh
f=<file>; echo "$(( $(grep -cE '^\s*(/\*|\*|//)' "$f") * 100 / $(wc -l < "$f") ))% comment"
```

Scaffolding counts toward that figure: `/**`, `*/`, the blank `*` separators and
the tag rows. A file of many short functions therefore sits high by
construction, so separate the two before cutting anything.

```sh
grep -cE '^\s*(\*|//) [A-Za-z`]' <file>   # prose lines only
```

A file that is two-thirds scaffolding has a different problem from one that is
two-thirds prose, and only the second is narration. Cut reasons and paragraphs
first.

## When a signature changes

The docblock changes in the same edit, not as a follow-up. Add the changelog tag
the language uses. WordPress wants a second `@since` with the version and a
sentence describing the change, with the original line left in place.

A comment describing a list, a count or a structure follows the same rule.
"All four groups" outlived the addition of a fifth and still read as correct,
because nothing checks a sentence against the thing it counts. Changing the
thing changes the sentence, in the same edit.
