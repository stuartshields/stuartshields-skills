# Scenario format

One directory per scenario at `skills/<name>/tests/<scenario>/`. The runner discovers every directory there that holds a `request.txt`.

| File | Required | Contract |
|---|---|---|
| `request.txt` | yes | The verbatim user request, and the whole prompt both arms see apart from the sentence naming the skill file in text mode. Names no skill and no rule. A harness fact the model needs, such as no one being there to reply, goes here, where both arms read it rather than one. |
| `fixture/` | no | Copied into the work directory, then `git init` and one commit. Store no `.git` inside it; nested repositories cannot be committed to this one. |
| `setup.sh` | no | Runs in the work copy after that commit, with `SKILLS_DIR`, `REPO_ROOT` and `SKILL_UNDER_TEST` exported. Where there is no `fixture/`, the work directory is empty when it runs, so it can clone into `.`. |
| `check.sh` | no | Runs in the work copy after the reply, with the reply path as `$1` and the same environment. Prints `key=value` lines, one per line. A non-zero exit adds `check_failed=yes`. |

Work copies live under `~/.claude-skill-tests/work/<stamp>/`, apart from the results. Under `--setting-sources` they move to a path outside `$HOME`, which the runner prints, because project sources walk up from the work directory and would find `~/.claude/CLAUDE.md` on the way. Each run directory holds `result.json` (the raw `claude -p` output), `reply.md`, `usage.txt`, `checks.txt`, and a `work` symlink to its copy once the run has finished. The isolated process inherits none of the runner's variables.

`usage.txt` carries the session id, turns, tokens and cost, plus `ambient_memory_files` (how many CLAUDE.md and rule files the run was handed, which the comparison needs at zero) and, in installed mode, `skill_invoked`. All of it stays out of `checks.txt` so that `--stage` can compare check lines across reps: a token count would make every run differ, and `skill_invoked` would make every pair of arms differ.

In installed mode the skill is copied to `.claude/skills/<name>/` in the treatment work copy only, without its `tests/`, and `/.claude/` is added to the repository's `.git/info/exclude`. A scenario therefore sees no skill in `git status` and cannot sweep one into a commit its check counts.

The runner always records `fixture_changed=yes|no`, from a snapshot of the commit hash and `git status --porcelain` taken after `setup.sh` and compared after the reply. The hash is in the snapshot because a run that commits its own edit leaves the status clean; the first clean control run to do that reported a fix as committed and would otherwise have counted as untouched. Untracked files created by `setup.sh` are part of the baseline, so a scenario can start with uncommitted work in progress without that counting as a change.

## Writing the request

The request is what a user would type on a normal day, including the pressures a user brings: urgency, a half-formed ask, a wrong assumption stated as fact. It contains nothing that tells either arm it is being measured.

| Tempts the failure | Tells the arms what is measured |
|---|---|
| "Look at src/retry.js and find what's wrong, quickly." | "Audit src/retry.js without editing it." |
| "I'm about to /clear. Update the handoff." | "Revise docs/HANDOFF.md in place following the template." |
| "The docblocks in inc/reading-time.php are stale. Fix them." | "Fix the stale tags and rewrite any summary that opens with 'This function'." |

## Writing the fixture

The smallest tree in which the control arm can fail. Give it the neighbours the skill says to read: two correct docblocks beside the stale one, a README whose claim the code contradicts, a handoff naming a path that no longer exists. Commit nothing that answers the question for the model, such as a test that already asserts the right behaviour, unless the scenario is about whether the model runs it.

A scenario that clones this repository builds a bare copy first, so a push from the work directory lands nowhere real:

```sh
branch=$(git -C "$REPO_ROOT" rev-parse --abbrev-ref HEAD)
git clone -q --bare "$REPO_ROOT" ../origin.git
git clone -q --branch "$branch" ../origin.git .
git branch -q main origin/main 2>/dev/null || true
```

## Writing the check

Count what a count can settle. Everything else is for the hand read.

```sh
#!/bin/bash
r="$1"
echo "tiers=$(grep -c '^### P[0-2]' "$r")"
echo "closing_ask=$(grep -ci 'want me to fix' "$r")"
```

A check may call the skill's own tooling through `SKILLS_DIR`, such as a linter or a scanner the skill ships. Keep each key stable across edits to the scenario, so results from different days line up.
