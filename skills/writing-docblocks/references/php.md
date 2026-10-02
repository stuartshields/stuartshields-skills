<!-- Last updated: 2026-10-02T12:41+11:00 -->

# PHP docblocks

The WordPress handbook governs any WordPress tree. phpDocumentor governs
everything else. Do not cite PSR-5 or PSR-19; both are Draft and neither was
accepted.

## Tag order, WordPress functions and methods

Omit what does not apply. Never reorder.

1. Summary
2. Description
3. `@ignore`
4. `@since`
5. `@access` (private APIs only)
6. `@see`
7. `@link`
8. `@global`
9. `@param`
10. `@return`

## Formatting

- Tabs for indentation inside the block, as in the surrounding file. Spaces only
  to align columns, below. `comments.md` carries the rule.
- Wrap at 80 characters of text.
- Nothing between the block and the declaration.
- Align the type, variable and description columns within a tag group.

## Summary and description

**Summary:** one sentence, two lines maximum, ending in a period. No HTML, no
Markdown. Write "img element", never the literal tag. The summary says what the
element does or when it fires. A why, where there is one, goes in the
description. The handbook says "Avoid describing "why" an element exists", and
this skill departs from it; `comments.md` says when a why earns its place.

**Description:** optional, and usually omitted. Markdown allowed, HTML
prohibited outside code examples. Blank comment line before and after lists and
code samples.

## `@since`

Three digits: `@since 3.9.0`. The one exception is `@since MU (3.0.0)`.

When a function changes materially, add another `@since` line with the new
version and a sentence in sentence case describing the change. The original line
stays. The stack of them is the changelog.

## `@param`

Format: `@param type $variable Description.`

Optional parameters say so before the description and end with a period:

```
Optional. This value does something. Accepts 'post', 'term', or empty.
Default empty.
```

Array arguments use hash notation, with a `@type` line per key.

## `@return`

Every possible return type, each with a description ending in a period.

A function that returns nothing takes `@return void`, so every block states what
comes back. The WordPress handbook reserves `@return void` for core's bundled
themes and PHP compatibility shims; this skill uses it everywhere, and
phpDocumentor permits it.

## Inline comments

- Single line: `//` with a leading space.
- Multi-line: open with `/*`, never `/**`, which the parser reads as a DocBlock.
- Wrap at 80 characters.

## phpDocumentor, outside WordPress

Same three parts: summary, description, tags. The summary carries no formatting
or inline tags. Summary and description separate by a blank line, or by a period
followed by a newline. The description ends at the first tag. Asterisks align
vertically.

Beyond the WordPress set, the tags that come up are `@throws`, `@deprecated`,
`@api`, `@var`, `@example` and `@version`.

## Checking it

`phpcs` with the WordPress-Docs ruleset decides most of this. Run it and quote
the output.

## Sources

- https://developer.wordpress.org/coding-standards/inline-documentation-standards/php/
- https://docs.phpdoc.org/3.0/guide/guides/docblocks.html
- https://www.php-fig.org/psr/ (PSR-5 listed as Draft)
