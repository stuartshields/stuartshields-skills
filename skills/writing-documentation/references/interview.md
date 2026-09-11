<!-- Last updated: 2026-09-11T19:05+10:00 -->

# The interview

Ask before drafting a word. Put all four questions in one `AskUserQuestion` call, which takes four at most. Asking them one at a time trains the user to stop answering.

Skip the interview only where the repo already records the answers, in its `CLAUDE.md` or a style note. Then say which file you read them from.

## The four questions

1. British or US English?
2. Which person, and for whom?
3. Which document type?
4. Which guide settles what you did not ask?

### 1. British or US English?

Offer: British English, US English, or match what the repo already uses.

The answer decides spelling: the `-ise`/`-ize` and `-our`/`-or` families, `licence` against `license`, doubled consonants in `modelling`. It also decides date order, whether numbers below ten are spelled out, whether negative contractions are allowed, and single or double quotation marks around interface labels. `style-guides.md` lists the three places the guides disagree.

Measure the repo before offering a default:

```
find . -name '*.md' -print0 | xargs -0 grep -hoiE '\b(behaviour|colour|organis[a-z]*|whilst|licence)\b' | wc -l
find . -name '*.md' -print0 | xargs -0 grep -hoiE '\b(behavior|color|organiz[a-z]*|license)\b' | wc -l
```

Report both counts. Counts within a third of each other mean the repo has no convention yet, so the user sets one. A clear majority is the default to offer, named with both numbers so the user can overrule it.

The author's recorded default: British English.

Code keeps its own spelling whatever the answer. `sanitize_text_field`, `JSON.serialize` and the CSS `color` property are identifiers, not prose.

### 2. Which person, and for whom?

Two decisions wearing one word: what the reader gets called, and whether the author appears at all.

| Answer | Reader is | Author is | Fits |
|---|---|---|---|
| Second person, author absent | you | absent | product docs, how-to guides, reference. Google, GitLab and Fuchsia all mandate this |
| Second person, author present | you | I | opinionated guides, skill bodies, ADRs, anything recording a choice |
| First person plural | we | we | team handbooks and contribution guides, where the team is the actor |
| Impersonal third person | the caller, the operator | absent | specs, RFCs, API contracts, compliance text |

Three constraints hold whatever the answer:

1. One name for the reader per document. Second person in the quick start and third person in the reference reads as two authors who never spoke.
2. "We" meaning the team and "we" meaning author-plus-reader are different words. Pick one and hold it.
3. Third person for the reader plus first person for the author does not cohere. If the author says "I chose", the reader is "you".

Google, for a user who asks for "we": "Use second person: 'you' rather than 'we.'"

**One place the answer is not open.** A `SKILL.md` `description` is third person whatever the document around it does. Anthropic's guidance: "Always write in third person. The description is injected into the system prompt, and inconsistent point-of-view can cause discovery problems." So "Processes Excel files and generates reports", never "I can help you process Excel files". The body below the frontmatter is governed by question 2 as normal.

That page asks for consistent terminology, meaning synonyms rather than spellings: do not mix "API endpoint" with "URL" and "API route".

The author's recorded default: second person for the reader, first person singular where the author made a choice.

### 3. Which document type?

Tutorial, how-to guide, reference, or explanation. The table in `SKILL.md` step 2 says what each opens with. Ask rather than infer: the user knows, and inferring wrong costs the outline.

### 4. Which guide settles what you did not ask?

Google, GitLab, GOV.UK, Fuchsia, or the repo's existing docs. `style-guides.md` says what each is good for and what dialect it carries. Naming one answers the hundred questions too small to ask, and gives the reader somewhere to appeal.

## What not to ask

Six things every guide checked agrees on: sentence-case headings, active voice, present tense for behaviour, numbered lists for sequences, bulleted lists otherwise, and parallel construction within a list. `formatting.md` carries them as defaults.

## Record the answers

State them back in one line as part of the contract in `SKILL.md` step 3. Where the project has a `CLAUDE.md`, propose adding the dialect and person to it before drafting.

## Sources

- Anthropic skill authoring best practices, read 2026-08-23: https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices
- Dialect default measured 2026-08-23 across `CLAUDE.md`, `rules/` and the locally authored skills: `behaviour` 17 to `behavior` 9, `colour` 6 to `color` 1.
