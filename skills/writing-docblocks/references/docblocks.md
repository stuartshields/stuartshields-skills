<!-- Last updated: 2026-10-02T12:41+11:00 -->

# Docblocks

What a docblock says and what it leaves out, for steps 2 and 3 of `SKILL.md`. Tag order and syntax live in the language references. Comments inside a body follow `inline-comments.md`.

## Who reads it

Someone calling the function who will never open its body. They meet the block in editor hover, in autocomplete, in a static analyser's output or in generated reference docs. So the block is a contract: everything a caller has to know to use the function correctly, and nothing about how the body gets there.

An inline comment is the other case. It serves someone who already has the code on screen and needs the reason behind one line.

Check a block against the body. A rewrite of the body that keeps the same inputs, outputs and side effects should leave the block untouched. If it would not, the block is describing the implementation.

## What it carries

- **Summary.** One sentence starting with a third-person verb, such as "Returns" or "Registers". Constants, properties and file headers take a noun phrase. `SKILL.md` step 3 has the other summary rules.
- **Parameters and return.** The declared type already says what kind of value it is. Use the description for what the value means: its unit, the values it accepts, its range, its default, and what an empty or null value does.
- **Hooks.** Each argument the hook passes, and the point at which it fires. Someone filtering it from a theme has nothing else to read.
- **`@since`.** The version the code ships in, not a date. A client project uses its own version numbers. Add one to a new public function, method or hook wherever the file's other blocks carry it.
- **What a caller would not expect.** A trap, an approach that was ruled out, or the reason behind a decision, in at most three lines of description. Leave out anything that follows from the types, the name or the conventions already in use. If someone fluent in the surrounding code would not be caught out without the sentence, delete it.

## One fact, one place

When two functions share the same trap or the same ruled-out approach, explain it once, on the function the fact belongs to, and point to it from the other. If editing one block keeps forcing an edit to another, the fact is stored twice.

When this code builds on a library or another block, its docblock says what this code does with it. What the library does internally belongs to the library's own documentation.

## Example

Before:

```php
/**
 * This function gets the name of an author.
 *
 * It calls get_userdata() with the ID, reads display_name from the result,
 * and falls back to user_login if that is empty.
 *
 * @param int $user_id The user ID.
 * @return string The name.
 */
```

After:

```php
/**
 * Returns the name to show for an author.
 *
 * @param int $user_id User ID.
 * @return string Display name, the login where none is set, or '' for an unknown user.
 */
```

The rewrite stops narrating `get_userdata()` and tells the caller what the original left out: what comes back for a user with no display name, and for one that does not exist.

## Anti-patterns

- Walking through the body, or listing the functions it calls.
- Opening with "This function" or "This method". The summary is about the function already.
- A description that repeats the type: `@param int $user_id Integer user ID.`
- Internal detail of the body in the block of a public function.
- `@param` rows out of step with the signature. `scripts/check-docblocks.sh` finds them.
- Justifying a decision by naming a dependency's internal functions. Say what the dependency does that matters here.
- Copying a trap another block already explains, instead of pointing at it.
- Explaining what a library does on its own account.
- Documenting what a reader fluent in the types, names and conventions would assume anyway.

## Indentation inside the block

Indent with tabs inside the block, as in the rest of the file: the leading whitespace, a wrapped tag description, and nested `@type` rows. Aligning the type, variable and description columns within a tag group is the one place spaces go, because a tab's width varies by editor and breaks the alignment. A file in a format that requires spaces, such as Python or YAML, keeps them.
