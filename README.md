# stuartshields-skills

Six working skills for Claude Code in one plugin, with the two hooks that keep them honest. I built them after the same three failures kept recurring in my own sessions. A review would quietly fix things, documentation read as generated, and the handoff file grew into a changelog.

| Skill | Use it when | Ships |
|---|---|---|
| `handoff` | you are about to `/clear`, wrap up, or resume from `docs/HANDOFF.md` | a template and a long-session nudge hook |
| `audit-vs-fix-discipline` | you ask for a review, audit or investigation and want findings, not edits | a tiered output format, a false-positive list, search traps |
| `writing-documentation` | you write or rewrite a README, a docs page or a skill body | a prose hook, a style-guide comparison, three reader tests |
| `writing-docblocks` | you add or fix a PHPDoc, JSDoc, TSDoc or SassDoc block | per-language tag order and a `@param` checker |
| `writing-pull-requests` | you write a pull request title and body | a context script that prints a push and size verdict, and the same prose hook |
| `testing-skills` | you want to know whether a skill changes what the model does, before shipping or after editing it | a runner that drives an isolated `claude -p` for a control and a treatment arm, and a scenario format each skill's `tests/` directory follows |

Installed as a plugin, every skill is namespaced, so `/stuartshields-skills:handoff` invokes the first one directly. Installed with the skills CLI, it is plain `/handoff`. Either way, Claude also picks each one up from the phrases in its description.

## Install

Two routes. The plugin keeps the skills namespaced and updates through `/plugin`. The skills CLI drops them straight into your skills directory alongside skills from other repositories.

### As a plugin

1. Add the marketplace:

```
/plugin marketplace add stuartshields/stuartshields-skills
```

2. Install the plugin:

```
/plugin install stuartshields-skills@stuartshields-skills
```

3. Run `/reload-plugins` if the install summary asks for it. Skills installed mid-session do not appear until then.

To try a local checkout without installing it:

```
claude --plugin-dir /path/to/stuartshields-skills
```

### With the skills CLI

```
npx skills add stuartshields/stuartshields-skills -g
```

That installs all six into `~/.claude/skills/`. Drop `-g` to install into the current project's `.claude/skills/` instead, or add `--skill handoff` to take one. The CLI symlinks by default; pass `--copy` for a standalone copy. Each skill installs on its own: none reads a file from a sibling's directory.

## Requirements

- `bash` and `jq` for the hooks and scripts. Without `jq` a hook exits silently and its skill still works.
- `awk` for the prose scanner. It runs on the BWK awk that ships with macOS and on GNU awk.
- `git` for the pull-request context script.

## How the hooks work

Three skills declare a hook in their `SKILL.md` frontmatter rather than in a plugin-wide `hooks.json`. Claude Code registers the hook the first time you invoke that skill in a session and keeps it running until the session ends. Each hook finds its script through `${CLAUDE_SKILL_DIR}`, so it runs the same from a plugin install and from `~/.claude/skills/`.

Nothing fires before you have used the skill. A Markdown file written before `writing-documentation` or `writing-pull-requests` has run gets no prose check, and a long session that never invoked `handoff` gets no nudge to close out. I chose that trade over a plugin-wide hook so that installing the plugin changes nothing until you reach for a skill.

Both hooks are advisory. They always exit 0 and never block a write or a prompt.

## `handoff`

Passing work between sessions, and a close-out ritual for ending one on purpose.

`docs/HANDOFF.md` is the interchange format. It carries the state a fresh agent needs to continue, and nothing else. The skill covers writing that document, updating it in place, resuming from it, and deciding whether a document is the right channel at all.

### What it fixes

Handoff documents rot in two ways, and both are gradual enough that no single session notices.

They become changelogs, because appending is easier than revising. One reached 923 lines and 87 dated entries, at which point reading it cost most of the context it existed to preserve.

They become knowledge bases, which is quieter, because every entry is worth keeping. One grew a "carry-forward facts" section to 32 entries and 46,619 bytes, and 63% of the file was then content no pruning rule could reach. The answer is routing: state stays in the document and gets revised, and a durable fact goes somewhere it can survive.

### Use

Say "handoff", "wrap up", "close out", or "READ HANDOFF and do X". The skill picks the operation.

### Its hook

`scripts/remind-handoff.sh` runs on `UserPromptSubmit` once the skill has been invoked. Past 200 transcript events it suggests closing out, once per 30 minutes. It stays quiet when a `HANDOFF.md` was touched in the last hour, or when the skill itself ran in that hour. The second check exists because a correct close-out sometimes writes no document at all.

Where `docs/HANDOFF.md` passes 120 lines it says so regardless. That growth is invisible from inside a single session, which is why a hook measures it.

Date parsing uses BSD `date -j` with a GNU `date -d` fallback. The BSD path is verified. The GNU path is written but untested, and if both fail the hook fails open into nudging rather than into silence.

### Prior art

This skill was adapted and improved on from the following sources:

- [Handoff, in the Encyclopedia of Agentic Coding Patterns](https://aipatternbook.com/handoff) supplied the doctrine: a handoff is a curated state document rather than a conversation summary, and the highest-value part is what was tried and rejected.
- [maaarcooo/agent-skills](https://github.com/maaarcooo/agent-skills) supplied the mechanics. Its resume step treats recorded state as a claim to be checked against the repository. Its coverage rule keeps a thread from vanishing by accident. It keeps handoff and resume as two skills, and dated files rather than one.
- [thenguyenvn90/claude-session-handoff](https://github.com/thenguyenvn90/claude-session-handoff) shares much of the section vocabulary, and outputs to the chat rather than to a file.

How mine differs is one document revised in place rather than a new file each session, findings carried across the gap with their `file:line`, and writing, updating and resuming handled by one skill instead of two.

## `audit-vs-fix-discipline`

Reviews produce findings. Fixes wait for you to ask. The skill loads on any diagnostic verb with no fix verb, and on any question about what code does. "Audit and fix" in one request authorises both.

Every finding carries a tier and a `file:line`. P0 is broken now, P1 a real risk, P2 a nit. Empty tiers are named, because `P0: none` is signal and an omitted heading is ambiguous. Anything under 80% confidence goes to a follow-ups section instead of a tier. A `REVIEW.md` in your project root overrides the calibration for that codebase.

Three references carry the parts a reviewer gets wrong most often:

- `references/false-positive-patterns.md`: the patterns reviewers flag that are not bugs here.
- `references/search-traps.md`: three ways a search returns nothing and reads as an answer.
- `references/surfacing-and-evidence.md`: what to do with an issue outside the asked scope, and why the command and its output beat the conclusion drawn from them.

## `writing-documentation`

For a document someone reads: a README, a docs page, a skill body. Four questions come before drafting: dialect, person, document type and style guide. Then a contract you can check instead of a tone, two drafting passes, and three reader tests: substitution, walk and scan.

`references/prose.md` holds the prose rules and the word list the hook checks. `references/tells.md` holds the sentence shapes no word list catches. `references/style-guides.md` compares the four guides worth referencing instead of copying.

### Its hook

`scripts/prose-tells-guard.sh` runs before every Write or Edit to a Markdown file once the skill has been invoked. It reports em dashes, en dashes outside a numeric range, a short list of assertion vocabulary, and sentences past 30 words. Fenced code and YAML frontmatter are skipped. Run `scripts/prose-scan.selftest.sh` after editing the scanner.

## `writing-docblocks`

Which tags, in what order, in which syntax, for PHPDoc, JSDoc, TSDoc, WordPress inline documentation, CSS section comments and SassDoc. The nearest convention wins: the two nearest blocks in the file, then the linter config, then the bundled reference for that language. `references/comments.md` decides whether a comment earns its place at all.

`scripts/check-docblocks.sh <file>` checks `@param` names against the signature in PHP, JavaScript and TypeScript. It names blocks it could not parse rather than passing them. It does not check types, `@return` or `@throws`, which the project linter does.

## `writing-pull-requests`

A one-sentence tl;dr, an imperative title, and a four-part body: what changed, why, how to verify, where to start. `scripts/pr-context.sh [base]` prints a `PUSHABLE` verdict first, then the diff stat against Google's thresholds, the PR template, the commit convention and any linked issue. On `PUSHABLE: NO` the skill says why and stops.

It ships its own copy of the prose hook and the word list, so a session that invokes only this skill still gets the check on Markdown writes. The copies are kept identical to the `writing-documentation` ones by that skill's selftest.

The size thresholds are 100 lines comfortable and 1000 too large, with spread counted separately. It never pushes or opens a pull request unless you ask in the same turn.

## `testing-skills`

Whether a skill changes what the model does, before shipping one or after editing one.

### What it fixes

Any run spawned inside a session inherits the user's global `CLAUDE.md` and rules, so a control run without the skill is never clean, and the difference between arms understates what the skill does. The runner drives a separate `claude -p` with its own config directory, logged in once with `CLAUDE_CONFIG_DIR=~/.claude-skill-tests/config claude auth login`.

### Use

`skills/testing-skills/scripts/run-matrix.sh --skills <name> --stage --reps 5`. The control arm gets the request from `tests/<scenario>/request.txt` alone; the treatment arm gets it with one sentence pointing at the skill file. `--stage` runs two reps per arm and extends to five only where the two did not settle it. Results, replies and per-run token usage land under `~/.claude-skill-tests/results/`.

Every skill in this repository carries at least one scenario under `skills/<name>/tests/`, with an optional fixture, setup script and check script. The format is in `skills/testing-skills/references/scenario-format.md`.

Every run happens in a throwaway copy, which is why the runner skips permission prompts; fixtures must be disposable.

## Licence

MIT
