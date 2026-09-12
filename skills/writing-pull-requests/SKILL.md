---
name: writing-pull-requests
description: Use when writing or rewriting a pull request description, PR title, MR description, or a tl;dr for a change. Triggers on "write the PR", "PR description", "raise a PR", "open a PR", "describe this branch", "summarise this change for review", "what should the PR say", and on being asked to improve a thin or stale PR body. Also use when asked how to word a commit message for a branch that will become a PR.
hooks:
  PreToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "\"${CLAUDE_SKILL_DIR}/scripts/prose-tells-guard.sh\""
---

<!-- Last updated: 2026-09-12T19:32+10:00 -->

# Writing pull requests

Produces three things, in this order: a one-sentence tl;dr, a title, a body.

The reader is a reviewer who knows the codebase, has the Files tab open, and
reads several of these a day. They came for two things the diff cannot give
them: the intent, and the evidence it works. Everything else in the body delays
those.

The prose rules in `references/prose.md` apply to the
title and the body: punctuation, the substance rules, and the word list.
`scripts/prose-tells-guard.sh` reports against that list on every Markdown
write once this skill has been invoked, so a body saved for `--body-file` gets
checked. A body passed inline to `gh` does not, so read it against the list
before printing it.

## Output contract

**Check the branch can be pushed before writing anything.** Step 1's script prints a `PUSHABLE` verdict.

- **`PUSHABLE: NO`.** Say why in one line and stop. Do not print a tl;dr, a title or a body. The missing remote or the failed auth is what the user has to fix first.
- **`PUSHABLE: YES`.** Write the three parts and print them.

Never post, push or open anything without being asked in that turn. Pushable is a statement about the branch, not permission to use it.

**Write it once, in the shape below.** Gather the context and read the diff first, then write the tl;dr, the title and the body in that order. Do not draft loosely and reshape it into the contract afterwards: a reshaped draft keeps the first draft's structure and quietly loses the parts the contract asks for.

## 1. Gather the context

```sh
scripts/pr-context.sh [base-branch]
```

One call returns:

- the push verdict
- the base branch, the diff stat and a size verdict
- the PR template and its required sections
- the repo's commit convention
- any issue reference, and existing PR state

It refuses rather than guessing when HEAD is the base branch itself.

Then read the diff. The script deliberately does not: a description written from a stat line describes the change you assumed.

```sh
git diff <base>...HEAD
```

Three dots compares against the merge base, which is what the PR will show. Two dots reports unrelated commits from the base as part of your change.

Where the diff is too large to read in full, say so in your reply, and read the files carrying logic rather than the generated or vendored ones.

`references/detection.md` has the individual commands, for when the script cannot run or its answer needs checking.

## 2. Write the tl;dr

One sentence. What changed and why. Under 25 words.

```markdown
## tl;dr

Adds retry-with-backoff to the webhook queue so a flaky endpoint no longer
drops events.
```

It goes **above** the template where one exists, and at the top of the body where one does not.

- **What and why, both.** "Adds retry-with-backoff" is half a sentence.
- **No file names, no counts, no ticket numbers.** Those are in the body.
- **Readable with no context.** It gets pasted into Slack and read on a phone with the rest cut off.
- **One sentence.** Where it will not fit in one, the PR is doing two things. See step 5.

## 3. Title

Imperative, present tense, no trailing period. "Delete the FizzBuzz RPC and replace it with the new system", not "Deleting the FizzBuzz RPC and replacing it".

Add a Conventional Commits prefix only where step 1 found the repo already uses one.

A title passes when a reader who knows the codebase but not this branch could
guess which files it touches. `references/anatomy.md` holds Google's rejected
examples, each true and none specific.

A commit message stays a label. A commit that grows into three paragraphs is a PR body in the wrong file.

## 4. Body

Four parts. Drop one only where the change genuinely has nothing to put in it. `references/anatomy.md` carries what each holds, with the source quotes.

Use the shortest form that carries a fact: a table row beats a bullet, a bullet
beats a sentence, a sentence beats a paragraph. Each fact appears once, in the
part where the reviewer needs it. The file list is on the Files tab and the
ticket number is under linked issues, so neither is repeated in prose.

**What changed.** The mechanism, not a file listing. A reviewer has the file list on the Files tab and cannot get the intent anywhere else.

**Why.** The problem, and why this approach rather than the obvious alternative. Name any shortcoming: it gets a faster review than leaving a reviewer to find the gap. Summarise what a linked document decided rather than linking it alone, because access restrictions and retention policies outlive the link.

**How to verify.** The commands you ran and what they returned, plus what a reviewer should run. "Tests pass" is a claim; `47 passed, 0 failed` is evidence. Where something was not run, say which and why.

**Where to start.** Two lines do the work, and the second is the one people omit:

```markdown
**Start at** `src/Queue/Dispatcher.php:88`, which holds the retry decision.
**Skip** `tests/__snapshots__/`, which is a mechanical regeneration.
```

**Linked issues.** A closing keyword only where merging finishes the issue. Otherwise reference it plainly, so merging does not close work still open.

The body records the change, not the drafting. Drop what you tried first, how
many runs the tests took, what an earlier version of the branch did, and what a
rebase removed. None of it is in the diff, so none of it is reviewable.

Banned openers, in the tl;dr and the body: "This PR", "This change", "Small",
"Quick", "Just", "As discussed", "It is worth noting", and any apology for the
size, which occupies the line where the split proposal should be. Start at the
verb.

**A template's sections are the team's decision and outrank this list.** Fill every one. Where a section does not apply, say why in a clause rather than deleting the heading: a missing heading reads as an oversight, an answered one reads as a decision.

`references/examples.md` has a before and after at three sizes. Take the shape
and none of the figures.

## 5. Size check

Step 1's script prints the verdict against Google's thresholds: 100 lines is comfortable, 1000 is too large, and spread counts separately, so 200 lines across 50 files is also too large.

Two exceptions, both surfaced by the script: a whole-file deletion counts as roughly one line of review, and a trusted refactoring tool's output is verified rather than read.

Over the threshold with neither exception applying, state the line count and propose a split by concern. Do not compensate with a longer description.

## 6. Self-review before handing it over

1. **Does every claim in the body match the diff?** A described behaviour that is not in the change costs a reviewer the most time.
2. **Is there anything in the diff the body does not mention?** A stray debugging line, a version bump, a reformatted file.
3. **Does the tl;dr survive alone?** Read it with the rest covered.
4. **Where the PR was already open, is everything a human wrote and the diff
   still supports still there?** Say what you removed and why.

Report what you checked and what you found.
