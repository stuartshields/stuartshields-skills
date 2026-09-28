#!/bin/bash
# PreToolUse on Bash, narrowed by `if: Bash(gh pr *)`: denies `gh pr create` and
# `gh pr edit` until writing-pull-requests has been invoked in the session.

command -v jq > /dev/null 2>&1 || exit 0

INPUT=$(cat)
jq -e . > /dev/null 2>&1 <<<"$INPUT" || exit 0

. "$(dirname "$0")/skill-state.sh"

jq -r '.tool_input.command // ""' <<<"$INPUT" \
	| grep -qE '(^|[^[:alnum:]_-])gh[[:space:]]+pr[[:space:]]+(create|edit)([[:space:]]|$)' || exit 0

SESSION=$(jq -r '.session_id // ""' <<<"$INPUT")
[ -z "$SESSION" ] && exit 0
skill_invoked "$SESSION" "$(jq -r '.transcript_path // ""' <<<"$INPUT")" writing-pull-requests && exit 0

jq -n '{
	hookSpecificOutput: {
		hookEventName: "PreToolUse",
		permissionDecision: "deny",
		permissionDecisionReason: "This command writes a pull request title or body, and writing-pull-requests has not been invoked this session. Invoke the Skill tool with stuartshields-skills:writing-pull-requests, rewrite the title and body to it, then rerun the command."
	}
}'
exit 0
