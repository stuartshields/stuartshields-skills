#!/bin/bash
# PostToolUse advisory: reports a HANDOFF.md written past the skill's budget.
# Declared in ../SKILL.md frontmatter, so it registers when the handoff skill is
# first invoked in a session. Advisory only: the write has already happened.

# Requires jq. Without it, fail open and silent rather than print an error on every write.
command -v jq > /dev/null 2>&1 || exit 0

BUDGET=3000

FILE_PATH=$(jq -r '.tool_input.file_path // ""' 2>/dev/null)

case "$FILE_PATH" in
	HANDOFF.md|*/HANDOFF.md) ;;
	*) exit 0 ;;
esac

[ -f "$FILE_PATH" ] && [ -r "$FILE_PATH" ] || exit 0

SIZE=$(wc -m < "$FILE_PATH" | tr -d ' ')
[ "$SIZE" -le "$BUDGET" ] && exit 0

jq -n --arg file "$FILE_PATH" --arg size "$SIZE" --arg budget "$BUDGET" '{
	hookSpecificOutput: {
		hookEventName: "PostToolUse",
		additionalContext: ("Handoff size check: \($file) is \($size) characters, past the \($budget)-character budget. Cut rather than compress. The usual excess is content CLAUDE.md, auto memory or git already holds, completed work, and dead ends that no longer constrain the next step.")
	}
}'

exit 0
