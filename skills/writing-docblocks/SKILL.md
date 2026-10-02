---
name: writing-docblocks
description: Use when adding or fixing a docblock, docstring, or inline comment in code, including PHPDoc, JSDoc, TSDoc, WordPress inline documentation, CSS section comments and SassDoc. Also use when the user says a function is undocumented, asks you to document a class or method, says the comments are stale, wrong, or disagree with the code, or asks which tags a docblock needs and in what order. Also use when a signature changes and its docblock has to follow. Also use before authoring a new file, class or module that will carry docblocks, because the comment budget is easier to hold while writing than to recover afterwards. Also use whenever an edit adds or rewrites a comment while the stated task is something else, such as a bug fix, a refactor, a rename, or a styling change. The comment is almost never the headline of the request that produces it, so this is the case that gets missed. Not for README or prose documentation.
hooks:
  PreToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "sh -c 'g=$HOME/.claude/skills/writing-docblocks/scripts/docblock-guard.sh; [ -x \"$g\" ] && exec \"$g\"; exit 0'"
---

<!-- Last updated: 2026-10-02T12:41+11:00 -->

# Writing docblocks and inline comments

The block above a declaration, and the comments inside a function body. Prose
documentation is a different standard and is not covered here.

Two kinds of comment, two sets of rules. `references/docblocks.md` covers the
block above a declaration, which describes a contract to a caller who will not
read the body. `references/inline-comments.md` covers a comment inside the body,
which explains one decision to a reader already looking at the code. This skill
holds the procedure: which tags, in what order, in what syntax, and whether the
block still matches the code.

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
2. **Description.** Usually omitted. One to three lines, only for what a
   caller would not expect: a gotcha, a rejected alternative, the reason for a
   decision. Blank comment line above it.
3. **Tags.** Only those the language or ruleset requires, in the order it
   mandates. Read the reference. WordPress PHP and WordPress JavaScript use
   different orders. Each tag description is a short phrase spent on what the
   value means: units, accepted values, defaults, what empty or null does.

`references/docblocks.md` decides what goes in and what stays out. A block
describes the contract, not the body, so rewriting the body without changing its
inputs, outputs or side effects leaves the block alone. The why it carries is
the one a caller would not expect. This departs from the WordPress handbook,
which says "Avoid describing "why" an element exists", on purpose: the why is
the one fact a reader cannot recover from the code.

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
 * Returns the reading time in minutes, never less than 1.
 *
 * 200 words per minute, the average adult reading speed.
 *
 * @param int $post_id Post ID.
 * @return int Minutes.
 */
```

The 200 keeps its line because the code shows the number and not why it is that
number. "Rounds up" goes, because `ceil()` already says it.

Summary rules:

- The summary is the only part that appears in indexes, editor hover and
  autocomplete. Front-load it. "Returns the trimmed excerpt, or an empty string
  when the post is password-protected" survives truncation.
- Never open with a phrase that delays the verb: "This method", "This function
  is used to", "A `Foo` is a", "Helper that", "Used to", "Responsible for",
  "It is important to note". Open with a third-person singular verb:
  "Retrieves", "Returns", "Filters". A constant, a property or a file header
  takes a noun phrase instead.
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
- It says what the code cannot: the reason behind an approach, an exception or
  a value. `references/inline-comments.md` lists the comments worth writing and
  where a longer reason goes instead. If a better name would make the
  comment unnecessary, rename instead.
- It makes sense on its own. A reader arrives from a stack trace or a diff, so
  no "as above" and no "same reason" pointing at another comment.
- **Multi-line comments open with `/*`, never `/**`.** A parser reads `/**` as a
  DocBlock. WordPress states this for PHP and JavaScript alike.
- A warning names what happens. "Careful here" says nothing. "Runs before
  `init`, so `get_option()` returns the default" does.
- Never comment out code. `references/inline-comments.md` covers it.

`scripts/docblock-guard.sh` flags history and runs over three prose lines on
every code write. It runs from the first invocation of this skill in a
session and stays on for the rest of it. Advisory, never blocking.

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
2. `@return` against every return path, including `@return void` on a function
   that returns nothing.
3. `@throws` against what the body can raise.

Run the project's linter for those and quote its output: `phpcs` with
WordPress-Docs, `eslint` with `eslint-plugin-jsdoc`, `tsc`.

Exit 0 means the parameter names match. The script read none of your prose. For
each sentence describing behaviour the reader cannot see in the signature, open
what it describes and name what you read. Where you cannot open it, cut the
sentence, or write the narrower claim you can defend and say which claim you
softened. Cutting is the cheaper fix.

## 6. Measure the budget

`references/inline-comments.md` puts it at about 15% of a file. Count it rather
than judge it, because the ratio is invisible while you write and obvious
afterwards.

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
