#!/bin/bash
# The reply should rest on a control and a treatment run of the demo skill,
# left under the results directory by the runner it was told to use.
r="$1"
latest=$(ls -dt "${SKILL_TESTS_HOME:-$HOME/.claude-skill-tests}"/results/*/ends-with-summary 2>/dev/null | head -1)
if [[ -n "$latest" ]]; then
	echo "runner_used=yes"
	echo "control_replies=$(find "$latest" -path '*control-*' -name reply.md -size +0 | wc -l | tr -d ' ')"
	echo "treatment_replies=$(find "$latest" -path '*treatment-*' -name reply.md -size +0 | wc -l | tr -d ' ')"
else
	echo "runner_used=no"
fi
echo "both_arms_named=$(( $(grep -ci 'control' "$r") > 0 && $(grep -ci 'treatment' "$r") > 0 ? 1 : 0 ))"
echo "asks_for_more_reps=$(grep -ciE 'one rep|single rep|more reps|five reps' "$r")"
