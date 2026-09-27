<!-- Last updated: 2026-09-28T09:14+11:00 -->

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

### Where to start

GitHub:

> Guidance is especially helpful when a pull request touches many files or
> requires a specific review order.

### Linked issues

GitHub:

> Use issue-closing keywords when a pull request should close an issue after
> merging.

## Sources

Google quotes verified against the live page on 2026-08-30.

- https://google.github.io/eng-practices/review/developer/cl-descriptions.html
- https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/getting-started/helping-others-review-your-changes
