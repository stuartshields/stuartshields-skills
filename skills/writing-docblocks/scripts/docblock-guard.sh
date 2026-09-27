#!/bin/bash
# PreToolUse advisory for code comments: reasons, session history, and overlong
# blocks. Declared in ../SKILL.md frontmatter, so it
# registers when that skill is first invoked in a session. ${CLAUDE_SKILL_DIR}
# resolves under a plugin install and under ~/.claude/skills/ alike, where
# ${CLAUDE_PLUGIN_ROOT} is unset.
#
# ADVISORY, NEVER BLOCKING. "because" and "to avoid" can appear in a comment
# that only states what code does. Report and let the model judge; exit 2 is the
# wrong instrument for a style signal.

# Requires jq. Without it, fail open and silent rather than print an error on every write.
command -v jq > /dev/null 2>&1 || exit 0

INPUT=$(cat)

TOOL=$(jq -r '.tool_name // ""' <<<"$INPUT")
FILE_PATH=$(jq -r '.tool_input.file_path // ""' <<<"$INPUT")

[ -z "$FILE_PATH" ] && exit 0

case "$FILE_PATH" in
	*.php|*.js|*.jsx|*.ts|*.tsx|*.mjs|*.cjs|*.css|*.scss|*.sass|*.go|*.rb|*.py) ;;
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

FINDINGS=$(printf '%s' "$TEXT" | awk -v MAX_PROSE=3 '
	function flush() {
		if (run_prose > MAX_PROSE) print run_start ": " run_prose " consecutive comment lines"
		run = 0; run_prose = 0
	}

	{
		line = $0
		# JSX wraps a comment in braces, putting `{` before the marker. Strip it
		# so `{ /* ... */ }` is seen as the comment it is.
		probe = line
		sub(/^[ \t]*\{[ \t]*/, "", probe)
		# Continuation lines of an unterminated `/* ... */` carry no marker, so
		# without tracking the open block the run ends at its first line and a
		# buffered finding is dropped before it can be reported.
		was_open = block_open
		is_comment = was_open || (probe ~ /^[ \t]*(\/\/|#|\*|\/\*)/)
		if (probe ~ /\/\*/ && line !~ /\*\//) block_open = 1
		else if (line ~ /\*\//) block_open = 0

		if (is_comment) {
			if (run == 0) run_start = NR
			run++
			# Requiring a letter or digit after the marker drops tag rows, which start at `@`.
			# Testing the whole line for `@` instead would drop any sentence naming
			# an `@scope/package`. `=>` and a trailing comma or brace mark a
			# multi-line `@return {{...}}` type, which is a signature, not narration.
			# The loose test is only for a continuation line carrying no marker of
			# its own. Applying it to a marked line would count `@param` rows as
			# prose, since a JSDoc block is itself an open `/* ... */`.
			if (probe ~ /^[ \t]*(\*|\/\/|#|\/\*)/) {
				if (probe ~ /^[ \t]*(\*|\/\/|#|\/\*)[ \t]+[A-Za-z0-9`]/ && probe !~ /(=>|[,{}][ \t]*$)/) run_prose++
			} else if (was_open && probe ~ /[A-Za-z]/) run_prose++

			low = tolower(line)
			if (low ~ /(because|we chose|in order to|to avoid|as opposed to|would fight|avoids that|the reason)/)
				print NR ": gives a reason, not what the code does"
			# "is used to" describes purpose, not history. BWK awk has no lookbehind or
			# \b, so the non-letter anchor keeps "this used to" matching.
			hist = low
			gsub(/(^|[^a-z])(is|are|be) used to /, " ", hist)
			if (hist ~ /(previously|used to |no longer|originally|before this|the old |this was |first pass|second pass)/)
				print NR ": describes history, not current state"
		} else {
			flush()
		}
	}

	END { flush() }
')

[ -z "$FINDINGS" ] && exit 0

COUNT=$(printf '%s\n' "$FINDINGS" | grep -c .)
SUMMARY=$(printf '%s' "$FINDINGS" | tr '\n' ';' | sed 's/;$//;s/;/; /g')

jq -n --arg file "$(basename "$FILE_PATH")" --arg n "$COUNT" --arg s "$SUMMARY" '{
	hookSpecificOutput: {
		hookEventName: "PreToolUse",
		additionalContext: ("Comment check on \($file): \($n) item(s), by line of the text being written: \($s). Advisory only, and the write proceeds. Say what the code does, in one line where you can. The reason for an approach goes in the commit or the PR, and history belongs in git. If the block is longer than the thing it documents, cut it. The writing-docblocks skill carries the full standard, a budget command, and scripts/check-docblocks.sh.")
	}
}'

exit 0
