---
name: writing-pull-requests
description: Use when writing or rewriting a pull request description, PR title, or MR description. Triggers on "write the PR", "PR description", "raise a PR", "open a PR", "describe this branch", "summarise this change for review", "what should the PR say", and on being asked to improve a thin or stale PR body. Also use when asked how to word a commit message for a branch that will become a PR.
hooks:
  PreToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "\"${CLAUDE_SKILL_DIR}/scripts/prose-tells-guard.sh\""
---

<!-- Last updated: 2026-09-28T12:08+11:00 -->

# Writing pull requests

Produces two things, in this order: a title, a body.

The reader is a reviewer who knows the codebase, has the Files tab open, and
reads several of these a day. They came for two things the diff cannot give
them: the intent, and the evidence it works. Everything else in the body delays
those.

The prose rules in `references/prose.md` apply to the title and the body. Read
the body against its word list before handing it over.

## Output contract

**"Write the PR", "raise a PR" and "open a PR" all mean open it.** Check step 1's `PUSHABLE` verdict first. On `PUSHABLE: NO`, say why in one line and stop, because the missing remote or the failed auth is what the user fixes first. Otherwise run `gh pr create --title "<title>" --body-file <file>`, or `gh pr edit` where step 1 found a PR already open, and reply with the URL.

**Write a file instead of opening only when the user asks for the text alone.** "Don't open it", "just the text" and "write it as text" ask for that, and so does a question like "what should the PR say". Write to `/tmp/pr-<repo>-<branch>.md`, with any `/` in the branch name replaced by `-`. Outside the repo, the file cannot be committed, and the user reads it there before pasting it into GitHub. The first line is `Title: <title>`, then a blank line, then the body as raw CommonMark. Reply with the path, and run no `gh` command. On `PUSHABLE: NO`, add one line saying the branch cannot be pushed yet.

Opening a PR is not permission to commit or push. Where the working tree or local commits hold changes the remote lacks, ask before committing or pushing them: the body describes a diff the PR would not yet show.

**The title and body describe the code change and nothing else.** Leave out any line crediting an AI tool or assistant, including an attribution line or `Co-Authored-By` trailer the harness supplies, and anything about how the text was written. The same holds for a commit message.

**On a revision, show only the sections that changed.** Reprinting a body the reader has already been through in order to alter two lines buries the two lines. A behaviour a new commit adds gets its own entry, not a clause on the end of an existing one.

That limits the reply, not the review. Run step 5 over the whole title and body, not only the new commits: a gap an earlier revision left is still in front of the reviewer. A section that fails step 5 counts as changed.

- **Text only:** rewrite the file in full, because the user pastes the whole body. Reply with the path and the names of the sections that changed.
- **`gh pr edit`:** GitHub replaces the whole body, so start from the live one (`gh pr view --json body`). Rewrite only the sections the change touches or step 5 fails, and keep what a human wrote that the diff still supports. Pass the result with `--body-file`, and a new title with `--title` where the old one fails step 2 or step 4. Then reply with the URL and each changed section in its own fenced block.

**Write it once, in the shape below.** Gather the context and read the diff first, then write the title and the body in that order. Do not draft loosely and reshape it into the contract afterwards: a reshaped draft keeps the first draft's structure and quietly loses the parts the contract asks for.

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

## 2. Title

Imperative, present tense, no trailing period. "Delete the FizzBuzz RPC and replace it with the new system", not "Deleting the FizzBuzz RPC and replacing it".

A template's own title rule outranks this section. Read the HTML comment at the top of the template file before writing a title. A required issue-key prefix, a banned word, or a length limit lives there. A deploy or release script may reject a title that breaks one.

Add a Conventional Commits prefix only where step 1 found the repo already uses one.

A title passes when a reader who knows the codebase but not this branch could
guess which files it touches. `references/anatomy.md` holds Google's rejected
examples, each true and none specific.

A commit message stays a label. A commit that grows into three paragraphs is a PR body in the wrong file.

## 3. Body

**Where the repo has a template, it is the body. Start there, not here.** Step 1 prints it under `=== TEMPLATE ===`.

Open the file and read it. The script prints its headings, and the headings are the least of it. The instruction for each section sits in an HTML comment beneath it, and that is where a team states what it wants and what will reject the PR.

Its sections replace the four below, in its order, under its headings, including any rule it states about the title. Fill every one. Where a section does not apply, say why in a clause rather than deleting the heading: a missing heading reads as an oversight, an answered one reads as a decision. One exception: a section only a human can supply, such as screenshots, a recording or a demo link. Leave the heading with nothing beneath it. Prose explaining why you attached no screenshot is addressed to the person who has to attach it, and it occupies the space the screenshot goes in.

The four parts below are the fallback for a repo with no template. They are also the standard for what the content inside a template's headings has to do, whatever those headings are called.

Four parts. Drop one only where the change genuinely has nothing to put in it. `references/anatomy.md` carries what each holds, with the source quotes.

Use the shortest form that carries a fact: a table row beats a bullet, a bullet
beats a sentence, a sentence beats a paragraph. Each fact appears once, in the
part where the reviewer needs it. The file list is on the Files tab and the
ticket number is under linked issues, so neither is repeated in prose.

**What changed.** The mechanism, not a file listing. A reviewer has the file list on the Files tab and cannot get the intent anywhere else.

**Why.** The problem the change solves. Give the standing reason, not the route you took to it. The why is "post metadata belongs to the template that frames it". The chronology is "we narrowed the scope after the first pass", which is invisible in the diff and useless to a reviewer. Name any shortcoming: it gets a faster review than leaving a reviewer to find the gap. Summarise what a linked document decided rather than linking it alone, because access restrictions and retention policies outlive the link.

A PR carrying more than one concern gives each its own reason. Where a reason is in neither the diff, the commits nor the conversation, ask the user for it. Only the author knows a decision the code does not show, so do not invent one, and do not leave the concern without one.

**How to verify.** The commands you ran and what they returned, plus what a reviewer should run. "Tests pass" is a claim; `47 passed, 0 failed` is evidence. A command listed without its output is a claim too.

Cover what the What changed part describes. Each behaviour there gets a check you ran, or a clause naming it as unchecked. A claim scoped wider than what ran is false, however many results follow it: "each hook was tested" when one was not.

Each result sits beside the command that produced it. Where reproducing one needs setup a reviewer would rebuild by hand, commit the check with the change or give the full command.

Every piece of that evidence has to be reproducible from the branch. A gate failing on an untracked local file, or a figure from a script you did not commit, is not part of the change. A reviewer cannot run it, so it reads as noise and invites a question you then have to answer. Cite the result, or leave it out.

**Status is a checkbox, not a sentence.** Where the template carries a pre-review checklist, an unticked box already says the step is outstanding. Saying it again in prose ("steps 1 to 6 have not been run in a browser", "no screenshots attached") addresses the author rather than the reviewer. It is the first thing a reader skips. Leave the box unticked and write nothing. Only where there is no checklist does an untested area need a clause of its own.

**Where to start.** Only where the diff has more than one file worth reading. Two lines do the work, and the second is the one people omit:

```markdown
**Start at** `src/Queue/Dispatcher.php:88`, which holds the retry decision.
**Skip** `tests/__snapshots__/`, which is a mechanical regeneration.
```

**Linked issues.** A closing keyword only where merging finishes the issue. Otherwise reference it plainly, so merging does not close work still open.

The body records the change, not the drafting. Drop what you tried first, how
many runs the tests took, what an earlier version of the branch did, and what a
rebase removed. None of it is in the diff, so none of it is reviewable.

Banned openers, in the title and the body: "This PR", "This change", "Small",
"Quick", "Just", "As discussed", "It is worth noting", and any apology for the
size, which occupies the line where the split proposal should be. Start at the
verb.

`references/examples.md` has a before and after at three sizes. Take the shape
and none of the figures.

## 4. Size check

Step 1's script prints the verdict against Google's thresholds: 100 lines is comfortable, 1000 is too large, and spread counts separately, so 200 lines across 50 files is also too large.

Two exceptions, both surfaced by the script: a whole-file deletion counts as roughly one line of review, and a trusted refactoring tool's output is verified rather than read.

Over the threshold with neither exception applying, state the line count and propose a split by concern. Do not compensate with a longer description.

Lines are not the only measure. Google defines a small change by focus, not by line count, and `references/anatomy.md` has the quote. List the independent concerns in the diff: changes that could merge or revert apart. More than one means proposing a split, whatever the line count. Where the user keeps them together, each concern gets its own entry in What changed, its own reason and its own check, and the title names each.

The split proposal goes to the user in the reply, never into the body. The body describes the change as the user chose to ship it.

## 5. Self-review before handing it over

1. **Does every claim in the body match the diff?** A described behaviour that is not in the change costs a reviewer the most time.
2. **Does every verification claim match a command you ran?** Read each "every", "each" and "all" in How to verify against the commands, and name what did not run.
3. **Does every concern have its own reason and its own check?** A reason you could not find is a question for the user, not a gap.
4. **Is there anything in the diff the body does not mention?** A stray debugging line, a version bump, a reformatted file.
5. **Where the PR was already open, is everything a human wrote and the diff
   still supports still there?** Say what you removed and why.

Report what you checked and what you found.
