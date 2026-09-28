<!-- Last updated: 2026-09-28T11:38+11:00 -->

# Anatomy of a pull request description

The sources behind each part of `SKILL.md` step 3. The instructions live there;
this file holds the quotes that settle them.

## Title

Google's rule:

> Short summary of what is being done. Complete sentence, written as though it
> was an order. Follow by empty line.

Their bad examples, verbatim, because each is a real one someone submitted:

- "Fix bug"
- "Fix build"
- "Add patch"
- "Moving code from A to B"
- "Phase 1"
- "Add convenience functions"
- "kill weird URLs"

The shape to copy:

> RPC: Remove size limit on RPC server message freelist

A scope prefix, an imperative verb, a specific object.

## Body

### What changed

Google: "fill in the details and include any supplemental information a reader
needs to understand the changelist holistically".

### Why

Google's wording, which is looser than a checklist:

> It might include a brief description of the problem that's being solved, and
> why this is the best approach. If there are any shortcomings to the approach,
> they should be mentioned. If relevant, include background information such as
> bug numbers, benchmark results, and links to design documents.

Read the modal verbs. Only the shortcomings sentence says "should"; the problem
description and the background are "might" and "if relevant". A description
omitting a benchmark is not incomplete; one hiding a known weakness is.

> If you include links to external resources consider that they may not be
> visible to future readers due to access restrictions or retention policies.

The questions Google puts to the author, which is why a missing reason is asked
for rather than filled in:

> Why are these changes being made? What contexts did you have as an author
> when making this change? Were there decisions you made that aren't reflected
> in the source code?

GitHub, on a generated summary, which is what this skill produces:

> you should review it carefully and add context that only you know.

### How to verify

GitHub's self-review:

> A self-review can include reading the diff, checking for accidental changes,
> and making sure relevant builds or tests have run.

Google:

> The CL should include related test code.

### Where to start

GitHub:

> Guidance is especially helpful when a pull request touches many files or
> requires a specific review order.

### Linked issues

GitHub:

> Use issue-closing keywords when a pull request should close an issue after
> merging.

## Scope

The concern count in `SKILL.md` step 4. Google defines the right size as "one
self-contained change", which means:

> The CL makes a minimal change that addresses just one thing.

And on what small means, verbatim:

> Remember that smallness here refers the conceptual idea that the CL should be
> focused and is not a simplistic function on line count.

GitHub:

> When a change grows large, consider splitting it into smaller pull requests
> that each serve one purpose.

## Sources

Quotes verified against the live pages on 2026-09-28.

- https://google.github.io/eng-practices/review/developer/cl-descriptions.html
- https://google.github.io/eng-practices/review/developer/small-cls.html
- https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/getting-started/helping-others-review-your-changes
