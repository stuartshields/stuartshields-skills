<!-- Last updated: 2026-09-11T19:05+10:00 -->

# Prose rules

Applies to everything written under this skill, and to the title and body a pull request gets. `writing-pull-requests` and `writing-docblocks` point here rather than carrying a copy.

## Punctuation

- Punctuate with what the sentence wants: a colon before a list or an explanation, a full stop between two independent clauses, a comma for an appositive, parentheses for a genuine aside. That set covers the work an em dash is usually reached for. Where none of the four fits, the sentence wants rewriting rather than repunctuating.
- En dashes set numeric and word ranges (`K–10`, `2016–2025`). Use them there and read them as ordinary punctuation. This stands as its own instruction because a permission folded into a neighbouring restriction gets suppressed along with it.

## Substance

- Show significance instead of asserting it. Generated prose claims something matters rather than demonstrating it: "crucial" with no consequence named, "robust" with no failure it survives. Supply the consequence and the adjective stops being needed.
- Give the reason, not the label. In shipped copy, telling the reader that a choice was made adds nothing they can act on. The constraint behind it does.
- One thought per sentence. Rule-of-three lists and paired clauses stacked for rhythm read as generated. Vary the length instead.

## Words to check

A checker's list, not a rule. Every entry has a legitimate use somewhere: quoting a source that uses em dashes, unlocking a keychain, financial leverage, robustness testing. The skill's `scripts/prose-tells-guard.sh` holds the same list in `scripts/prose-scan.awk` and reports against it on every Markdown write once the skill has been invoked in the session. Before that, or where the hook is not running, read the draft against the table once, during the line-level pass in step 4 of `SKILL.md`.

| Finding | Words or shapes |
|---|---|
| Asserts significance | seamless, delve, vibrant, bustling, nestled, testament, holistic, synergy, tapestry, with their inflections |
| Needs a usage check, since a technical sense exists | robust, leverage, elevate, crucial, unlock |
| Set phrase | "not just X, but Y", "more than just", "dive into", "in today's", "pivotal moment", "marks a shift", "serves as", "underscores the" |
| Throat-clearing | "here's the thing", "here's why", "it's worth noting", "at the end of the day", "when it comes to", "in a world where", "let that sink in", "at its core" |
| Punctuation | an em dash anywhere; an en dash not sitting between two numbers |
| Length | a sentence past 30 words |

The length threshold is a checker's compromise. The target is 20 words, and a check firing past 20 fires on roughly a tenth of real sentences, which gets it ignored. Past 30 fires on one in a hundred, and those are the ones that are hard to read. The 21 to 30 band is a judgement call.

The fix is usually the sentence, not the word: give the consequence instead of calling something crucial. A long sentence wants a full stop, and several parallel ones in a row usually want to be a list. Where a flagged word is used in its genuine technical sense, or an em dash sits inside a quotation, say so and keep it. Rewording around a correct word to satisfy a checker makes the prose worse.

`tells.md` holds the sentence shapes no word list can catch.
