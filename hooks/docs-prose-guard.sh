#!/bin/bash
# PreToolUse on Write|Edit: runs the writing-documentation prose check on
# documentation paths before that skill has been invoked. Advisory only.
#
# The paths come from the plugin's `docs_paths` option, a comma-separated list
# of globs relative to the project root. `*` also matches `/`, and a leading
# `**/` also matches at the root.

DEFAULT_DOCS_PATHS='README.md,CONTRIBUTING.md,docs/**,**/SKILL.md'

command -v jq > /dev/null 2>&1 || exit 0

INPUT=$(cat)
jq -e . > /dev/null 2>&1 <<<"$INPUT" || exit 0

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$HOOK_DIR/skill-state.sh"

SESSION=$(jq -r '.session_id // ""' <<<"$INPUT")
TRANSCRIPT=$(jq -r '.transcript_path // ""' <<<"$INPUT")
[ -z "$SESSION" ] && exit 0

# Both skills register the same prose check themselves once invoked.
skill_invoked "$SESSION" "$TRANSCRIPT" writing-documentation && exit 0
skill_invoked "$SESSION" "$TRANSCRIPT" writing-pull-requests && exit 0

FILE_PATH=$(jq -r '.tool_input.file_path // ""' <<<"$INPUT")
[ -z "$FILE_PATH" ] && exit 0

ROOT="${CLAUDE_PROJECT_DIR:-$(jq -r '.cwd // ""' <<<"$INPUT")}"
REL="${FILE_PATH#"${ROOT%/}"/}"

matches_docs_path() {
	local pattern
	IFS=',' read -ra PATTERNS <<<"${CLAUDE_PLUGIN_OPTION_DOCS_PATHS:-$DEFAULT_DOCS_PATHS}"
	for pattern in "${PATTERNS[@]}"; do
		pattern="${pattern#"${pattern%%[![:space:]]*}"}"
		pattern="${pattern%"${pattern##*[![:space:]]}"}"
		[ -z "$pattern" ] && continue
		# Unquoted on the right so [[ ]] treats it as a glob.
		[[ "$REL" == $pattern ]] && return 0
		[[ "$pattern" == '**/'* && "$REL" == ${pattern#'**/'} ]] && return 0
	done
	return 1
}

matches_docs_path || exit 0

exec "$HOOK_DIR/../skills/writing-documentation/scripts/prose-tells-guard.sh" <<<"$INPUT"
