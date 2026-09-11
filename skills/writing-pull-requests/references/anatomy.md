<!-- Last updated: 2026-08-31T12:20+11:00 -->

# Anatomy of a pull request description

What each part carries, and the source that settles it.

## tl;dr

One sentence, what and why, under 25 words, above everything including a
template.

Not a summary of the body. It is the sentence someone reads in a Slack unfurl,
a notification preview, or a release note, with everything after it cut off.

## Title

Google's rule:

> Short summary of what is being done. Complete sentence, written as though it
> was an order. Follow by empty line.

Imperative, present tense, no trailing period.

Their bad examples, verbatim, because each is a real one someone submitted:

- "Fix bug"
- "Fix build"
- "Add patch"
- "Moving code from A to B"
- "Phase 1"
- "Add convenience functions"
- "kill weird URLs"

Each is true, and none is specific. A title passes when a reader who knows the
codebase but not this branch could guess which files it touches.

The shape to copy:

> RPC: Remove size limit on RPC server message freelist

A scope prefix, an imperative verb, a specific object. The body then explains
why the limit mattered.

## Body

### What changed

The mechanism. A reviewer has the file list on the Files tab and cannot get the
intent anywhere else.

Google: "fill in the details and include any supplemental information a reader
needs to understand the changelist holistically".

### Why

The problem, the approach, and why not the obvious alternative. Google's
wording, which is looser than a checklist:

> It might include a brief description of the problem that's being solved, and
> why this is the best approach. If there are any shortcomings to the approach,
> they should be mentioned. If relevant, include background information such as
> bug numbers, benchmark results, and links to design documents.

Read the modal verbs. Only the shortcomings sentence says "should"; the problem
description and the background are "might" and "if relevant". A description
omitting a benchmark is not incomplete; one hiding a known weakness is.

> If you include links to external resources consider that they may not be
> visible to future readers due to access restrictions or retention policies.

Summarise what the linked document decided. A bare link is a description that
expires.

### How to verify

Commands and their output. "Tests pass" is a claim; `47 passed, 0 failed` is
evidence. Where something was not run, say which and why.

### Where to start

GitHub:

> Guidance is especially helpful when a pull request touches many files or
> requires a specific review order.

Two lines do the work:

```markdown
**Start at** `src/Queue/Dispatcher.php:88`, which holds the retry decision.
**Skip** `tests/__snapshots__/`, which is a mechanical regeneration.
```

The second line is the one people omit and the one that saves the most time.
GitHub also suggests naming the kind of review wanted.

### Linked issues

> Use issue-closing keywords when a pull request should close an issue after
> merging.

Closing keywords only where merging finishes the issue. Where the PR is one
part of a larger issue, reference it without a keyword.

## What a template changes

A repo template's sections are the team's decision and outrank this anatomy.
Fill every one. Where one does not apply, say so in a clause rather than
deleting the heading. The tl;dr still goes above it.

## Sources

Google quotes verified against the live page on 2026-08-30.

- https://google.github.io/eng-practices/review/developer/cl-descriptions.html
- https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/getting-started/helping-others-review-your-changes
