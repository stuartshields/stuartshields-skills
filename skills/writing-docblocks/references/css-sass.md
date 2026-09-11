<!-- Last updated: 2026-08-31T10:00+11:00 -->

# CSS and SASS comments

Stylesheets have no signature to document, so a block comment partitions the
file instead. SassDoc adds an API layer for mixins and functions.

## WordPress CSS

**Comment liberally.** File size is not a reason to strip comments from source;
that is what minification and `SCRIPT_DEBUG` are for.

**Numbered section headers**, so a section is searchable by number:

```css
/**
 * #.# Section title
 *
 * Description of section, whether or not it has media queries, etc.
 */
```

A newline goes before and after the block. A long stylesheet takes a table of
contents at the top using the same numbers.

**Inline comments** carry no blank line separating them from the code:

```css
/* This is a comment about this selector */
.another-selector {
	position: absolute;
	top: 0 !important; /* I should explain why this is so !important */
}
```

Every `!important` wants its reason on the same line, because the next reader's
first instinct is to delete it.

**Wrap long comments at 80 characters**, broken by hand.

Do not write CSSDoc into a WordPress tree.

## SassDoc

For `.scss` and `.sass`, SassDoc documents mixins, functions, variables and
placeholders. It reads `///` line comments, not `/** */` blocks.

```scss
/// Chunks a list into sub-lists of a given length.
///
/// @access public
/// @group List
/// @param {List} $list The list to process.
/// @param {Number} $size [1] The length of each chunk.
/// @return {List} The new list of chunks.
@function chunk($list, $size: 1) {
```

Square brackets give a default value, as in JSDoc.

### The annotation set

21 annotations:

`@access`, `@alias`, `@author`, `@content`, `@deprecated`, `@example`,
`@group`, `@groupDescription`, `@ignore`, `@link`, `@name`, `@output`,
`@parameter`, `@property`, `@require`, `@return`, `@see`, `@since`, `@throw`,
`@todo`, `@type`

Aliases: `@param` for `@parameter`, `@returns` for `@return`, `@prop` for
`@property`.

One use per item is enforced for `@access`, `@content`, `@deprecated`,
`@group`, `@output`, `@return` and `@type`. The rest may repeat.

### Which annotations to write

`@param` and `@return` on every public mixin or function. `@group` once the file
has more than a handful. `@output` on a mixin, since what it emits cannot be
inferred from its name. `@access private` on anything callers should not reach.

## Checking it

`stylelint` handles formatting. Nothing checks SassDoc annotations against the
signature, so step 5 of the skill is manual here: read the argument list and the
`@param` lines side by side.

## Sources

- https://developer.wordpress.org/coding-standards/wordpress-coding-standards/css/
- https://github.com/SassDoc/sassdoc/tree/master/src/annotation/annotations
