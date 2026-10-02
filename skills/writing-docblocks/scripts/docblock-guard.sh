#!/bin/bash
# PreToolUse advisory for code comments: session history and overlong blocks.
# Registered in the plugin-wide hooks.json under a plugin install, and
# in ../SKILL.md frontmatter under ~/.claude/skills/. A hook command cannot use
# ${CLAUDE_SKILL_DIR}: Claude Code substitutes it into a skill's allowed-tools
# and body text only, and never exports it to the hook process, so a path built
# from it expands to /scripts/...
#
# ADVISORY, NEVER BLOCKING. "the old" and "no longer" can appear in a comment
# about current state. Report and let the model judge; exit 2 is the wrong
# instrument for a style signal.
#
# A reason is not flagged. The skill treats the reason behind an approach, an
# exception or a value as the one thing a comment can say that code cannot.

# Requires jq. Without it, fail open and silent rather than print an error on every write.
command -v jq > /dev/null 2>&1 || exit 0

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
		writing-docblocks || exit 0
fi

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
		additionalContext: ("Comment check on \($file): \($n) item(s), by line of the text being written: \($s). Advisory only, and the write proceeds. A comment is worth its line when it says what the code cannot: the reason behind an approach, an exception or a value. Cut one that restates what the code does, and keep history in git. If the block is longer than the thing it documents, cut it. The writing-docblocks skill carries the full standard, a budget command, and scripts/check-docblocks.sh.")
	}
}'

exit 0
