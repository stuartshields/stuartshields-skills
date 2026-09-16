#!/bin/bash
# PreToolUse advisory for code comments: rejected-alternative prose, session
# history, and overlong blocks. Declared in ../../../hooks/hooks.json at the
# plugin root rather than in a skill's frontmatter, so it runs whenever the
# plugin is enabled instead of only after something invokes the skill.
#
# That placement is the point. A comment is almost never the stated task, so the
# skill goes uninvoked while comments are written anyway, and a guard that waits
# for invocation waits forever.
#
# ADVISORY, NEVER BLOCKING. Every phrase here has a legitimate use: a comment
# genuinely recording why an approach was rejected is what ../references/
# comments.md asks for. The signal is length, not vocabulary. Report and let the
# model judge; exit 2 is the wrong instrument for a style signal.

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

FINDINGS=$(printf '%s' "$TEXT" | awk '
	# A sentence naming why an approach was rejected is what references/comments.md
	# asks for; a paragraph arguing it is ADR material. So the vocabulary hits are
	# held until the run ends and reported only once the run is paragraph-length.
	# History is wrong at any length and reports immediately.
	function flush(   n) {
		n = run_prose
		if (n > 5) print run_start ": " n " consecutive comment lines"
		if (n >= 3 && pending != "") printf "%s", pending
		run = 0; run_prose = 0; pending = ""
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
			# Requiring a letter after the marker drops tag rows, which start at `@`.
			# Testing the whole line for `@` instead would drop any sentence naming
			# an `@scope/package`. `=>` and a trailing comma or brace mark a
			# multi-line `@return {{...}}` type, which is a signature, not narration.
			# The loose test is only for a continuation line carrying no marker of
			# its own. Applying it to a marked line would count `@param` rows as
			# prose, since a JSDoc block is itself an open `/* ... */`.
			if (probe ~ /^[ \t]*(\*|\/\/|#|\/\*)/) {
				if (probe ~ /^[ \t]*(\*|\/\/|#|\/\*)[ \t]+[A-Za-z`]/ && probe !~ /(=>|[,{}][ \t]*$)/) run_prose++
			} else if (was_open && probe ~ /[A-Za-z]/) run_prose++

			low = tolower(line)
			if (low ~ /(rather than|instead of|as opposed to|we chose|would fight|avoids that)/)
				pending = pending NR ": argues against an alternative\n"
			if (low ~ /(previously|used to |no longer|originally|before this|the old |this was |first pass|second pass)/)
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
		additionalContext: ("Comment check on \($file): \($n) item(s), by line of the text being written: \($s). Advisory only, and the write proceeds. A sentence naming why an approach was rejected is legitimate; a paragraph arguing it is ADR material and goes stale first. Keep the constraint, drop the case for it. History belongs in git, not above the code. If the block is longer than the thing it documents, it is telling a story. The writing-docblocks skill carries the full standard, a budget command, and scripts/check-docblocks.sh.")
	}
}'

exit 0
