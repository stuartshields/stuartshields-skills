#!/bin/bash
# PostToolUse advisory: reports a HANDOFF.md written past the skill's budget.
# Registered in the plugin-wide hooks.json under a plugin install, and in
# ../SKILL.md frontmatter under ~/.claude/skills/. A hook command cannot use
# ${CLAUDE_SKILL_DIR}: Claude Code substitutes it into a skill's allowed-tools
# and body text only, and never exports it. Advisory only: the write has
# already happened.

# Requires jq. Without it, fail open and silent rather than print an error on every write.
command -v jq > /dev/null 2>&1 || exit 0

BUDGET=3000

INPUT=$(cat)

# Two registrations reach this script. The plugin-wide hooks.json runs it on
# every write, so it gates on the skill having been invoked. An install into
# ~/.claude/skills/ carries no hooks.json and no skill-state.sh, and there the
# frontmatter hook registers only once the skill is invoked.
SKILL_STATE="$(dirname "$0")/../../../hooks/skill-state.sh"
if [ -f "$SKILL_STATE" ]; then
	. "$SKILL_STATE"
	skill_invoked \
		"$(jq -r '.session_id // ""' <<<"$INPUT")" \
		"$(jq -r '.transcript_path // ""' <<<"$INPUT")" \
		handoff || exit 0
fi

FILE_PATH=$(jq -r '.tool_input.file_path // ""' <<<"$INPUT")

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
