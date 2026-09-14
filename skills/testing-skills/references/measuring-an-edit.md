# Measuring an edit

A matrix compares the skill against nothing. After an edit the open question is different: this wording against the wording it replaced. No arm in the default matrix carries the previous wording, so a rerun of the treatment arm cannot answer it.

## Stage the previous version as a third arm

```sh
PRE=$(mktemp -d)                                    # outside the repo, so nothing is mutated
mkdir -p "$PRE/skills/<name>" && cp -R skills/<name>/* "$PRE/skills/<name>/"
git show HEAD:skills/<name>/references/<edited>.md > "$PRE/skills/<name>/references/<edited>.md"
diff -r skills/<name> "$PRE/skills/<name>"          # the arms differ in the edited file and nothing else
scripts/run-matrix.sh --skills-dir "$PRE/skills" --skills <name> --arm treatment --reps 5
```

Restore from `HEAD` only where the edit is committed. Where it is not, the previous version is the working tree and the staged copy takes the edit instead, so commit first or copy the old text in by hand.

Run the current arm the same way, from a tree staged the same way, rather than against the live skill directory. Two arms built by different routes differ in more than the edit.

The control arm is untouched by any of this. Its counts stand until the request or the fixture changes.

## One scenario per tree

`--skills` selects skills and nothing selects a scenario, so a skill with three scenarios runs all three on every invocation. A staged tree holding one scenario runs one scenario, which is the only way to rerun a single scenario once a skill has several. Copy in the one you want:

```sh
cp -R skills/<name>/tests/<scenario> "$PRE/skills/<name>/tests/"
```

## Read the process keys, not only the outcome keys

Both arms can reach a passing outcome while one thrashes on the way. The clearest separation on record sat entirely in the process: validity was 5/5 against 5/5 and said nothing, while generator invocations per run were 1, 1, 1, 1, 1 post-edit against 3, 5, 6, 5, 6 pre-edit, with the two sets not overlapping. Count the steps as well as the verdict, or an edit that removes floundering reads as no effect at all.

A count of tool calls belongs in `check.sh`, read from the run's own transcript with a JSON parser. `../SKILL.md` §2 carries why that check must be calibrated before the matrix depends on it.

## What a null means here

A post-edit arm scoring zero on the behaviour the edit targets has two causes that look identical. The wording failed to bind, or the request never asked for the behaviour, so nothing could have bound. Check the control arm first: where it never attempts the behaviour either, the scenario measures nothing about the edit and the answer is another scenario rather than another edit.
