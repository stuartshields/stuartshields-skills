#!/bin/bash
# UserPromptSubmit: a PR written for copy and paste never runs `gh`, so pr-gate.sh
# cannot see it. When a prompt mentions a pull request and writing-pull-requests
# has not been invoked, this adds a reminder. Advisory only.

command -v jq > /dev/null 2>&1 || exit 0

INPUT=$(cat)
jq -e . > /dev/null 2>&1 <<<"$INPUT" || exit 0

. "$(dirname "$0")/skill-state.sh"

jq -r '.prompt // ""' <<<"$INPUT" \
	| grep -qiE '(^|[^[:alnum:]])(pr|prs|mr|pull request|pull requests|merge request)([^[:alnum:]]|$)' || exit 0

SESSION=$(jq -r '.session_id // ""' <<<"$INPUT")
[ -z "$SESSION" ] && exit 0
skill_invoked "$SESSION" "$(jq -r '.transcript_path // ""' <<<"$INPUT")" writing-pull-requests && exit 0

jq -n '{
	hookSpecificOutput: {
		hookEventName: "UserPromptSubmit",
		additionalContext: "If this prompt asks for a pull request title or description, including one to copy and paste, invoke the Skill tool with stuartshields-skills:writing-pull-requests before writing it."
	}
}'
exit 0
