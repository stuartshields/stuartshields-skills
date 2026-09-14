---
name: testing-skills
description: Use when checking whether a skill changes what the model does, before shipping a new or edited skill, when a skill seems not to bind or not to fire, or when asked "test this skill", "does the skill work", "baseline the skill", "run the skill tests", "does it actually change behaviour", or "compare with and without the skill". Also use after editing a skill body, to confirm the edit binds. Not for unit testing application code.
---

<!-- Last updated: 2026-09-14T14:10+10:00 -->

# Testing skills

A skill is text meant to change what the model does. The only evidence that it does is the same request run with the skill and without it, and the difference read by a person. Everything here serves that comparison.

## Why the runs leave the session

Any agent spawned from inside a session inherits the user's global `CLAUDE.md` and rules. A run without the skill still carries a weaker version of whatever the skill enforces, so the difference between arms understates the skill and sometimes hides it. Two probes established that replacing the system prompt does not remove those files either, and a separate config directory does not either: with only `CLAUDE_CONFIG_DIR` set, every run of a twenty-run matrix still received `~/.claude/CLAUDE.md` and the path-scoped files under `~/.claude/rules/`.

`scripts/run-matrix.sh` therefore drives a separate `claude -p` process with its own config directory, under one of two isolation flags. The control arm sees the request alone either way.

Do not take the isolation on trust. Every run counts the CLAUDE.md and rule files it was handed, reading its own transcript under `<config dir>/projects/`, and records the figure as `ambient_memory_files` in `usage.txt`. The summary warns when any run is above zero. A matrix with a non-zero count still means something, but the something is what the skill adds on top of those files, and a report has to say so.

## How the skill reaches the treatment arm

Two ways, answering different questions.

**Text, the default.** The runner passes `--safe-mode` and puts one sentence in front of the request pointing at the SKILL.md by path. That sentence carries the path and nothing else, since whatever else it carried would be an instruction the control arm never receives. The model reads the body with the Read tool. Nothing else loads, not even the bundled skills, so the baseline is as bare as it gets. A treatment arm that behaves like its control means the text did not bind, because the body certainly arrived.

**Installed, with `--setting-sources project`.** The runner copies the skill into the work copy at `.claude/skills/<name>/` and hands both arms the bare request. The model reaches it through the Skill tool, as it would in a real session. The `tests/` directory is left out of that copy, because a model that read its own scenario would know what was being measured.

Installed mode puts the description under test alongside the body. That is worth having, and it is also a confound: a treatment arm that matches its control might be a description that never fired rather than a body that did not bind. `usage.txt` records `skill_invoked` per run to separate the two, and the summary prints it beside the checks.

Two things installed mode does not give you. The bundled skills stay in the listing for both arms, so the baseline is a stock Claude rather than a bare one. Work copies also move out of `$HOME`, because project sources walk up from the work directory and `~/.claude/CLAUDE.md` sits on that walk. The same probe on 2026-09-13 read the global protocol from a copy under `$HOME` and nothing from one under `/tmp`. The runner relocates the copies and prints where they went.

Whether a skill's frontmatter hooks fire in installed mode is untested. In text mode they certainly do not, since the body is only ever read as a file.

## 1. Set up once

The isolated config directory needs its own login. The runner refuses to start until it has one and prints this command:

```sh
CLAUDE_CONFIG_DIR=~/.claude-skill-tests/config claude auth login
```

It is interactive, so the user runs it. Type it for them if the harness offers a way to run a command in the user's terminal. A login that already exists elsewhere is reached with `SKILL_TESTS_CONFIG_DIR=<dir>`; the login is bound to the literal path, so a symlink does not carry it.

## 2. Write the scenario

**One scenario, then stop.** Write the single most impactful scenario, run it, report what it returned, name the one you would write next, and wait to be told to go on. The most impactful is the rule whose failure the control arm is likeliest to produce unprompted and whose outcome a check can settle, which is usually the rule the skill exists for rather than the one most recently edited.

The reason is not tidiness. Each scenario costs a matrix of full sessions, and what the first one returns routinely changes which scenario is worth writing at all. A first fixture that the control arm passed four times in five turned the second scenario into a different test. A later scenario showed the control already producing the shape a planned third scenario was going to check, which would have measured a gap that does not exist. Both would have been written and paid for under a batch.

**No exceptions:**
- Not for a scenario that is "obviously needed too".
- Not for staging the next fixture while the first matrix runs.
- Not for sharing one fixture across two scenarios written together.
- A plan naming three scenarios is a plan. Write the first one.

One directory per scenario at `skills/<name>/tests/<scenario>/`. `references/scenario-format.md` carries the four files and their contracts. The two that decide whether the test means anything:

**`request.txt` is what a user would type.** It tempts the failure the skill guards against and says nothing about the skill. "Look at src/retry.js and check for issues" tempts an unrequested fix. "Test whether this follows the audit skill" tests nothing, because both arms now know what is being measured.

**`fixture/` is the smallest repository in which the failure can happen.** A stale docblock next to two correct ones. A handoff document that names a file since renamed. If the control arm cannot fail on it, the fixture is too easy, and a pass on the treatment arm proves nothing.

**Provoke the failure by hand before you build the fixture around it.** Run the thing that decides pass or fail against the shape a model writes from memory, and keep the shapes that break. One command is cheaper than a matrix: a `validate` probe across eight block types found three that a from-memory author gets wrong, after a fixture built without it produced valid output in four of five control runs and settled nothing. A fixture assembled from shapes you have already watched fail starts from a control arm that can fail.

Write `check.sh` for what a count can settle: files changed, a phrase present, a linter's exit code. Leave to the hand read what a count cannot.

**Calibrate the check against a run whose answer you already know, before any matrix depends on it.** Point it at a stored `reply.md` you have read and confirm every key returns what you know to be true. A wrong key does not announce itself: it fills a column with plausible numbers and every row inherits them. One key that counted tool calls was wrong twice in opposite directions, first counting a `grep` over the skill's own references as a run, then missing every real run, and both times the matrix looked clean and was reported from.

**A check that reads the run's transcript parses it; it never greps it.** Command strings in `<config dir>/projects/*.jsonl` are JSON-escaped and span newlines, so a heredoc that builds an input file and then pipes it to the tool sits behind an escaped quote where `grep -o '"command":"[^"]*"'` stops. Walk the file with a JSON parser and read `input.command` off the tool calls.

## 3. Run

```sh
scripts/run-matrix.sh --skills <name> --stage --reps 5
```

Runs are scenarios × arms × reps, and each is a full `claude -p` session plus whatever the model reads. Without `--skills`, every skill with a `tests/` directory runs: seven scenarios today, so 70 sessions at five reps. Name the skill.

`--stage` runs two reps per arm, then extends to `--reps` only where two did not settle it. Two reps fail to settle an arm whose replies printed different check lines, and a scenario whose two arms printed the same lines. Two reps settle a saturated arm and mislead on a partial one, and `references/reading-results.md` carries the subsample counts behind that. A settled scenario supports the direction of the effect; a count in a report, such as "5 of 5", still needs the five. Without `--stage`, `--reps` runs flat, and its default is 2.

`--setting-sources project` switches to installed mode, and the list it is given must contain `project`, since nothing else finds a skill under the work copy's `.claude/`. A list containing `user` runs with a warning, because that measures what the skill adds on top of your own rules rather than what it does alone.

`--out <dir>` resumes by skipping any run that already has `checks.txt`, so pointing at an earlier directory reuses its control arm and adds only what is missing. A results directory refuses a resume in the other mode, which would compare a control read as text against a treatment reached through the Skill tool.

The `demo-skill` scenario under this skill asks the model to run this runner, so each treatment run that follows the skill is three sessions. Leave it out of a matrix that is not about this skill.

`scripts/run-matrix.sh -h` prints the rest: every flag, the state layout under `~/.claude-skill-tests`, and what each isolation flag drops. Read it there rather than here, where it would go stale against the script.

## 4. Read every reply

The runner ends with a table of check output per arm. The table finds candidates. The reply decides.

- **A grep matches quoted counter-examples.** A reply that says "I did not open with 'This PR'" matches the banned-opener check. Read the line.
- **A converged treatment arm is the signal.** Every reply with the same shape means the text binds. Five different shapes mean it does not, whatever the counts say. Tighten the form before adding words.
- **A control arm that never fails means the fixture, not the skill, needs work.** Two audit fixtures this skill was built on failed to tempt an edit from any control run. The discriminating rows were format and calibration.
- **Check the fixture for the rule under test.** A pull-request scenario run from a branch whose diff adds a fencing rule teaches the control arm to fence. Read the fixture through the control arm's eyes before trusting a comparison.

`references/reading-results.md` carries the full list, with what each trap looked like when it happened.

## 5. Edit, then rerun the treatment arm

A skill edit is a hypothesis about the failure. Match the form to it:

| The control arm | Write |
|---|---|
| knows the rule and breaks it under pressure | the prohibition, the excuse, and the reality beside it |
| complies but produces the wrong shape | the shape itself: the parts, in order, as a template |
| leaves out one element it otherwise produces | that element inside the template, not a sentence near it |
| should act differently under a condition | the condition as something observable, then the action |

Rerun the treatment arm alone. The control results stand until the fixture or request changes.

**A treatment arm measures the skill. To measure the edit, add an arm holding the skill as it was.** Rerunning treatment alone answers "skill against nothing", which a shipped skill already passed. Stage the previous version as a third arm, and read the process keys rather than only the outcome: the clearest separation on record sat at 5/5 against 5/5 on validity and split completely on how many times each arm invoked the tool. `references/measuring-an-edit.md` carries the commands, the one-scenario-per-tree trick, and what a null means here.

## Common mistakes

- **Testing through the session's own agents.** The control is contaminated. Use the runner.
- **Reading the summary table as the result.** It ranks what to read first.
- **Two reps, then a count.** Two reps settle the direction of a saturated arm and mislead on a partial one, and cannot tell a 5/5 from a 3/5. `--stage` extends the second kind; a count needs the five.
- **A request that names the skill or its rule.** Both arms then perform for the test.
- **Fixing the fixture to make the treatment pass.** The fixture changes to make the control fail.
- **Writing the second scenario before the first has reported.** Its result decides whether the second is worth writing.
