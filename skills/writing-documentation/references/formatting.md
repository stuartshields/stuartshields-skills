<!-- Last updated: 2026-09-11T19:05+10:00 -->

# Formatting

Defaults to apply without asking, the house rules that override them, and the handful of choices the dialect answer decides. Sources are named in `style-guides.md`.

## Apply these without asking

All four guides checked agree, so a question here spends attention the dialect question needed:

- Sentence case for every heading, page title included.
- Active voice, with the actor named.
- Present tense for facts and behaviour. No "will" for what the system does now.
- Numbered list for a sequence somebody executes in order.
- Bulleted list for everything else, unless a house rule below says otherwise.
- Parallel construction inside a list: all items start with the same part of speech.
- One punctuation pattern per list. Full stops after complete sentences, none after fragments.
- A lead-in line before a bulleted list, ending in a colon.
- A language tag on every fenced code block.

## House rules

These override the defaults above, and they exist because the defaults left the choice open.

### A stated count becomes a numbered list

Where the prose says how many items follow ("four questions", "three checks"), number them. An edit that adds a fifth item to a stated four then shows up in the numbering instead of hiding in a bullet. A stated count of eight is numbered.

Where no count is stated and no sequence exists, bullet.

A table already lets the reader count its rows, so a stated count above a table needs no numbering. The rule bites on bullets.

### Prose flows, structure carries counts

Continuous prose is the default for an argument or an explanation, and a list is what you reach for when the items are genuinely parallel and countable. The test is in step 4 of `SKILL.md`: two or more consecutive sentences of the same shape, reorderable without loss, were a list all along.

### Change carrier after about a dozen lines

Prose, bulleted list, numbered list, table, code block, worked example and block quotation are the carriers available. Running one of them past roughly twelve consecutive lines is the point to look for a reason to switch.

A heuristic, and the weakest rule in this file. `attention.md` says what it rests on.

1. **The alternation is a symptom, not the goal.** Pick the carrier that fits the content. A section that has run twelve lines of prose is usually doing two jobs, and splitting it is the real fix.
2. **A genuine fourteen-line explanation stays fourteen lines.** Breaking an argument into bullets to hit a rhythm makes it worse.

## Line length

Hard wrapping is a per-repo decision, and mixing wrapped and unwrapped paragraphs produces diffs nobody can read. Fuchsia wraps prose at 80 characters and code at 100. The author's own skills do not wrap.

Match the file you are editing. Starting a new file, match its neighbours, and say which file you matched.

## Decided by the dialect answer

| Choice | British | US |
|---|---|---|
| Numbers below ten | numerals from 2 up, words at the start of a sentence | spell out one to nine |
| Negative contractions | avoid `can't`, `don't` | allowed |
| Interface labels and titles | single quotes | double quotes |
| Direct quotation | double quotes | double quotes |
| Dates | 23 August 2026 | August 23, 2026 |
| Serial comma | record a decision, since no guide read here settles it | required |

## Markdown mechanics

- A table suits pairs of related values. A table too wide for the terminal becomes a list.
- Link text describes the destination. No bare URLs in prose, and no "here".
- Indentation: tabs in the body, spaces inside YAML frontmatter, where a tab is a parse error. Where the project's own convention differs, the project wins.
- Anything over roughly 30 lines, code samples and long tables included, moves to its own file with a teaser left behind. Step 4 of `SKILL.md` covers this.
