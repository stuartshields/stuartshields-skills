<!-- Last updated: 2026-09-28T09:14+11:00 -->

# External style guides

The four guides step 1 of `SKILL.md` offers, and what each settles.

Every quotation below was read from the live page on 2026-08-23. Where a guide does not settle something, this file says so instead of filling the gap.

| Guide | Dialect | Reader | Good for |
|---|---|---|---|
| [Google developer documentation style guide](https://developers.google.com/style) | US: "Use standard American spelling and punctuation" | second person: "Use second person: 'you' rather than 'we.'" | product and API docs, and the widest coverage of the four |
| [Fuchsia documentation style guide](https://fuchsia.dev/fuchsia-src/contribute/docs/documentation-style-guide) | US: "Write clear, direct U.S. English using simple words and concise sentences" | second person: "Write directly to the reader in the second person" | engineering docs living in a repo, since it settles line length and code-block conventions |
| [GitLab documentation style guide](https://docs.gitlab.com/development/documentation/styleguide/) | US: "Write in US English with US grammar", tested by Vale's `British.yml` | second person, and it rejects "GitLab allows you" for direct address | docs kept honest by CI, because each rule maps to a Vale test |
| [GOV.UK style guide](https://guidance.publishing.service.gov.uk/writing-to-gov-uk-standards/style-guides/a-to-z-style-guide/) | UK: "use 'organise' not 'organize', 'modelling' not 'modeling'" | second person | the British-English answer, and the strictest of the four on lists and plain language |

## Quotations worth having to hand

- Fuchsia on headings: "All titles and section headers (#, ##, ###) must use sentence case."
- Fuchsia on tense: "State facts and system behavior in the present tense. Avoid future tense ('will')."
- Fuchsia on numbered lists: use them "only when sections are meant to be executed in sequence, such as in a tutorial", and bullets "for non-sequential topics, such as an overview, concept page, index page, or reference document".
- Fuchsia on line length: 80 characters for prose, 100 for code, with URLs, link definitions and frontmatter exempt.
- GOV.UK on bullets: "always use a lead-in line", lower-case starts, no semicolons at line ends, no full stop after the last bullet. Numbered steps end in full stops and need no lead-in line.
- GitLab on list punctuation: "Give all items the same punctuation... Do not use a period if the item is not a complete sentence. Use a period after every complete sentence."
- GitLab on parallelism: "Make all items in the list parallel. For example, do not start some items with nouns and others with verbs."
- GitLab on sentence length: fewer than 20 words where possible, aiming at an eighth-grade reading level. GitLab states the reading level in grades and does not name a metric, so cite it that way.
- GOV.UK on voice: "Use the active voice rather than the passive voice."

## Where they disagree

The dialect table in `formatting.md` carries the three divergences: numbers below ten, negative contractions and quotation marks. The British column follows GOV.UK; the US column follows Google and GitLab.

One thing none of them settled in what was read: whether British-English prose takes the serial comma. Google requires it ("Use serial commas"). The GOV.UK A to Z entries read on 2026-08-23 did not cover it. So a British project decides it once and records the decision, and nobody should claim a guide made that call.
