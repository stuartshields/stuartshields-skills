<!-- Last updated: 2026-08-31T10:00+11:00 -->

# JavaScript and TypeScript docblocks

WordPress follows JSDoc 3. TypeScript files in a WordPress tree keep the
WordPress tag order; only the type information changes.

## The opening delimiter

A docblock must open with `/**`. A block opening `/*` or `/***` is skipped by
the parser.

The inverse rule is the one that bites: a multi-line comment that is not
documentation must open with `/*`, or the parser treats it as a DocBlock.

## Tag order, WordPress

Different from the PHP order. Do not carry one across to the other.

1. `@since`
2. `@deprecated`
3. `@access`
4. `@class` / `@constructs`
5. `@augments`
6. `@mixes`
7. `@alias`
8. `@memberof`
9. `@see`
10. `@link`
11. `@global`
12. `@fires`
13. `@listens`
14. `@param`
15. `@yield`
16. `@return`

## Formatting

- Wrap at 80 characters of text. A deeply indented block may wrap later, up to
  120 characters wide in total.
- Align types and names vertically within a tag group.

## Summary and description

**Summary:** one line, one sentence, ending in a period. No markup.

**Description:** optional supplement, ending in a period. Markdown permitted.

## `@since`

Three digits, as in PHP. Additional `@since` lines with versions and
descriptions form the changelog. `svn blame` finds the version something landed
in core.

## `@param`

```js
/**
 * Formats a post excerpt for display.
 *
 * @since 5.4.0
 *
 * @param {string} text          Raw excerpt text.
 * @param {number} [length=55]   Optional. Word count to trim to. Default 55.
 * @return {string} The trimmed excerpt.
 */
```

Square brackets mark an optional parameter, with `=` giving the default.

## TypeScript

Three differences in a `.ts` file:

1. **Do not repeat types.** The signature carries them. Write
   `@param text - Raw excerpt text.` with the TSDoc hyphen, no braces.
2. **`@returns`, not `@return`.**
3. **`@typeParam` documents a generic**, where JSDoc would use `@template`.

TSDoc tags split three ways:

- **Block:** `@param`, `@returns`, `@throws`, `@remarks`, `@example`,
  `@defaultValue`, `@typeParam`, `@privateRemarks`, `@decorator`
- **Modifier:** `@alpha`, `@beta`, `@public`, `@internal`, `@experimental`,
  `@deprecated`, `@sealed`, `@virtual`, `@override`, `@readonly`,
  `@eventProperty`
- **Inline:** `@link`, `@inheritDoc`, `@label`

`@packageDocumentation` marks the block documenting the entry point.

Where `tsconfig.json` or the lint config picks a side, follow it and say which
file you read.

## Checking it

`eslint` with `eslint-plugin-jsdoc` checks tag presence, order and signature
agreement. `tsc` catches type drift. Run one and quote it.

## Sources

- https://github.com/WordPress/wpcs-docs/blob/master/inline-documentation-standards/javascript.md
- https://jsdoc.app/about-getting-started
- https://tsdoc.org/
