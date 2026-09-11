<!-- Last updated: 2026-08-30T07:50+11:00 -->

# Writing for attention

The reading evidence behind `writing-documentation`, `writing-docblocks` and
`writing-pull-requests`. All three point here. Read it when deciding whether
one of their drafting rules can bend, because the citation says what the rule
was protecting and how much it was worth.

This file holds only what all three share. Each skill states its own
application in its own body, so a rule and its evidence are never written out
three times.

The reader this assumes is not a careless one. They are reading at the rate
everybody reads at, on something long enough that they will leave partway and
come back.

## What the reader actually does

Nielsen Norman Group measured it: people read at most 28% of the words on a
page, and 20% is the likelier figure. The F-shaped scan appears under three
conditions, one of which is the writer's fault: unformatted text with no
bolding or subheadings. Their explanation of the mechanism is the useful
sentence. "In the absence of any signals to guide the eye, they will choose the
path of minimum effort."

Two findings sharpen this for a reader with ADHD.

1. **Comprehension tracks sustained attention.** Adults with ADHD in the ICLS
   2022 study scored lower on sustained attention and lower on reading
   comprehension. They also rated the same texts as harder, and had less
   confidence in answers they had got right. The comprehension gap moved with
   the attention measure rather than with anything about decoding.
2. **Satiation arrives faster on uniform material.** Zentall's optimal
   stimulation work found people with ADHD satiate to stimuli sooner than
   controls, and named the conditions: "rote, long, or repetitive tasks".

So write for someone who will drop out midway and re-enter at a heading. That
single assumption generates most of what follows.

## Three levers, and what each is worth

### Voice, which is worth the most

Mayer's personalization principle is the largest effect in this file.
Conversational style beat formal style on transfer tests in 11 of 11
experiments, median `d = 1.11`. A wider set of tests replicated it 14 times out
of 17, median `d = 0.79`.

The operationalisation is mechanical rather than artistic. Mayer's manipulation
is at the level of "your" instead of "the", direct address instead of
description, and an author who is present in the sentence. You do not need to
be charming. You need to be talking to somebody.

Two boundary conditions are reported, and both narrow where it pays: the effect
weakens for high-prior-knowledge readers and for long lessons. That is why each
skill spends voice in a different place, and why none of them spends it
everywhere.

### Signalling and segmenting, which are worth a lot and cost nothing

The GOV.UK content principles collect the evidence behind conventions most
writers already half-follow.

- **Segmenting.** Dee-Lucas (1995): breaking information into more, shorter
  pages produces better understanding than fewer, longer ones.
- **Signalling.** Spyridakis, on headings, introductions, overview sentences,
  tables of contents and lists: these "helped readers' comprehension, speed and
  search tasks".
- **Both together.** Morkes and Nielsen (1997) found text made "extremely
  scannable" let users complete tasks faster and with fewer errors.

Nielsen Norman Group's countermeasure list is the concrete version, and three
items on it are the ones technical writing usually misses:

1. "Include the most important points in the first two paragraphs on the page."
2. "Start headings and subheadings with the words carrying most information."
3. "Use bullets and numbers to call out items in a list or process."

Item 2 is what makes something re-enterable. A reader who resumes at a heading
gets whatever that heading tells them and nothing else.

### Carrier alternation, which is the weakest of the three

Nobody has measured "structure variety", and this file will not pretend
otherwise. What exists is the satiation finding above plus the signalling
evidence, and the heuristic is inferred from the pair rather than tested as
itself.

The inference: uniform blocks are the rote-and-repetitive condition, and they
are also the unsignalled condition that produces the F-scan. Changing carrier
fixes both at once.

**Heuristic.** After roughly a dozen consecutive lines carried by one form,
change form. Prose, bulleted list, numbered list, table, code block, worked
example and block quotation are the forms available.

The alternation is a side effect, not the goal. Each carrier has a job, and
`formatting.md` decides which one a passage wants. Where a section genuinely
needs fourteen lines of prose, it gets them, and the finding to act on is that
the section is doing two jobs.

This lever does not transfer to a docblock, where the parser fixes the carrier.

## Emotion attaches to stakes, not to decoration

The seductive details effect is why "make it warmer" is a request to be careful
with. Emotionally interesting but inessential material has negative effects on
recall and comprehension of the content around it, and it cuts the time readers
spend on the base text.

Harp and Mayer's distinction is the one to hold. Adjuncts that raise
**emotional** interest impede learning. Adjuncts that raise **cognitive**
interest assist it.

The test is whether the sentence changes what the reader does:

| Passes | Fails |
|---|---|
| "Skip this and the build succeeds locally and fails in CI." | "This next part is the fun bit." |
| `// Runs before init, so get_option() returns the default.` | `// Careful here!` |
| "1,840 lines across 34 files, over the 1,000-line guidance. I can split it." | "Sorry this one's a monster." |

The left column names a consequence. The right column is atmosphere, and it
costs the reader the line it sits in.

Narrative is the partial exception, and only in prose. A meta-analysis over 75
samples and more than 33,000 participants found stories better understood and
better recalled than essays. The same literature reports the advantage
inverting for high-prior-knowledge readers, so a narrative opener suits a
tutorial and not a reference page, a docblock or a PR.

## COGA patterns these rules implement

W3C's *Making Content Usable* is the accessibility standard behind the contract
terms in `writing-documentation` step 3, the docblock description rule, and the
PR tl;dr.

| Pattern | What it asks for |
|---|---|
| 4.4.5 Keep text succinct | "Break content into short blocks" |
| 4.4.8 Provide summary | A condensed version of anything long |
| 4.4.9 Separate each instruction | One action per step, never two combined |
| 4.4.10 Use white spacing | Breathing room between sections |
| 4.6.2 Make short critical paths | Fewest steps between the reader and the goal |
| 4.6.3 Avoid too much content | Cut rather than collapse |

## What is not established

Worth not claiming, since each is asserted somewhere on the open web.

1. **There is no Home Office accessibility poster for ADHD.** The
   `UKHomeOffice/posters` set covers anxiety, autism, deafness, dyslexia, low
   vision, motor disabilities and screen readers. Directory listed on
   2026-08-28. Several secondary sources imply an ADHD poster exists.
2. **"Structure variety" has no measured effect of its own.** See the carrier
   alternation section for what it is inferred from.
3. **A reading-level target does not address attention.** GitLab's eighth-grade
   level and its 20-word sentence limit measure difficulty. Something can be
   easy to understand and still be something nobody finishes. Two problems, two
   sets of rules.
4. **No study measures docblock or PR-description comprehension directly.**
   Applying this file to either carrier takes prose-reading evidence somewhere
   it has not been tested. The nearest domain-specific sources are Google Java
   §7.2 on the summary fragment, quoted in `writing-docblocks`, and Google's
   small-CL reasoning, quoted in `writing-pull-requests`. The second is stated
   as experience rather than measured.

## Sources

Read on 2026-08-28. The Google, GitHub and W3C quotes were re-verified against
the live pages on 2026-08-30.

- [W3C, Making Content Usable for People with Cognitive and Learning Disabilities](https://www.w3.org/TR/coga-usable/)
- [Nielsen Norman Group, F-shaped pattern of reading: misunderstood, but still relevant](https://www.nngroup.com/articles/f-shaped-pattern-reading-web-content/)
- [Nielsen Norman Group, How users read on the web](https://www.nngroup.com/articles/how-users-read-on-the-web/)
- [GOV.UK content principles: conventions and research background](https://www.gov.uk/government/publications/govuk-content-principles-conventions-and-research-background/govuk-content-principles-conventions-and-research-background), which carries the Dee-Lucas, Spyridakis and Morkes and Nielsen citations
- [Google Java Style Guide, section 7](https://google.github.io/styleguide/javaguide.html)
- [Google, Small CLs](https://google.github.io/eng-practices/review/developer/small-cls.html)
- [Mayer, A personalization effect in multimedia learning](https://tecfa.unige.ch/tecfa/teaching/methodo/Mayer2004)
- [Cambridge Handbook of Multimedia Learning, chapter 14: principles based on social cues](https://www.cambridge.org/core/books/abs/cambridge-handbook-of-multimedia-learning/principles-based-on-social-cues-in-multimedia-learning-personalization-voice-image-and-embodiment-principles/3841340D8AD820C26DBCD39AE664BCEC)
- [Cognitive and affective effects of seductive details in multimedia learning](https://nschwartz.yourweb.csuchico.edu/COGNITIVE%20AND%20AFFECTIVE%20EFFECTS%20OF%20SEDUCTIVE%20DETAILS%20IN%20MULTIMEDIA%20LEARNING.pdf), carrying the Harp and Mayer distinction
- [Memory and comprehension of narrative versus expository texts: a meta-analysis](https://link.springer.com/article/10.3758/s13423-020-01853-1)
- [Sources of difficulties in reading comprehension in adults with ADHD, ICLS 2022](https://repository.isls.org/handle/1/8895)
- [Zentall, Optimal stimulation as theoretical basis of hyperactivity](https://files.eric.ed.gov/fulltext/ED407791.pdf)
- [UKHomeOffice/posters, accessibility dos and don'ts](https://github.com/UKHomeOffice/posters/tree/master/accessibility/dos-donts)
