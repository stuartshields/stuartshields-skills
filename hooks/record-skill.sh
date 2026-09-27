#!/bin/bash
# PostToolUse on Skill: records the invoked skill for the other plugin hooks.

command -v jq > /dev/null 2>&1 || exit 0
INPUT=$(cat)
jq -e . > /dev/null 2>&1 <<<"$INPUT" || exit 0

. "$(dirname "$0")/skill-state.sh"

SESSION=$(jq -r '.session_id // ""' <<<"$INPUT")
SKILL=$(jq -r '.tool_input.skill // ""' <<<"$INPUT")
[ -z "$SESSION" ] || [ -z "$SKILL" ] && exit 0

DIR=$(skill_state_dir "$SESSION")
mkdir -p "$DIR" && touch "$DIR/${SKILL##*:}"
exit 0
