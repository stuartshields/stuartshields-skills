# Changelog

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
