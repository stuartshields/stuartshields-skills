# Changelog

## Unreleased

- `writing-pull-requests` carries its own `references/prose.md`, and the pointers into `writing-documentation` are gone from the other writing skills. A skill installed alone with `npx skills add --skill` no longer references files it does not have.
- `writing-pull-requests` declares the prose hook in its frontmatter and ships its own copy of `prose-tells-guard.sh` and `prose-scan.awk`, so a session that invokes only that skill gets the check. `prose-scan.selftest.sh` fails when any of the three copied files diverges from the `writing-documentation` original.
- Added `testing-skills`: a runner that drives an isolated `claude -p` for a control arm and a treatment arm per scenario, so the arm without the skill carries none of the user's global rules, plus the scenario format and a guide to reading results.
- Every skill carries a `tests/` directory with at least one scenario: a verbatim request, a fixture, and a check script. `audit-vs-fix-discipline` has two. `writing-pull-requests` clones the repository into a bare-backed copy so a push from the run lands nowhere real.
- `run-matrix.sh` keeps each run's `result.json` and writes `usage.txt` (session id, turns, tokens, cost), and the summary totals usage per arm. Before this the runner used text output and no run's cost was recorded anywhere. A run the API rejected has no `checks.txt`, so a resume retries it, and an expired login stops the matrix with the login command instead of leaving an empty reply.
- `run-matrix.sh --stage` runs two reps per arm and extends to `--reps` only where an arm's two replies differ or the arms match. In the one five-rep matrix on record, two reps kept the direction of every saturated arm. They misread every arm at 3/5 in four of ten subsamples, and the flag spends the extra reps only on that kind.
- The `writing-pull-requests` scenario pins its branch to a fixed pair of commits, PR #2 on the main it merged into, instead of whatever is checked out. The diff the model reads is six files on any day and cannot carry the rule under test.

## 1.0.0

The three objections to this number in `0.1.0-beta-1` no longer hold: the plugin has a git remote, `prose-scan.selftest.sh` covers the prose scanner, and it ships five skills.

- Added `audit-vs-fix-discipline`, `writing-docblocks`, `writing-documentation` and `writing-pull-requests`, moved out of `~/.claude/skills/`.
- Hooks moved from a plugin-level `hooks/hooks.json` into each skill's frontmatter, so a hook registers when its skill is invoked rather than for every session.
- Scripts live under `skills/<name>/scripts/` beside the skill that owns them.
- Installable with `npx skills add stuartshields/stuartshields-skills` as well as through `/plugin`. Hooks locate their scripts through `${CLAUDE_SKILL_DIR}` instead of `${CLAUDE_PLUGIN_ROOT}`, which is unset outside a plugin.

## 0.1.0-beta-1

Renumbered down from 1.0.0. The plugin has no git remote, no test file and one skill, which is not what 1.0.0 claims.

Cut for size and for staleness, after an audit found the document rotting even though the rewrite rule was working.

- `SKILL.md` 121 lines to 87, the template 68 to 42, on-invoke cost ~4.2k tokens to ~2.2k.
- The template lost Key Files, Git State and the Verification results list. All three asked for a snapshot of the tree, which is wrong by morning.
- Write and update gained a reconcile step: an old document's claims are resolved against the tree before they are carried forward.
- Findings move to a queue the handoff points at, rather than a copy it carries.
- `remind-handoff.sh` measures the document and nudges past a 120-line ceiling, exempt from the "the skill just ran" suppression.

## 1.0.0, withdrawn

Never published anywhere. One skill, `handoff`, with its `remind-handoff.sh` advisory hook. Superseded by `0.1.0-beta-1` above, which is the same plugin under an honest number, so the descending order here is not a downgrade.
