#!/bin/bash
# PreToolUse on Write|Edit: denies a code edit that adds a comment line until
# writing-docblocks has been invoked in the session.

command -v jq > /dev/null 2>&1 || exit 0

INPUT=$(cat)
jq -e . > /dev/null 2>&1 <<<"$INPUT" || exit 0

. "$(dirname "$0")/skill-state.sh"

SESSION=$(jq -r '.session_id // ""' <<<"$INPUT")
[ -z "$SESSION" ] && exit 0
skill_invoked "$SESSION" "$(jq -r '.transcript_path // ""' <<<"$INPUT")" writing-docblocks && exit 0

FILE_PATH=$(jq -r '.tool_input.file_path // ""' <<<"$INPUT")
case "$FILE_PATH" in
	*.py|*.rb) HASH=1 ;;
	*.php|*.js|*.jsx|*.ts|*.tsx|*.mjs|*.cjs|*.css|*.scss|*.sass|*.go) HASH=0 ;;
	*) exit 0 ;;
esac

case "$(jq -r '.tool_name // ""' <<<"$INPUT")" in
	Write)
		NEW=$(jq -r '.tool_input.content // ""' <<<"$INPUT")
		OLD=$(cat "$FILE_PATH" 2>/dev/null)
		;;
	Edit)
		NEW=$(jq -r '.tool_input.new_string // ""' <<<"$INPUT")
		OLD=$(jq -r '.tool_input.old_string // ""' <<<"$INPUT")
		;;
	*) exit 0 ;;
esac

OLD_FILE=$(mktemp)
trap 'rm -f "$OLD_FILE"' EXIT
printf '%s\n' "$OLD" > "$OLD_FILE"

ADDED=$(printf '%s\n' "$NEW" | awk -v hash="$HASH" '
	function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }
	function is_comment(s) {
		if (s !~ /[A-Za-z0-9]/) return 0
		if (s ~ /^[ \t{]*(\/\/|\/\*|\*)/ || s ~ /[ \t]\/\/[ \t]/ || s ~ /\/\*/) return 1
		return hash && (s ~ /^[ \t]*#/ || s ~ /[ \t]#[ \t]/)
	}
	NR == FNR { seen[trim($0)] = 1; next }
	is_comment($0) && !(trim($0) in seen) { print FNR; exit }
' "$OLD_FILE" -)

[ -z "$ADDED" ] && exit 0

jq -n --arg file "$(basename "$FILE_PATH")" '{
	hookSpecificOutput: {
		hookEventName: "PreToolUse",
		permissionDecision: "deny",
		permissionDecisionReason: ("This edit adds a comment to \($file), and writing-docblocks has not been invoked this session. Invoke the Skill tool with stuartshields-skills:writing-docblocks, then retry the same edit, applying the skill to the comment.")
	}
}'
exit 0
