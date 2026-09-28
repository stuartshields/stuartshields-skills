<!-- Last updated: 2026-09-28T11:55+11:00 -->

# Worked examples

Three constructed descriptions, at three sizes, each paired with the weak
version it replaces.

## Read these for shape, never for content

**Every repository, file path, line number, test count, timing, issue number
and event count below is invented.** None of it was observed. These show where
each part of a description sits and what a filled-in part reads like.

Take the structure. Take none of the figures.

A figure that cannot be traced to a command you ran or a file you read does not
go in. `SKILL.md` step 5 checks every claim in the body against the diff, and a
number imported from this file is what that check is looking for.

## Small: a one-file fix

**Before**

```markdown
Fix bug
```

Google names this one: "'Fix bug' is an inadequate CL description. What bug?
What did you do to fix it?" It is true and it is useless.

**After**

```markdown
Trim the excerpt on word boundaries rather than character count.

`wp_trim_words()` was being called after a `substr()` that had already cut the
string mid-word, so the final token was discarded as a fragment. Archive
listings lost the last word of every excerpt.

Swapped the order: trim to words first, then apply the length cap.

**How to verify**
`composer test -- --filter ExcerptTest` returns `12 passed, 0 failed`.
Manual check on `/blog/` shows full final words on all 10 excerpts.

Fixes #1841
```

The invented parts are the test counts, the excerpt count and the issue number.
The shape around them is the point. One file changed, so there is no Start at
line: the Files tab already routes the reviewer.

The title is the first line of the body here because GitHub takes it
separately. In a text-only file, it takes its own `Title:` line.

## Medium: a feature with a trade-off

**Body**

```markdown
Add exponential backoff retries to the webhook dispatcher.

Endpoints that returned 503 during a deploy had their events discarded, because
the dispatcher treated any non-2xx as terminal. Roughly 400 events were lost in
the March window.

The dispatcher now retries on 5xx and on connection timeouts, backing off
2s / 8s / 32s, then moves the event to the dead-letter table. 4xx stays
terminal, since a 422 will not become valid on a retry.

**Shortcoming:** retry state lives in Redis, so a Redis restart mid-backoff
loses the pending retries. Making it durable needs a schema change, tracked in
#1902.

**How to verify**
`composer test -- --group queue` returns `38 passed, 0 failed`.
`wp queue:dispatch --dry-run` against the staging endpoint shows three retries
then a dead-letter row.

**Start at** `src/Queue/Dispatcher.php:88`, which holds the retry decision, and
`src/Queue/Backoff.php` for the schedule.
**Skip** `tests/__snapshots__/`, a mechanical regeneration.

Refs #1877
```

The shortcoming paragraph is the part most descriptions omit. Google asks for
it plainly: "If there are any shortcomings to the approach, they should be
mentioned." Stating one gets a faster review than leaving a reviewer to find
it.

Note `Refs #1877`, not `Closes #1877`. In this invented scenario the issue
covers durable retry state too, so merging would not finish it.

## Large: over the size threshold

**Before**

```markdown
Big refactor, sorry this one's a monster. Moving code from A to B mostly.
Should be fine, tests pass.
```

Three faults. "Moving code from A to B." is on Google's list of similarly bad
descriptions. The apology is atmosphere that costs the reader a line and tells
them nothing. "Tests pass" is a claim with no output.

**After**

```markdown
Extract Order into OrderTotals, OrderTaxes, OrderShipping and OrderPersistence.

**Size warning: 1,840 lines across 34 files.** Google's guidance puts 1,000
lines as usually too large, and this is over it. Of the total, 1,310 lines are
the mechanical move of existing methods into the four new classes with no
change to their bodies; 530 lines are new interfaces and their tests. It splits
into the four extractions as separate PRs.

**Why now:** checkout tests each needed a seeded database because totals and
persistence sat in one class, so the suite took 4 minutes. It is 40 seconds
after this.

**Shortcoming:** OrderTaxes still reaches for the global tax config rather than
taking it as a constructor argument. Changing that touches the admin screens.

**How to verify**
`composer test` returns `412 passed, 0 failed` (was 412 before, unchanged).
`composer test -- --group checkout` runs in 41s, down from 4m 06s.

**Start at** `src/Order/OrderTotals.php`, the only class whose logic changed.
**Skim** the other three: methods moved verbatim, and
`git diff -M --stat` shows them as renames.
**Skip** `tests/Unit/Order/*Test.php`, new tests for the extracted interfaces.
```

The 1,000-line figure is Google's and real. Every other number here is
invented, and they are internally consistent only because a worked example that
contradicts itself teaches the wrong lesson.

The size warning proposes a split rather than apologising for the absence of
one. That is the behaviour step 4 of the skill asks for: the description names
the problem and hands the decision back.

The reviewer routing does the other half. A 34-file diff where 30 files are
verbatim moves is reviewable once someone knows which four are not.

## The shapes to reuse

This table is the part to carry into real work. Nothing above it is.

| Line | Purpose |
|---|---|
| Imperative title | What a reader sees in the merge log |
| Why paragraph | The problem the change solves |
| `**Shortcoming:**` | What a reviewer would otherwise have to find |
| `**How to verify**` + output | Evidence, not a claim |
| `**Start at**` / `**Skip**` | The routing that saves the most time |
| Size warning + proposed split | Where the diff is over threshold |

## Sources

Quotes verified against the live page on 2026-08-30.

- [Google, Writing good CL descriptions](https://google.github.io/eng-practices/review/developer/cl-descriptions.html)
- [Google, Small CLs](https://google.github.io/eng-practices/review/developer/small-cls.html), for the 1,000-line figure
