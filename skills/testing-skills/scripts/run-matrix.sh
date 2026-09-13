#!/bin/bash
# Runs each scenario under skills/<name>/tests/ through an isolated `claude -p`,
# once per rep for a control arm (the request alone) and a treatment arm (the
# same request with the skill reachable), then tabulates each scenario's check
# output and token usage per arm.
#
# Usage: run-matrix.sh [--skills a,b] [--reps N] [--stage] [--model M]
#                      [--arm control|treatment|both] [--setting-sources LIST]
#                      [--skills-dir DIR] [--out DIR]
#
# --stage runs two reps per arm, then extends to --reps only where two did not
# settle it: an arm whose two replies printed different check lines, or two
# arms that printed the same lines.
#
# Two ways the treatment arm reaches the skill, measuring different claims.
# By default the runner passes --safe-mode and puts one sentence in front of
# the request pointing at the SKILL.md by path, so the body arrives as text and
# a null result means the text did not bind. With --setting-sources project the
# skill is copied into the work copy at .claude/skills/ instead, both arms get
# the bare request, and the model reaches it through the Skill tool as it would
# in a real session. That also puts the description under test, so usage.txt
# records skill_invoked per run and the summary prints it beside the checks.
#
# State lives under $SKILL_TESTS_HOME (default ~/.claude-skill-tests):
#   config/            the isolated login, created by `claude auth login`;
#                      SKILL_TESTS_CONFIG_DIR points at a different one
#   results/<stamp>/   one directory per run holding result.json (the raw
#                      `claude -p` output), reply.md, usage.txt, stderr.log,
#                      checks.txt and a `work` symlink to the copy it edited
#   work/<stamp>/      the throwaway copies themselves, kept apart from results
#                      so a run cannot reach a sibling's slot from its cwd
#
# Every run happens in a throwaway copy, which is the only reason permission
# prompts are skipped. Fixtures must be disposable. The isolated process gets
# none of the runner's variables, so the control arm cannot find the skill.
#
# Isolation is what keeps the control clean, and CLAUDE_CONFIG_DIR is not it:
# it moves the login and settings but still attaches ~/.claude/CLAUDE.md and
# ~/.claude/rules/ to every run, as transcripts from 2026-09-12 showed in all
# twenty runs of one matrix. --safe-mode drops CLAUDE.md, rules, skills,
# plugins and hooks. --setting-sources project drops the user-level ones and
# keeps project-level loading, which is the only thing that finds the installed
# skill. Either way the login and the permission flags are untouched.
set -u

REPS=2
STAGE=no
STAGE_FIRST=2
MODEL=sonnet
ARM=both
SKILLS=""
OUT=""
SKILLS_DIR=""
SETTING_SOURCES=""
HOME_DIR="${SKILL_TESTS_HOME:-$HOME/.claude-skill-tests}"
CONFIG_DIR="${SKILL_TESTS_CONFIG_DIR:-$HOME_DIR/config}"

while [[ $# -gt 0 ]]; do
	case "$1" in
		--skills)     SKILLS="$2"; shift 2 ;;
		--reps)       REPS="$2"; shift 2 ;;
		--stage)      STAGE=yes; shift ;;
		--model)      MODEL="$2"; shift 2 ;;
		--arm)        ARM="$2"; shift 2 ;;
		--skills-dir) SKILLS_DIR="$2"; shift 2 ;;
		--out)        OUT="$2"; shift 2 ;;
		--setting-sources) SETTING_SOURCES="$2"; shift 2 ;;
		# Prints the header comment, ending at the first line that does not open
		# with one, so adding to it never needs a line number updated here.
		-h|--help)    sed -n '2,/^[^#]/p' "$0" | sed -e '$d' -e 's/^# \{0,1\}//'; exit 0 ;;
		*) echo "unknown flag: $1" >&2; exit 64 ;;
	esac
done

if [[ $STAGE == yes && $REPS -le $STAGE_FIRST ]]; then
	echo "--stage runs $STAGE_FIRST reps first and extends to --reps, so --reps must be above $STAGE_FIRST" >&2
	exit 64
fi

# Nothing but project-level loading finds a skill under the work copy's
# .claude/skills/, so sources without it would run a treatment arm that has no
# skill and report the result as though it had one.
MODE_ARGS=(--safe-mode)
MODE_LABEL=safe-mode
if [[ -n "$SETTING_SOURCES" ]]; then
	if [[ ",$SETTING_SOURCES," != *,project,* ]]; then
		echo "--setting-sources must include project: the skill is installed into the work copy at .claude/skills/, and no other source loads it" >&2
		exit 64
	fi
	if [[ ",$SETTING_SOURCES," == *,user,* ]]; then
		echo "warning: user sources attach ~/.claude/CLAUDE.md, its rules and your own skills to both arms, so the matrix measures what the skill adds on top of them" >&2
	fi
	MODE_ARGS=(--setting-sources "$SETTING_SOURCES")
	MODE_LABEL="setting-sources=$SETTING_SOURCES"
fi

if [[ -z "$SKILLS_DIR" ]]; then
	if [[ -d ./skills ]]; then
		SKILLS_DIR="$(cd ./skills && pwd)"
	else
		SKILLS_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
	fi
fi
SKILLS_DIR="$(cd "$SKILLS_DIR" && pwd)"
REPO_ROOT="$(dirname "$SKILLS_DIR")"
export SKILLS_DIR REPO_ROOT

if [[ -z "$SKILLS" ]]; then
	SKILLS=$(cd "$SKILLS_DIR" && ls -d */tests 2>/dev/null | cut -d/ -f1 | tr '\n' ',')
fi
[[ -z "$SKILLS" ]] && { echo "no skill under $SKILLS_DIR has a tests/ directory" >&2; exit 1; }

LOGIN_HINT="The isolated config directory is not logged in. Run this once, interactively:
  CLAUDE_CONFIG_DIR=$CONFIG_DIR claude auth login"

mkdir -p "$CONFIG_DIR"
if ! CLAUDE_CONFIG_DIR="$CONFIG_DIR" claude auth status 2>/dev/null | grep -q '"loggedIn": true'; then
	echo "$LOGIN_HINT" >&2
	exit 2
fi

[[ -z "$OUT" ]] && OUT="$HOME_DIR/results/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"
WORK_ROOT="$HOME_DIR/work/$(basename "$OUT")"

# Project sources walk up from the work copy, and $HOME/.claude/CLAUDE.md is a
# hit on that walk with its rules behind it. Measured 2026-09-13: the same probe
# read the global protocol from a copy under $HOME and nothing from one in /tmp.
# Safe mode ignores those files wherever the copy sits, so only this mode moves.
if [[ -n "$SETTING_SOURCES" && "$WORK_ROOT" == "$HOME"/* ]]; then
	WORK_ROOT="${TMPDIR:-/tmp}"
	WORK_ROOT="${WORK_ROOT%/}/claude-skill-tests/work/$(basename "$OUT")"
	echo "work copies: $WORK_ROOT (outside \$HOME, where the ancestor walk finds no CLAUDE.md)"
fi
if [[ -n "$SETTING_SOURCES" && "$WORK_ROOT" == "$HOME"/* ]]; then
	echo "work copies would sit under \$HOME, where project sources pick up $HOME/.claude/CLAUDE.md; point TMPDIR somewhere outside it" >&2
	exit 64
fi

# A resume that changes mode would compare one arm read as text against another
# reached through the Skill tool, and the summary would not show the seam.
if [[ -f "$OUT/mode.txt" && "$(cat "$OUT/mode.txt")" != "$MODE_LABEL" ]]; then
	echo "$OUT was run under $(cat "$OUT/mode.txt") and this invocation is $MODE_LABEL; resume in the same mode or pick a new --out" >&2
	exit 64
fi
echo "$MODE_LABEL" > "$OUT/mode.txt"

case "$ARM" in
	both) ARMS="control treatment" ;;
	control|treatment) ARMS="$ARM" ;;
	*) echo "--arm takes control, treatment or both" >&2; exit 64 ;;
esac

# HEAD is part of the state, because a run that commits its edit leaves
# `git status` clean and would otherwise read as no change.
tree_state() {
	{ git -C "$1" rev-parse HEAD 2>/dev/null; git -C "$1" status --porcelain; } | md5 -q
}

# Installs the skill where project-level loading finds it. tests/ is left out:
# a model that read its own scenario would know what is being measured. The
# excludes keep the skill out of git, so it never reads as a fixture change and
# a scenario that commits cannot sweep it into the diff its check counts.
install_skill() {
	local work="$1" src="$2" name="$3" dest="$work/.claude/skills/$3"
	mkdir -p "$dest" "$work/.git/info"
	cp -R "$src/." "$dest/"
	rm -rf "$dest/tests"
	echo '/.claude/' >> "$work/.git/info/exclude"
}

# Prepares a work copy: fixture, initial commit, setup.sh, the skill where the
# arm gets one, then a snapshot of the tree state so fixture_changed can be
# reported without knowing the scenario. The skill goes in last because a
# scenario with no fixture/ clones into a work directory it expects to be empty.
prepare_work() {
	local scenario="$1" work="$2" skill="$3" skill_src="$4"
	mkdir -p "$work"
	if [[ -d "$scenario/fixture" ]]; then
		cp -R "$scenario/fixture/." "$work/"
		git -C "$work" init -q
		git -C "$work" add -A
		git -C "$work" commit -qm "Fixture" --allow-empty
	fi
	if [[ -f "$scenario/setup.sh" ]]; then
		(cd "$work" && SKILL_UNDER_TEST="$skill" bash "$scenario/setup.sh") || echo "setup.sh failed for $scenario" >&2
	fi
	if [[ ! -d "$work/.git" ]]; then
		git -C "$work" init -q
		git -C "$work" add -A
		git -C "$work" commit -qm "Fixture" --allow-empty
	fi
	[[ -n "$skill_src" ]] && install_skill "$work" "$skill_src" "$skill"
	tree_state "$work"
}

# The name the Skill tool answers to, which a skill may set to something other
# than its directory name.
skill_frontmatter_name() {
	local n=""
	[[ -f "$1/SKILL.md" ]] && n=$(awk -F': *' '/^name:/ {print $2; exit}' "$1/SKILL.md")
	echo "${n:-$(basename "$1")}"
}

# The session transcript the run left under the config directory, which is where
# both of the keys below are settled rather than assumed.
transcript_of() {
	local sid
	sid=$(awk -F= '/^session_id=/ {print $2}' "$1/usage.txt")
	find "$CONFIG_DIR/projects" -name "$sid.jsonl" 2>/dev/null | head -1
}

# Whether the model reached the skill through the Skill tool. Worth recording
# because in installed mode a description that never fired and a body that did
# not bind produce the same empty-looking reply.
skill_invoked() {
	local transcript
	transcript=$(transcript_of "$1")
	[[ -n "$transcript" ]] || { echo unknown; return; }
	grep -q "\"skill\": *\"$2\"" "$transcript" && echo yes || echo no
}

# How many CLAUDE.md or rule files the run was handed. Every comparison here
# assumes this is zero: a run that inherited the user's global files measures
# what the skill adds on top of them, which is a different claim from the one
# the summary appears to make.
ambient_memory_files() {
	local transcript
	transcript=$(transcript_of "$1")
	[[ -n "$transcript" ]] || { echo unknown; return; }
	grep -oE '"type":"(instructions|nested_memory)"' "$transcript" | wc -l | tr -d ' '
}

# One arm and rep of a scenario. A run the API rejected gets no checks.txt, so a
# resume with --out retries it instead of counting an error message as a reply.
run_one() {
	local skill="$1" scenario="$2" arm="$3" rep="$4"
	local name run work before after prompt skill_src=""
	name=$(basename "$scenario")
	run="$OUT/$skill/$name/$arm-$rep"
	work="$WORK_ROOT/$skill/$name/$arm-$rep"
	[[ -f "$run/checks.txt" ]] && return 0
	mkdir -p "$run"
	[[ $arm == treatment && -n "$SETTING_SOURCES" ]] && skill_src="$SKILLS_DIR/$skill"
	before=$(prepare_work "$scenario" "$work" "$skill" "$skill_src")
	prompt=$(cat "$scenario/request.txt")
	# The pointer sentence is the only thing putting the skill in front of the
	# model in text mode, and it carries nothing but where the file is. Anything
	# further is an instruction the control arm never receives, and it lands on
	# whatever the skill was going to be judged on: a clause telling the model it
	# could not ask the user sat here until 2026-09-13, in the arm testing a
	# skill whose own output ends in a question. A scenario that needs the model
	# told something puts it in request.txt, which both arms read.
	if [[ $arm == treatment && -z "$SETTING_SOURCES" ]]; then
		prompt="Read $SKILLS_DIR/$skill/SKILL.md and follow it for this task, resolving its relative paths against that directory. $prompt"
	fi
	echo "[$skill/$name $arm $rep] running"
	(cd "$work" && printf '%s' "$prompt" | env -u CLAUDECODE -u SKILLS_DIR -u REPO_ROOT -u SKILL_UNDER_TEST CLAUDE_CONFIG_DIR="$CONFIG_DIR" claude -p "${MODE_ARGS[@]}" --model "$MODEL" --dangerously-skip-permissions --output-format json > "$run/result.json" 2> "$run/stderr.log")
	after=$(tree_state "$work")
	ln -sfn "$work" "$run/work"
	if ! jq -e 'type == "object" and has("result")' "$run/result.json" >/dev/null 2>&1; then
		echo "[$skill/$name $arm $rep] failed: result.json holds no result, see $run/stderr.log" >&2
		return 1
	fi
	jq -r '.result' "$run/result.json" > "$run/reply.md"
	jq -r '"session_id=\(.session_id)", "turns=\(.num_turns)", "duration_s=\(((.duration_ms // 0) / 1000) | floor)", "input_tokens=\(.usage.input_tokens // 0)", "cache_create_tokens=\(.usage.cache_creation_input_tokens // 0)", "cache_read_tokens=\(.usage.cache_read_input_tokens // 0)", "output_tokens=\(.usage.output_tokens // 0)", "cost_usd=\(.total_cost_usd // 0)"' "$run/result.json" > "$run/usage.txt"
	# In usage.txt rather than checks.txt, because a key that always differs
	# between arms would tell --stage the two arms disagree on every scenario.
	echo "ambient_memory_files=$(ambient_memory_files "$run")" >> "$run/usage.txt"
	[[ -n "$SETTING_SOURCES" ]] && echo "skill_invoked=$(skill_invoked "$run" "$(skill_frontmatter_name "$SKILLS_DIR/$skill")")" >> "$run/usage.txt"
	if [[ $(jq -r '.is_error' "$run/result.json") == true ]]; then
		if grep -q 'Not logged in' "$run/reply.md"; then
			echo "[$skill/$name $arm $rep] the login expired mid-matrix. $LOGIN_HINT" >&2
			echo "Then resume with: $0 --out $OUT" >&2
			exit 2
		fi
		echo "[$skill/$name $arm $rep] failed: $(head -c 200 "$run/reply.md")" >&2
		return 1
	fi
	{
		[[ "$before" == "$after" ]] && echo "fixture_changed=no" || echo "fixture_changed=yes"
		if [[ -f "$scenario/check.sh" ]]; then
			(cd "$work" && SKILL_UNDER_TEST="$skill" bash "$scenario/check.sh" "$run/reply.md") || echo "check_failed=yes"
		fi
	} > "$run/checks.txt"
}

# How many distinct checks.txt contents the given files hold. Usage lives in
# usage.txt so a token count never makes two otherwise identical runs differ.
distinct_checks() {
	local f
	for f in "$@"; do [[ -f $f ]] && md5 -q "$f"; done | sort -u | wc -l | tr -d ' '
}

# Prints "settled", or "extend" followed by the arms that need more reps: each
# arm whose reps disagree, or both arms when every run printed the same lines.
stage_verdict() {
	local dir="$1" arm extend=""
	for arm in $ARMS; do
		[[ $(distinct_checks "$dir/$arm"-*/checks.txt) -gt 1 ]] && extend="$extend $arm"
	done
	if [[ -z $extend && $ARMS == "control treatment" && $(distinct_checks "$dir"/*/checks.txt) -eq 1 ]]; then
		extend=" control treatment"
	fi
	[[ -z $extend ]] && echo "settled" || echo "extend$extend"
}

FIRST=$REPS
[[ $STAGE == yes ]] && FIRST=$STAGE_FIRST

for skill in ${SKILLS//,/ }; do
	skill_dir="$SKILLS_DIR/$skill"
	[[ -d "$skill_dir/tests" ]] || { echo "[$skill] no tests/ directory, skipped" >&2; continue; }
	for scenario in "$skill_dir"/tests/*/; do
		scenario="${scenario%/}"
		name=$(basename "$scenario")
		[[ -f "$scenario/request.txt" ]] || { echo "[$skill/$name] no request.txt, skipped" >&2; continue; }
		for arm in $ARMS; do
			for ((rep = 1; rep <= FIRST; rep++)); do
				run_one "$skill" "$scenario" "$arm" "$rep"
			done
		done
		[[ $STAGE == yes ]] || continue
		verdict=$(stage_verdict "$OUT/$skill/$name")
		echo "after $FIRST reps: $verdict" > "$OUT/$skill/$name/stage.txt"
		echo "[$skill/$name] after $FIRST reps: $verdict"
		[[ $verdict == extend* ]] || continue
		for arm in ${verdict#extend}; do
			for ((rep = FIRST + 1; rep <= REPS; rep++)); do
				run_one "$skill" "$scenario" "$arm" "$rep"
			done
		done
	done
done

# Sums usage.txt across the runs of one arm: tokens in (prompt plus both cache
# columns), tokens out, and cost as the API reported it.
usage_line() {
	local dir="$1" arm="$2"
	cat "$dir/$arm"-*/usage.txt 2>/dev/null | awk -F= -v arm="$arm" '
		/^session_id=/ { n++ }
		/^(input_tokens|cache_create_tokens|cache_read_tokens)=/ { i += $2 }
		/^output_tokens=/ { o += $2 }
		/^cost_usd=/ { c += $2 }
		END { if (n) printf "usage %s\t%d runs\tin=%d\tout=%d\tcost_usd=%.2f\n", arm, n, i, o, c }'
}

echo
echo "Results: $OUT"
for skill in ${SKILLS//,/ }; do
	for scenario in "$OUT/$skill"/*/; do
		[[ -d "$scenario" ]] || continue
		echo
		echo "== $skill / $(basename "$scenario")"
		for run in "$scenario"*/; do
			run="${run%/}"
			if [[ -f "$run/checks.txt" ]]; then
				row=$(tr '\n' '\t' < "$run/checks.txt")
				[[ -n "$SETTING_SOURCES" ]] && row="$row$(grep '^skill_invoked=' "$run/usage.txt" 2>/dev/null)"
				printf '%s\t%s\n' "$(basename "$run")" "$row"
			else
				printf '%s\tno checks.txt (run did not finish)\n' "$(basename "$run")"
			fi
		done | column -t -s $'\t'
		# Every arm the results hold, not just the ones this invocation ran, so a
		# resume with --arm still totals the side it reused rather than dropping
		# it from the table it is printed beside.
		for arm in control treatment; do usage_line "$scenario" "$arm"; done | column -t -s $'\t'
		dirty=$(grep -l '^ambient_memory_files=[1-9]' "$scenario"*/usage.txt 2>/dev/null | wc -l | tr -d ' ')
		[[ $dirty -gt 0 ]] && echo "warning: $dirty run(s) were handed the user's CLAUDE.md or rules, so this compares what the skill adds on top of them"
		[[ -f "$scenario/stage.txt" ]] && cat "$scenario/stage.txt"
	done
done
