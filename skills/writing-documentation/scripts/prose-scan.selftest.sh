#!/bin/bash
# Regression guard for prose-scan.awk. Run it after any edit to that file:
#   bash skills/writing-documentation/scripts/prose-scan.selftest.sh
#
# Every expected value here was measured against the scanner rather than
# reasoned about, so a failure means behaviour changed, not that the guard
# guessed wrong.
#
# The case this exists for is the splitter. check_length() splits on
# `[.!?][[:space:]]+`, and a bullet's bold lead-in ends `.**` before the space,
# so without the `**` strip no boundary is found and the lead-in is counted as
# part of the sentence after it. That reported a 9-word lead-in plus a 26-word
# sentence as one 37-word run, and it inflated eight of eleven findings across
# one directory of rule files into false positives.
set -uo pipefail

SCANNER="$(cd "$(dirname "$0")" && pwd)/prose-scan.awk"
[ -f "$SCANNER" ] || { printf 'no scanner at %s\n' "$SCANNER" >&2; exit 1; }

FAILED=0
WORDS40="$(awk 'BEGIN{for(i=0;i<40;i++)printf "word "}')"

# Findings of one kind, for text passed on stdin. LONG is opt-in exactly as
# prose-tells-guard.sh passes it, so the guard exercises the real invocation.
count() {
	local kind="$1" long="$2"
	if [ "$long" = on ]; then
		awk -v LONG=1 -f "$SCANNER" | grep -c "$kind"
	else
		awk -f "$SCANNER" | grep -c "$kind"
	fi
}

check() {
	local label="$1" want="$2" got="$3"
	if [ "$want" = "$got" ]; then
		printf 'pass  %s\n' "$label"
	else
		printf 'FAIL  %s: wanted %s, got %s\n' "$label" "$want" "$got"
		FAILED=$((FAILED + 1))
	fi
}

BOLD_LEADIN='- **The splitter merges a bold lead-in with the sentence.** Everything after that point is counted together with the lead-in, so a bullet that is comfortably inside the limit gets reported as one very long run.'
UNDERSCORE_LEADIN='- __The splitter merges a bold lead-in with the sentence.__ Everything after that point is counted together with the lead-in, so a bullet that is comfortably inside the limit gets reported as one very long run.'
GENUINE_LONG='This control is a single genuinely long sentence that carries no bold markup at all and runs well past thirty words so that it must keep firing after the fix lands, because losing a true positive would be a worse outcome than the false one.'

# The fix itself. Both emphasis markers matter: `**` is what Markdown bullets
# use here, `__` is the equivalent the same gsub covers.
check 'bold lead-in does not weld to the next sentence' 0 \
	"$(printf '%s\n' "$BOLD_LEADIN" | count 'long sentence' on)"
check 'underscore lead-in does not weld either' 0 \
	"$(printf '%s\n' "$UNDERSCORE_LEADIN" | count 'long sentence' on)"

# The inverse defect. A checker that stopped flagging real run-ons would pass
# every assertion above while being useless, so the true positive is asserted
# with its exact word count: stripping `**` must not change the tally.
check 'a genuine run-on still fires' 1 \
	"$(printf '%s\n' "$GENUINE_LONG" | count 'long sentence' on)"
check 'its word count is unchanged by the strip' 1 \
	"$(printf '%s\n' "$GENUINE_LONG" | count 'long sentence (45 words)' on)"

# Threshold. 30 words is the measured setting, chosen because >20 fires on 9%
# of real sentences; an off-by-one here would change the finding volume.
check 'exactly 30 words is silent' 0 \
	"$(awk 'BEGIN{for(i=0;i<30;i++)printf "word ";print "."}' | count 'long sentence' on)"
check '31 words fires' 1 \
	"$(awk 'BEGIN{for(i=0;i<31;i++)printf "word ";print "."}' | count 'long sentence' on)"

# A logging caller runs the scanner with no -v LONG and reads its output as
# this window against the last one. A length finding leaking into it would
# make the two windows incomparable.
check 'length checking stays off unless asked' 0 \
	"$(printf '%s\n' "$GENUINE_LONG" | count 'long sentence' off)"

# Skipped contexts. Frontmatter is trigger vocabulary rather than prose, and a
# skill description would otherwise be the longest "sentence" in the tree.
check 'frontmatter is not prose' 0 \
	"$(printf -- '---\ndescription: %s\n---\n\nshort line.\n' "$WORDS40" | count . on)"
check 'fenced blocks are skipped whole' 0 \
	"$(printf 'ok.\n\n```\n%s\n```\n' "$WORDS40" | count . on)"
check 'a table row is not a sentence' 0 \
	"$(printf '| %s |\n' "$WORDS40" | count 'long sentence' on)"
check 'a heading is not a sentence' 0 \
	"$(printf '# %s\n' "$WORDS40" | count 'long sentence' on)"

# The other finding types, so an edit to the shared scanner cannot quietly
# break them while the length assertions above stay green.
check 'em dash is flagged' 1 \
	"$(printf 'This uses an em dash — like so.\n' | count 'em dash' on)"
check 'en dash in a numeric range is allowed' 0 \
	"$(printf 'The range is 2016–2025 inclusive.\n' | count 'en dash' on)"
check 'en dash outside a range is flagged' 1 \
	"$(printf 'The result was good – or so it seemed.\n' | count 'en dash' on)"
check 'a tell inside a code span is not prose' 0 \
	"$(printf 'The `seamless` identifier is fine.\n' | count 'seamless' on)"
check 'the same tell in prose is flagged' 1 \
	"$(printf 'It was a seamless migration.\n' | count 'seamless' on)"

# writing-pull-requests carries copies of the word list, the hook and the
# scanner so it installs alone. Each pair has to stay identical, and the only
# fixed relationship between them is being siblings in this repository, so the
# checks are skipped when the skill runs from a single-skill install.
SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PR_DIR="$(cd "$SKILL_DIR/.." && pwd)/writing-pull-requests"
if [ -d "$PR_DIR" ]; then
	for shared in references/prose.md scripts/prose-tells-guard.sh scripts/prose-scan.awk; do
		check "writing-pull-requests carries an identical $shared" 0 \
			"$(cmp -s "$SKILL_DIR/$shared" "$PR_DIR/$shared"; echo $?)"
	done
else
	printf 'skip  no sibling writing-pull-requests, shared-file sync not checked\n'
fi

if [ "$FAILED" -gt 0 ]; then
	printf '\n%s check(s) failed.\n' "$FAILED"
	exit 1
fi
printf '\nAll checks passed.\n'
