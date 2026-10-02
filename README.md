# stuartshields-skills

Five working skills for Claude Code in one plugin, with the hooks that keep them honest. I built them after the same three failures kept recurring in my own sessions. A review would quietly fix things, documentation read as generated, and the handoff file grew into a changelog.

| Skill | Use it when | Ships |
|---|---|---|
| `handoff` | you are about to `/clear`, wrap up, or resume from `docs/HANDOFF.md` | a four-section template and a size-check hook |
| `audit-vs-fix-discipline` | you ask for a review, audit or investigation and want findings, not edits | a tiered output format, a false-positive list, search traps |
| `writing-documentation` | you write or rewrite a README, a docs page or a skill body | a prose hook, a style-guide comparison, three reader tests |
| `writing-docblocks` | you add or fix a PHPDoc, JSDoc, TSDoc or SassDoc block | per-language tag order, a `@param` checker, and a comment hook |
| `writing-pull-requests` | you write a pull request title and body | a context script that prints a push and size verdict, and the same prose hook |

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

That installs all five into `~/.claude/skills/`. Drop `-g` to install into the current project's `.claude/skills/` instead, or add `--skill handoff` to take one. The CLI symlinks by default; pass `--copy` for a standalone copy. Each skill installs on its own. `writing-pull-requests` shares a word list, a scanner and a prose hook with `writing-documentation`, held in this repository as symlinks. The CLI resolves a symlink to the file it points at, so `--skill writing-pull-requests` on its own still lands real files.

## Requirements

- `bash` and `jq` for the hooks and scripts. Without `jq` a hook exits silently and its skill still works.
- `awk` for the prose scanner. It runs on the BWK awk that ships with macOS and on GNU awk.
- `git` for the pull-request context script.

## How the hooks work

Each skill guard is registered twice, because the two install shapes expose different variables. A plugin install runs the guards from `hooks/hooks.json`, where `${CLAUDE_PLUGIN_ROOT}` reaches the hook process; each guard gates on its own skill having been invoked that session, so it stays quiet until you use the skill. A skills-CLI install has no `hooks.json`, so the declaration in each `SKILL.md` frontmatter resolves the script under `$HOME/.claude/skills/`, and Claude Code registers it the first time you invoke that skill.

A hook path cannot be built from `${CLAUDE_SKILL_DIR}`. Claude Code substitutes that name into a skill's `allowed-tools` and its body text, and does not export it to a hook process, so a hook command using it expands to `/scripts/...` and fails on every write.

No guard fires before you have used its skill, under either registration. A `HANDOFF.md` written in a session that never invoked `handoff` gets no size check. The skill hooks are advisory: they always exit 0 and never block a write or a prompt.

### Before a skill is invoked

The writing skills cover work that is rarely the headline of a request, so they went uninvoked while that work was done. The plugin's `hooks/hooks.json` registers these for every session:

| Hook | Runs on | Does |
|---|---|---|
| `docblock-gate.sh` | a code `Write` or `Edit` that adds a comment line | denies it until `writing-docblocks` is invoked |
| `pr-gate.sh` | `gh pr create` or `gh pr edit` | denies it until `writing-pull-requests` is invoked |
| `pr-nudge.sh` | a prompt mentioning a PR, MR or pull request | reminds Claude to invoke `writing-pull-requests`, which covers a PR written for copy and paste |
| `docs-prose-guard.sh` | a `Write` or `Edit` to a documentation path | runs the prose check, advisory only |
| `record-skill.sh` | every `Skill` call | records which skills the session has invoked |

Each gate and reminder stops once its skill is invoked, including a slash command typed at the prompt. The prose check stops once `writing-documentation` or `writing-pull-requests` runs its own copy.

Documentation paths default to `README.md`, `CONTRIBUTING.md`, `docs/**` and `**/SKILL.md`, relative to the project root. Set your own as a comma-separated list in the plugin's `docs_paths` option, under `/config`. Your list replaces the defaults.

Installed with the skills CLI, there is no plugin `hooks.json`, so none of these run.

## `handoff`

Passing work to a session that starts with fresh context.

`docs/HANDOFF.md` carries the goal, the current state, the dead ends and the next step, in 3,000 characters or fewer. The skill writes it, rewrites it in place, and resumes from it. Where you will come back to the same conversation, it points you at `claude --resume <name>` instead, since compaction already re-injects `CLAUDE.md`, auto memory and invoked skills.

### What it fixes

Handoff documents rot in three ways, and each is gradual enough that no single session notices.

They become changelogs, because appending is easier than revising. One reached 923 lines and 87 dated entries, at which point reading it cost most of the context it existed to preserve.

They become knowledge bases, which is quieter, because every entry is worth keeping. One grew a "carry-forward facts" section to 32 entries and 46,619 bytes, and 63% of the file was then content no pruning rule could reach. The answer is routing: state stays in the document and gets revised, and a durable fact goes somewhere it can survive.

They fit a line limit and still grow. Under the old 120-line ceiling, one document held 8,725 bytes in 48 lines, 18 of them over 200 characters. The budget is now counted in characters, so a long line costs what it weighs.

### Use

Say "handoff", "wrap up", "close out", or "READ HANDOFF and do X". The skill picks the operation.

### Its hook

`scripts/check-handoff-size.sh` runs after each `Write` or `Edit` once the skill has been invoked. When a file named `HANDOFF.md` passes 3,000 characters, it tells Claude the size and what usually fills the excess. It counts with `wc -m`, which counts bytes outside a UTF-8 locale, so there it can only be stricter.

### Prior art

This skill was adapted and improved on from the following sources:

- [Handoff, in the Encyclopedia of Agentic Coding Patterns](https://aipatternbook.com/handoff) supplied the doctrine: a handoff is a curated state document rather than a conversation summary, and the highest-value part is what was tried and rejected.
- [maaarcooo/agent-skills](https://github.com/maaarcooo/agent-skills) supplied the mechanics. Its resume step treats recorded state as a claim to be checked against the repository. Its coverage rule keeps a thread from vanishing by accident. It keeps handoff and resume as two skills, and dated files rather than one.
- [thenguyenvn90/claude-session-handoff](https://github.com/thenguyenvn90/claude-session-handoff) shares much of the section vocabulary, and outputs to the chat rather than to a file.

How mine differs is one document revised in place rather than a new file each session, findings pointed at in their own queue rather than copied, and writing, updating and resuming handled by one skill instead of two.

## `audit-vs-fix-discipline`

Reviews produce findings. Fixes wait for you to ask. The skill loads on any diagnostic verb with no fix verb, and on any question about what code does. "Audit and fix" in one request authorises both.

Every finding carries a tier and a `file:line`. P0 is broken now, P1 a real risk, P2 a nit. Empty tiers are named, because `P0: none` is signal and an omitted heading is ambiguous. Anything under 80% confidence goes to a follow-ups section instead of a tier. A `REVIEW.md` in your project root overrides the calibration for that codebase.

Three references carry the parts a reviewer gets wrong most often:

- `references/false-positive-patterns.md`: the patterns reviewers flag that are not bugs here.
- `references/search-traps.md`: three ways a search returns nothing and reads as an answer.
- `references/surfacing-and-evidence.md`: what to do with an issue outside the asked scope, and why the command and its output beat the conclusion drawn from them.

## `writing-documentation`

For a document someone reads: a README, a docs page, a skill body. Four questions come before drafting a new document: dialect, person, document type and style guide. An edit to an existing one takes the answers from the document. Then a contract you can check instead of a tone, two drafting passes, and three reader tests: substitution, walk and scan.

`references/prose.md` holds the prose rules and the word list the hook checks. `references/tells.md` holds the sentence shapes no word list catches. `references/style-guides.md` compares the four guides worth referencing instead of copying.

### Its hook

`scripts/prose-tells-guard.sh` runs before every Write or Edit to a Markdown file once the skill has been invoked. It reports em dashes, en dashes outside a numeric range, a short list of assertion vocabulary, and sentences past 30 words. Fenced code and YAML frontmatter are skipped. Run `scripts/prose-scan.selftest.sh` after editing the scanner.

## `writing-docblocks`

Which tags, in what order, in which syntax, for PHPDoc, JSDoc, TSDoc, WordPress inline documentation, CSS section comments and SassDoc. The nearest convention wins: the two nearest blocks in the file, then the linter config, then the bundled reference for that language. `references/comments.md` decides whether a comment earns its place at all.

`scripts/check-docblocks.sh <file>` checks `@param` names against the signature in PHP, JavaScript and TypeScript. It names blocks it could not parse rather than passing them. It does not check types, `@return` or `@throws`, which the project linter does.

### Its hook

`scripts/docblock-guard.sh` runs before every Write or Edit to a code file once the skill has been invoked. It reports a comment describing history rather than current state, and a comment run past three prose lines. A reason is not reported: the skill treats the reason behind an approach, an exception or a value as what a comment is for.

## `writing-pull-requests`

An imperative title and a four-part body: what changed, why, how to verify, where to start. `scripts/pr-context.sh [base]` prints a `PUSHABLE` verdict first, then the diff stat against Google's thresholds, the PR template, the commit convention and any linked issue. On `PUSHABLE: NO` the skill says why and stops.

It ships its own copy of the prose hook and the word list, so a session that invokes only this skill still gets the check on Markdown writes. The copies are kept identical to the `writing-documentation` ones by that skill's selftest.

The size thresholds are 100 lines comfortable and 1000 too large, with spread counted separately. It never pushes or opens a pull request unless you ask in the same turn.

## Licence

MIT
