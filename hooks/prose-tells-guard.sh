#!/bin/bash
# PreToolUse advisory for Markdown prose: em dashes and assertion vocabulary.
#
# The literal word list lives in prose-scan.awk, and the same list is written
# out for reading in skills/writing-documentation/references/prose.md. A
# denylist inside an always-on instruction has to be pattern-matched against,
# and it over-suppresses: en dashes expressly permitted for numeric ranges still
# went unused across six files, because a prohibition swallows its own carve-out.
# A deterministic check has no judgement to distort and costs no context, which
# is why it can hold a blunt list safely. GitLab enforces its word list the same
# way, with Vale in CI rather than with prose instructions.
#
# ADVISORY, NEVER BLOCKING. Every term here has a legitimate use somewhere:
# quoting a source that uses em dashes, "unlock the keychain", financial
# leverage, robustness testing. Blocking would have refused a verbatim quote of
# Google's own style guide into a research log. Report and let the model
# judge; exit 2 is the wrong instrument for a style signal.
#
# Detection lives in prose-scan.awk. Run prose-scan.selftest.sh after editing it.

# Requires jq. Without it, fail open and silent rather than print an error on every write.
command -v jq > /dev/null 2>&1 || exit 0

HOOK_DIR="$(cd "$(dirname "$0")" && pwd)"
SCANNER="${HOOK_DIR}/prose-scan.awk"
[ -f "$SCANNER" ] || exit 0

INPUT=$(cat)

TOOL=$(jq -r '.tool_name // ""' <<<"$INPUT")
FILE_PATH=$(jq -r '.tool_input.file_path // ""' <<<"$INPUT")

[ -z "$FILE_PATH" ] && exit 0

case "$FILE_PATH" in
	*.md|*.mdx|*.markdown) ;;
	*) exit 0 ;;
esac

# Write carries the whole file; Edit carries only the replacement text. Checking
# new_string keeps the report scoped to what this call actually introduces.
case "$TOOL" in
	Write) TEXT=$(jq -r '.tool_input.content // ""' <<<"$INPUT") ;;
	Edit)  TEXT=$(jq -r '.tool_input.new_string // ""' <<<"$INPUT") ;;
	*) exit 0 ;;
esac

[ -z "$TEXT" ] && exit 0

# Scanner emits LINE <tab> FINDING <tab> SNIPPET; the snippet is for the drift
# log, so drop it here and report by line of the text being written.
# LONG=1 turns on sentence-length checking. It is opt-in so a second caller
# that compares its output window against window can leave it off.
FINDINGS=$(printf '%s' "$TEXT" | awk -v LONG=1 -f "$SCANNER" | awk -F'\t' '{print $1 ": " $2}')

[ -z "$FINDINGS" ] && exit 0

COUNT=$(printf '%s\n' "$FINDINGS" | grep -c .)
SUMMARY=$(printf '%s' "$FINDINGS" | tr '\n' ';' | sed 's/;$//;s/;/; /g')

jq -n --arg file "$(basename "$FILE_PATH")" --arg n "$COUNT" --arg s "$SUMMARY" '{
	hookSpecificOutput: {
		hookEventName: "PreToolUse",
		additionalContext: ("Prose check on \($file): \($n) item(s), by line of the text being written: \($s). Advisory only, and the write proceeds. Quoting a source that uses an em dash, or a term in its genuine technical sense, is a legitimate exception; say so rather than rewording around it. Otherwise the fix is usually the sentence, not the word: give the consequence instead of calling something crucial. A long sentence wants a full stop, and several parallel ones in a row usually want to be a list.")
	}
}'

exit 0
