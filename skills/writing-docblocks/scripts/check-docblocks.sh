#!/bin/bash
# Checks that every docblock in a file still agrees with the declaration
# beneath it: @param names present, in signature order, none missing and
# none left over. This is step 5 of the skill, and it is the check most
# often skipped, because doing it by eye across a long file is tedious
# and a stale @param looks correct until someone trusts it.
#
# Handles PHP, JavaScript and TypeScript. Reports what it could not parse
# rather than passing it silently, since a false clean is worse than a
# gap you know about.
#
# Usage: check-docblocks.sh <file> [<file>...]
# Exits 0 when every block agrees, 1 when any disagrees, 2 on bad usage.

set -uo pipefail

[ $# -eq 0 ] && { echo "usage: check-docblocks.sh <file> [<file>...]" >&2; exit 2; }

STATUS=0

for FILE in "$@"; do
	if [ ! -f "$FILE" ]; then
		echo "$FILE: not a file" >&2
		STATUS=1
		continue
	fi

	case "$FILE" in
		*.php) LANG=php ;;
		*.js|*.jsx|*.mjs|*.cjs|*.ts|*.tsx) LANG=js ;;
		*)
			echo "$FILE: no signature parser for this extension; check by hand against references/generic.md"
			continue
			;;
	esac

	awk -v lang="$LANG" -v file="$FILE" '
	function reset_block() {
		in_block = 0
		np = 0
		has_return = 0
		block_line = 0
		delete params
	}

	function trim(s) {
		sub(/^[ \t]+/, "", s)
		sub(/[ \t]+$/, "", s)
		return s
	}

	# Strip a default value, type annotation, and modifiers from one
	# declared parameter so only the name is left.
	function param_name(raw,   s, n, parts) {
		s = trim(raw)
		sub(/=.*$/, "", s)
		s = trim(s)
		if (lang == "php") {
			# Last $-prefixed token wins: types and & and ... precede it.
			if (match(s, /\$[A-Za-z_][A-Za-z0-9_]*/)) {
				return substr(s, RSTART + 1, RLENGTH - 1)
			}
			return ""
		}
		# JS/TS: drop a type annotation, a spread, and access modifiers.
		sub(/:.*$/, "", s)
		sub(/^\.\.\./, "", s)
		sub(/^(public|private|protected|readonly)[ \t]+/, "", s)
		s = trim(s)
		if (s ~ /^[A-Za-z_$][A-Za-z0-9_$]*$/) return s
		return "?destructured"
	}

	/\/\*\*/ {
		reset_block()
		in_block = 1
		block_line = NR
	}

	in_block && /@param/ {
		line = $0
		if (lang == "php") {
			# @param type $name Description.
			if (match(line, /\$[A-Za-z_][A-Za-z0-9_]*/)) {
				params[++np] = substr(line, RSTART + 1, RLENGTH - 1)
			}
		} else {
			# JSDoc: @param {type} name | @param {type} [name=default]
			# TSDoc: @param name - description
			rest = line
			sub(/^.*@param[ \t]*/, "", rest)
			sub(/^\{[^}]*\}[ \t]*/, "", rest)
			sub(/^\[/, "", rest)
			if (match(rest, /^[A-Za-z_$][A-Za-z0-9_$.]*/)) {
				name = substr(rest, RSTART, RLENGTH)
				sub(/\..*$/, "", name)   # a.b documents a property of a
				if (name != "") params[++np] = name
			}
		}
	}

	in_block && /@returns?/ { has_return = 1 }

	in_block && /\*\// {
		in_block = 0
		awaiting = 1
		sig = ""
		next
	}

	awaiting {
		sig = sig " " $0
		# Accumulate until the parameter list closes. Deliberately not
		# named open/close: close is an awk built-in and shadowing it
		# is a syntax error, not a warning.
		nopen = gsub(/\(/, "(", $0)
		nclose = gsub(/\)/, ")", $0)
		depth += nopen - nclose
		if (sig !~ /\(/) {
			# Not a declaration yet. Attributes, decorators and
			# modifiers can sit between the block and the signature.
			if ($0 ~ /^[ \t]*(#\[|@|export|declare|abstract|final|static|public|private|protected|async|readonly)/ || trim($0) == "") next
			# Anything else means this block documents a non-callable.
			awaiting = 0
			depth = 0
			next
		}
		if (depth > 0) next

		awaiting = 0
		depth = 0

		# Pull out the parameter list.
		if (!match(sig, /\(/)) next
		inner = substr(sig, RSTART + 1)
		d = 1
		out = ""
		for (i = 1; i <= length(inner); i++) {
			c = substr(inner, i, 1)
			if (c == "(" || c == "[" || c == "{") d++
			else if (c == ")" || c == "]" || c == "}") { d--; if (d == 0) break }
			out = out c
		}

		# Split on commas at nesting depth zero only, so a default of
		# {a: 1, b: 2} or a generic like Record<string, number> stays
		# one parameter. Angle brackets count, with the arrow of an
		# inline callback excluded so => does not unbalance the depth.
		ns = 0
		d = 0
		buf = ""
		for (i = 1; i <= length(out); i++) {
			c = substr(out, i, 1)
			prev = (i > 1 ? substr(out, i - 1, 1) : "")
			if (c == "(" || c == "[" || c == "{") d++
			else if (c == "<" && prev != "=" && prev != "<") d++
			else if (c == ")" || c == "]" || c == "}") d--
			else if (c == ">" && prev != "=" && d > 0) d--
			if (d < 0) d = 0
			if (c == "," && d == 0) { sigp[++ns] = buf; buf = ""; continue }
			buf = buf c
		}
		if (trim(buf) != "") sigp[++ns] = buf

		nsig = 0
		delete signames
		for (i = 1; i <= ns; i++) {
			n = param_name(sigp[i])
			if (n != "") signames[++nsig] = n
		}

		# Name the thing, for the report.
		name = "?"
		if (match(sig, /function[ \t]+[A-Za-z_$][A-Za-z0-9_$]*/)) {
			name = substr(sig, RSTART, RLENGTH)
			sub(/^function[ \t]+/, "", name)
		} else if (match(sig, /[A-Za-z_$][A-Za-z0-9_$]*[ \t]*\(/)) {
			name = substr(sig, RSTART, RLENGTH)
			sub(/[ \t]*\($/, "", name)
		}

		problems = ""
		unverifiable = 0
		for (i = 1; i <= nsig; i++) if (signames[i] == "?destructured") unverifiable = 1

		if (np == 0 && nsig > 0) {
			problems = problems sprintf("\n    no @param at all, but the signature takes %d", nsig)
		} else if (np != nsig && !unverifiable) {
			problems = problems sprintf("\n    %d @param rows against %d parameters", np, nsig)
		}

		if (!unverifiable) {
			m = (np < nsig ? np : nsig)
			for (i = 1; i <= m; i++) {
				if (params[i] != signames[i]) {
					problems = problems sprintf("\n    position %d: @param names %s, signature declares %s", i, params[i], signames[i])
				}
			}
			for (i = m + 1; i <= nsig; i++) {
				problems = problems sprintf("\n    %s is undocumented", signames[i])
			}
			for (i = m + 1; i <= np; i++) {
				problems = problems sprintf("\n    @param %s has no matching parameter", params[i])
			}
		}

		if (problems != "") {
			printf "%s:%d  %s%s\n", file, block_line, name, problems
			bad++
		} else if (unverifiable && np > 0) {
			printf "%s:%d  %s\n    destructured or complex parameter; @param agreement not checkable here, read it by hand\n", file, block_line, name
			skipped++
		} else {
			ok++
		}

		reset_block()
		delete sigp
		delete signames
	}

	END {
		printf "%s: %d block(s) agree", file, ok + 0
		if (bad > 0) printf ", %d disagree", bad
		if (skipped > 0) printf ", %d need a manual read", skipped
		printf "\n"
		exit (bad > 0 ? 1 : 0)
	}
	' "$FILE" || STATUS=1
done

if [ "$STATUS" -ne 0 ]; then
	echo
	echo "Fix the disagreements before reporting done. A block that contradicts its"
	echo "declaration is worse than no block, because it gets trusted."
else
	# Printed on success on purpose. Exit 0 is the moment a sentence written
	# from memory about a called function survives into the file.
	echo
	echo "Names only. This compared @param lists against signatures; it did not read"
	echo "a word you wrote. Any sentence about what a CALLED function does is still"
	echo "unverified. Open that function before you keep the claim."
fi

exit "$STATUS"
