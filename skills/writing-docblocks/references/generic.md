<!-- Last updated: 2026-09-27T13:05+10:00 -->

# Any other language

The fallback for a language with no entry of its own: Python, Go, Ruby, Rust,
Java, C#, Swift. Find the language's own convention first, from the table at the
bottom. Where you cannot, these rules hold across all of them.

## Whether it needs a block

Step 2 of the skill decides. Where the language's linter requires a block on
every visible member, write the one-line summary only. Two cases never need
one:

- **Self-explanatory members**, such as a `getFoo()`, where there is nothing to
  say but "the foo".
- **Overrides.** The parent's block is the documentation.

A comment inside a function saying what the whole function does belongs above
the function.

## The three-part structure

Universal across PHPDoc, JSDoc, TSDoc, Javadoc and Python docstrings.

1. **Summary.** One line, front-loaded.
2. **Description.** Optional, after a blank line.
3. **Tags or fields.** Last, grouped.

## The summary

The only part shown in class and method indexes. Step 3 of the skill holds:
one sentence, front-loaded, ending in a period, none of the banned openers.
Javadoc is the exception and wants a noun or verb phrase instead, capitalised
and punctuated as though it were a sentence.

## Tag order

Where the language mandates no order, use `@param`, `@return`, `@throws`,
`@deprecated`. None of the four takes an empty description. A bare `@throws
IOException` is worse than omitting the tag, because it looks like
documentation.

Continuation lines indent four or more spaces from the `@`.

## Per-language starting points

| Language | Convention | Tool |
|---|---|---|
| Python | PEP 257, plus a chosen style (Google, NumPy or reST) | `pydocstyle`, `ruff` |
| Go | Doc comments start with the identifier's name | `go doc`, `gopls` |
| Rust | `///` outer, `//!` inner, Markdown body, `# Examples` heading | `cargo doc`, doctests |
| Ruby | RDoc or YARD, and the project picks one | `yard` |
| Java | Javadoc | `javadoc -Xdoclint` |
| C# | XML documentation comments | Roslyn analysers |

Python and Rust run docstring examples as tests. Where that is true, a wrong
example fails the build, which makes the example the strongest part of the
block.

## Sources

- https://google.github.io/styleguide/javaguide.html
