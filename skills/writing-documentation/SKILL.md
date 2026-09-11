---
name: writing-documentation
description: Use when writing or rewriting documentation the user will actually read or ship, including README.md, docs/*.md, package docs, and skill bodies. Also use when they say the docs are verbose, bloated, disconnected, hard to scan, or out of date, or when a change needs its documentation updated to match. Also use when asked whether a document should be British or US English, first or third person, or which style guide it follows. Not for inline code comments.
hooks:
  PreToolUse:
    - matcher: "Write|Edit"
      hooks:
        - type: command
          command: "\"${CLAUDE_SKILL_DIR}/scripts/prose-tells-guard.sh\""
---

<!-- Last updated: 2026-09-11T20:35+10:00 -->

# Writing documentation

For documentation someone reads: `README.md`, `docs/*.md`, package docs, skill bodies. Inline code comments are `writing-docblocks`, which is a different standard.

## Prose style

`references/prose.md` governs every sentence written here: punctuation, the substance rules, and the word list a checker would hold. Read it once before drafting. Do not carry a copy of it into a project doc; point at the project's own style note where one exists.

`scripts/prose-tells-guard.sh` flags em dashes and assertion vocabulary on every Markdown write. It is declared in this file's frontmatter, so it registers the first time this skill is invoked in a session and stays on for the rest of it. Where it flags a word used in its genuine technical sense, or an em dash inside a quotation, say so and keep it. Rewording around a correct word to satisfy a checker makes the prose worse.

A checker catches words, not shapes. `references/tells.md` holds the sentence shapes that pass every rule here and still read as generated. Read it during the line-level pass in step 4.

## 1. Interview before you draft

Four questions, in one `AskUserQuestion` call, which takes four at most:

1. British or US English?
2. Which person for the reader, and does the author appear?
3. Which of the four document types?
4. Which external guide settles what you did not ask?

Ask all four together. A dialect answer arriving after the first draft respells every sentence in it, and a person answer arriving late rewrites all of them.

Where the repo already records the answers, in its `CLAUDE.md` or a style note, read them from there and say which file you read them from.

Reference the chosen guide; do not copy it into the repo. Record only where the project departs from it, with the reason. `references/style-guides.md` compares the four worth referencing.

`references/interview.md` carries the options, the author's recorded defaults, and what changes in the text when an answer flips.

## 2. Name the document type

Four types, and they are not interchangeable. Mixing them is the most common reason a document fails to help anyone.

| Type | Reader is | Opens with |
|---|---|---|
| Tutorial | learning by doing | the thing they will have built |
| How-to guide | solving a specific problem | the problem it solves |
| Reference | looking something up | the signature, the flags, the shape |
| Explanation | trying to understand | the question being answered |

**Lead with what the reader gets, not where the code came from.** A first paragraph explaining the project's origin ("extracted from a real client project") spends the most-read line on context nobody needs yet.

That holds for a README and a how-to guide. It does not hold for reference, where opening with the signature is correct and a value proposition is padding.

A README is usually a how-to guide with a reference section attached. Say which sections are which before outlining.

## 3. Agree a contract before drafting

Ask for a contract rather than a tone. "Concise and clear" cannot be checked, so it cannot be met or missed. A contract can:

> British English, second person for the reader with first person for choices, value-first opener, single requirements block, at most 5 bullets per section, sentences under 20 words, front-loaded at every level, one action per numbered step, examples over 30 lines lifted to their own file.

State it back in one line before writing, with the interview answers in it, and flag any section that cannot fit it.

Defaults where the user has no preference, from GitLab: sentences under 20 words, prose around an eighth-grade reading level. GitLab states the level in grades and names no metric, so cite it in grades.

### Shape terms

1. **Front-load at four levels.** Document, section, paragraph, sentence. Most documents do the first and skip the rest.
2. **One action per numbered step.** "Install the CLI and authenticate" is two steps wearing one number, and a reader interrupted between them loses the second.
3. **A summary block above anything past 100 lines.** The reader decides whether to continue from it.

### Voice terms

Limits alone produce prose that breaks none of them and still reads as though nobody wrote it. Name the voice in terms you can check by reading.

- **First person for the choices you made.** "I would not skip that step" beats "that step matters more than it sounds".
- **Second person for what the reader does**, including permission to disagree with you.
- **No sentence whose only job is to introduce the next one.**
- **Give the consequence rather than saying there is one.**

Two of those are countable, so count them:

1. **Direct address at least once per section.** Not once per document. A section with no "you" in it has stopped talking to anybody.
2. **First person wherever the section records a choice, and in the opener whether or not it looks like one.** Somebody decided to build this rather than use the thing that already existed, and that decision is what a reader is weighing. Scoped to choices alone, this rule never fires on the most-read text on the page.

`references/attention.md` carries the effect sizes. This is the best-evidenced rule here and the one most likely to be dropped as decoration.

### Substance terms, which are what stop AI slop

Every term above constrains shape: where a point sits, how long a sentence runs, whether a reader is addressed. A draft can satisfy all of them and still read as generated, because none of them asks whether the text says anything about this particular thing. These three do, and they are countable.

1. **Every feature claim carries a checkable specific**: a number, a default, a mechanism, or a named cost. The failure has a name, marketese: "exaggeration, subjective claims, and boasting, rather than just simple facts."
2. **The document names one thing it does not do**: a limitation, an unsupported case, or which tool to use instead. A document with no boundary in it has not been used in anger.
3. **A person appears in the first screen.** The voice rule above, with its trigger widened to reach the opener.

Padding is not neutral. The reader spends attention rejecting an unearned claim, which is time taken from the text that mattered.

Avoid the superlatives "best, simplest, fastest, never, and always". Treat "ensure" and "guarantee" as claims you will stand behind. Google's rule: "The safest approach is always to write factually and objectively, limiting what you say to verifiable information."

`references/tells.md` holds the sentence shapes that produce this failure. `references/attention.md` holds the measurements.

### Emotion attaches to stakes, not to decoration

A sentence carrying feeling has to change what the reader does. Emotionally interesting but inessential material reduces recall of the content around it.

| Passes | Fails |
|---|---|
| "I lost an afternoon to this before working out the cache was stale." | "Caching is one of the two hard problems, as the joke goes." |
| "Skip this and the build succeeds locally and fails in CI." | "This next part is the fun bit." |

The left column is a consequence the reader can act on. The right column is atmosphere, and it costs them the paragraph it sits in.

## 4. Draft in two passes

Mixing structural and line-level editing produces unfocused work.

**Structural pass.** Section order, consolidation, what gets lifted out.

- Every fact once, in the section where the reader needs it. Where it appears twice, it stays in the earlier, more specific section. If the skill set appears under "What's included", it does not also appear under "How it works".
- Cut what the reader already knows. Step 2's reader column says who they are. A how-to guide for a WordPress plugin does not explain what a hook is, and a README does not explain what npm does.
- Prerequisites collapse into one "Requirements" block, not spread across "What this assumes", "Compatibility" and "Notes".
- Examples past roughly 30 lines move to their own file with a short teaser left behind.

**Every section is a re-entry point.** Attention leaves partway through and comes back at a heading, so the structure has to survive being entered anywhere.

1. **Headings lead with the words carrying the information.** "Configuring the cache" over "Configuration", "When the build fails in CI" over "Troubleshooting". A heading naming a category has told the reader nothing.
2. **No section depends on having read the one above it.** Where it genuinely does, its first line says what it is assuming.

**Line-level pass.** Sentence shape and bullets. Read `references/tells.md` here.

- One idea per sentence. Cut compound modifiers and "which" clauses hiding a second clause.
- **A paragraph of parallel sentences is a list.** Two or more consecutive sentences of the same shape, reorderable without loss, are a list the reader has to assemble themselves.
- **Reordering is the test.** If it does not matter which sentence comes first, stop writing prose. `references/formatting.md` settles bullets against numbers.
- **For a fact, the shortest carrier wins.** A table row beats a bullet, a bullet beats a sentence, a sentence beats a paragraph. An argument stays prose.
- **Banned openers:** "It is important to note", "It is worth noting", "Notably", "To be clear", "In plain terms", "In this section", "Let me walk you through", "As we'll see". Delete the opener and keep the sentence after it. `references/tells.md` holds the shapes a list cannot catch.
- A bullet that wraps to three terminal lines is a paragraph. Make it one, or split it.
- Do not write a bullet that restates the one above it.
- Sections past about five bullets are usually doing two jobs. A genuine list of eight flags stays a list of eight flags.

## 5. Reader-test before handing it over

Three tests, and they fail in different ways. Run substitution first: it takes seconds and it fails the drafts that are not worth walking.

| Test | Catches |
|---|---|
| Substitution | A claim that is true of anything |
| Walk | A step the reader cannot complete |
| Scan | A point buried where nobody looks |

### The substitution test

Swap the product name for a competitor's and reread. Every sentence that is still true belongs to no particular piece of software, and the reader learned nothing from it.

A subjective claim survives substitution because it was never about this thing. A fact does not, because a fact names a version, a default, a mechanism or a limit.

This opener passes every shape rule in step 3:

> Retry failed webhooks without writing the retry logic yourself. You supply a transport, and the queue handles the rest.
>
> - Configurable backoff strategies
> - Dead-letter routing with no setup
> - Survives process restarts

It survives substitution whole. Nothing distinguishes this library from any other queue, and the three bullets name no default, no schedule and no cost.

The repair puts the specifics back:

> Retries webhooks that failed on a 5xx or a timeout, so a deploy on the receiving end does not cost you events.
>
> - Backoff is exponential and fixed at 2s, 8s, 32s, then dead-letter
> - Retry state lives in Redis, so a Redis restart drops anything mid-backoff
> - 4xx is terminal on purpose: a 422 will not become valid on a retry

Substitute a competitor's name into that and the second bullet is a lie about them. That is the test passing. That bullet is also the limitation the contract asks for, sitting in the feature list rather than in a section nobody reaches.

### The walk test

Pick the first task the document promises. Follow it literally, using only what the document says, as though the codebase is unfamiliar.

The finding is the first point where a reader would need something the document has not given them. It usually takes one of these shapes:

- an unstated prerequisite
- a command that assumes a directory
- a variable introduced without saying where it comes from

### The scan test

Read only the headings, the bold text and the first sentence of each paragraph. If the document's main claim and its first action do not survive that pass, the document fails. The fix is never to add more text. Move what matters up into the parts that get read.

Run this one last. It reads shape rather than content, so it finds different faults from the other two.

Report what you tested and what stopped you. Where nothing stopped you, say that, and say which path you walked. "I read it and it seems fine" is a different claim.

## Updating an existing document

Diagnose before rewriting, because the two failures need opposite fixes:

- **Verbose** means the same idea appears several times. Cut.
- **Disconnected** means the reader wades through caveats before reaching the point. Reorder, lifting the value paragraph and the quick start above the prerequisites.

Then run both passes. Check every documented command still works before leaving it in place: one that fails is worse than an absent one, because it gets trusted.

The document records the current state. Drop what it used to say, which rewrite changed it, and what the earlier version got wrong. A changelog carries that where the repo keeps one.
