<!-- Last updated: 2026-09-11T19:05+10:00 -->

# Sentence shapes that read as generated

Structural patterns, not a word list. `prose.md` holds the words, and a
project's prose hook flags them on every Markdown write, which is the right
instrument for a denylist: deterministic, no judgement to distort, no context
cost. A shape cannot be matched that way, so it lives here.

Read this during the line-level pass in step 4, and when a draft passes every
contract term and still reads wrong.

## Why these cost something

Every pattern below asks the reader to do work that returns them no
information. `attention.md` carries the measurements.

## Binary contrast

A negation used to set up its own reversal.

| Shape | Example |
|---|---|
| "Not X, but Y" | "This is not a queue, but a scheduler." |
| "X isn't the problem. Y is." | "Latency isn't the problem. Retries are." |
| "The answer isn't X. It's Y." | |
| "It feels like X. It's actually Y." | |
| "stops being X and starts being Y" | |

**Repair:** state Y. "This is a scheduler." The negated half was scaffolding.

## Negative listing

Naming what a thing is not, several times, before naming what it is. The reader
holds three rejected ideas to reach one real one.

**Repair:** open with the real one.

## Dramatic fragmentation

| Shape | Example |
|---|---|
| "[Noun]. That's it. That's the [thing]." | "One flag. That's it. That's the fix." |
| "X. And Y. And Z." | |
| Sentence fragments for emphasis | |

**Repair:** complete sentences. A fragment used for weight is asking the layout
to carry an argument the words did not make.

## Rhetorical setup

Announcing an insight in place of delivering it.

| Shape | Why it fails |
|---|---|
| "What if [reframe]?" | The reader did not ask |
| "Here's what I mean:" | The next sentence was going to say it anyway |
| "Think about it:" | Instructs the reader to do the writer's work |
| "And that's okay." | Grants permission nobody sought |

**Repair:** delete the setup and keep the sentence after it.

## False agency

An inanimate subject given a human verb. This is the most common tell in
technical prose, because it lets a sentence describe a decision without naming
who made it.

| Shape | Repair |
|---|---|
| "the decision emerges" | Someone decided. Name them, or write "you decide". |
| "the data tells us" | Someone read it and drew a conclusion. |
| "the config takes over" | Something reads the config. Say what. |
| "the error surfaces" | Where? Name the log, the stream, the exit code. |
| "the culture shifts" | People changed what they do. |

**Repair:** find the actor and put them at the front. Where no specific actor
fits, "you" puts the reader in the seat, which the personalization evidence in
`attention.md` says is the strongest move available anyway.

## Narrator from a distance

| Shape | Repair |
|---|---|
| "This happens because…" | Name the mechanism |
| "People tend to…" | "You will…" or cite who |
| "Nobody designed this." | Say what was designed and by whom |

## Meta-commentary

Sentences about the document rather than about its subject. The banned openers
in step 4 of `SKILL.md` are the word-level list; "The rest of this guide
explains…" and "But that's another topic" are the same shape mid-document.

**Repair:** delete. The heading already announced the section. This is the same
rule as the voice term in step 3 forbidding a sentence whose only job is to
introduce the next one.

## Vague declarative

A sentence asserting that something is significant without naming the
significance. The word list in `prose.md` catches the common vocabulary; the
shape is broader than the words.

| Shape | Repair |
|---|---|
| "The implications are significant." | Name one implication |
| "The reasons are structural." | Name a reason |
| "This is where it gets interesting." | Be interesting |

The word-level version is in step 3 of `SKILL.md`: avoid the superlatives, and
reserve "ensure" and "guarantee" for claims you will stand behind.

## The justifying tail

A clause appended to explain why the preceding statement matters.

> Start without Redis and your first `enqueue()` call hangs instead of
> erroring, which costs more time to diagnose than to prevent.

**Test:** delete everything after the last comma. Where the sentence still
stands, the tail was the writer reassuring themselves that the point landed.

## The subjectless feature list

Bullets that are noun phrases with no subject, no number and no cost.

| Fails | Passes |
|---|---|
| Configurable backoff strategies | Backoff is exponential and fixed at 2s, 8s, 32s |
| Dead-letter routing with no setup | Failed events land in the `dead_letters` table after the third retry |
| Survives process restarts | Retry state lives in Redis, so a Redis restart drops anything mid-backoff |

The right column survives the substitution test in step 5. The left column does
not.

## What this file does not tell you to do

Three rules that circulate with the patterns above and are wrong for
documentation. They are listed so a later reader does not add them back.

1. **"Never open a sentence with a Wh- word."** Step 4 recommends "When the
   build fails in CI" as a heading, because a heading that leads with the
   information beats one that names a category. The Wh- ban would forbid it.
2. **"Two items beat three."** Step 4 sets five bullets as the heuristic and
   says a genuine list of eight flags stays a list of eight. A reference page
   enumerating options is not padding.
3. **"Cut every adverb."** "Deliberately", "explicitly" and "roughly" carry
   meaning that costs a clause to replace. The emphasis crutches worth removing
   are already in the hook's word list.

## Sources

Read on 2026-08-28.

- [Nielsen Norman Group, How users read on the web](https://www.nngroup.com/articles/how-users-read-on-the-web/)
- [Nielsen Norman Group, Concise, scannable, and objective: how to write for the web](https://www.nngroup.com/articles/concise-scannable-and-objective-how-to-write-for-the-web/)
- [Google developer documentation style guide, Excessive claims](https://developers.google.com/style/excessive-claims)
- [Google developer documentation style guide, Voice and tone](https://developers.google.com/style/voice)
