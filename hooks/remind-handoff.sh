#!/bin/bash
# UserPromptSubmit advisory: nudge to run the handoff skill's close-out on long
# sessions without a recent HANDOFF.md. The skill decides whether a document is
# the right channel, so this does not assume /clear is the next move.
# Policy: advisory only (exit 0), surfaced before the next prompt.
# Rate-limited to once per session per condition (cleared on SessionStart clear|resume).
# Requires jq.

command -v jq > /dev/null 2>&1 || exit 0

INPUT=$(cat)

EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // ""')
[ "$EVENT" != "UserPromptSubmit" ] && exit 0

CWD=$(echo "$INPUT" | jq -r '.cwd // ""')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // ""')
TRANSCRIPT=$(echo "$INPUT" | jq -r '.transcript_path // ""')

[ -z "$SESSION_ID" ] && exit 0
[ -z "$TRANSCRIPT" ] || [ ! -f "$TRANSCRIPT" ] && exit 0
[ -z "$CWD" ] || [ ! -d "$CWD" ] && exit 0

# Threshold: ~200 transcript events. Long enough that /clear would lose real work.
THRESHOLD=200
LINES=$(wc -l < "$TRANSCRIPT" 2>/dev/null | tr -d ' ')
[ -z "$LINES" ] && exit 0
[ "$LINES" -lt "$THRESHOLD" ] && exit 0

# Skip if a handoff exists and was touched in the last hour - user already handed off.
# The skill writes docs/HANDOFF.md relative to the repo root, so check there first.
# The bare paths are kept for projects that don't use a docs/ directory. Checking only
# ${CWD}/HANDOFF.md meant this suppression never fired.
ROOT=$(git -C "$CWD" rev-parse --show-toplevel 2>/dev/null || echo "$CWD")
NOW=$(date +%s)

# The skill's own ceiling. Prose telling the model to prune is read once at
# invocation and abandoned under task pressure; the growth this guards against
# is invisible from inside a single session, which is why it is measured here.
CEILING=${HANDOFF_CEILING:-120}
OVERSIZE=""

for HANDOFF in "$ROOT/docs/HANDOFF.md" "$CWD/docs/HANDOFF.md" "$ROOT/HANDOFF.md" "$CWD/HANDOFF.md"; do
	[ -f "$HANDOFF" ] || continue
	HLINES=$(wc -l < "$HANDOFF" 2>/dev/null | tr -d ' ')
	if [ -n "$HLINES" ] && [ "$HLINES" -gt "$CEILING" ]; then
		OVERSIZE="$HANDOFF is ${HLINES} lines, past the ${CEILING}-line ceiling."
		break
	fi
	MTIME=$(stat -f %m "$HANDOFF" 2>/dev/null || stat -c %Y "$HANDOFF" 2>/dev/null)
	if [ -n "$MTIME" ] && [ $((NOW - MTIME)) -lt 3600 ]; then
		exit 0
	fi
done

# Skip if the handoff skill itself ran in the last hour. Close-out can correctly
# write no document at all, when a live session was messaged or nothing crossed a
# boundary, and the mtime check above cannot see that. Without this, such a session
# gets nudged every 30 minutes for the rest of its life.
# The transcript entry is an assistant tool_use with a compact "skill":"handoff"
# input. The optional prefix matches a plugin-namespaced invocation ("handoff:handoff"),
# which a bare '"skill":"handoff"' pattern misses on the closing quote.
# BSD date needs TZ=UTC to read the ISO 8601 Z stamp as UTC rather than local; the
# fractional seconds are cut because %S rejects them. GNU date is the fallback, and a
# failure of both leaves RUN_TS empty, which fails open into nudging.
# An oversized document is exempt from this suppression. A close-out that just
# ran and left 200 lines behind is the case the ceiling exists for, and
# suppressing on "the skill ran" would silence it exactly then.
LAST_RUN=$(grep -E '"skill":"([A-Za-z0-9_-]+:)?handoff"' "$TRANSCRIPT" 2>/dev/null | tail -1 \
	| jq -r '.timestamp // empty' 2>/dev/null)
if [ -n "$LAST_RUN" ] && [ -z "$OVERSIZE" ]; then
	STAMP="${LAST_RUN%%.*}"
	RUN_TS=$(TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "$STAMP" +%s 2>/dev/null \
		|| date -u -d "${STAMP}Z" +%s 2>/dev/null)
	if [ -n "$RUN_TS" ] && [ $((NOW - RUN_TS)) -lt 3600 ]; then
		exit 0
	fi
fi

# Rate-limit: once per 30 min per session for this condition.
CACHE_FILE="${TMPDIR:-/tmp}/claude-remind-handoff-${SESSION_ID}.state"
LAST_TS="0"
if [ -s "$CACHE_FILE" ]; then
	LAST_TS=$(cat "$CACHE_FILE")
fi
if [ $((NOW - LAST_TS)) -lt 1800 ]; then
	exit 0
fi

echo "$NOW" > "$CACHE_FILE" 2>/dev/null
if [ -n "$OVERSIZE" ]; then
	echo "HANDOFF: $OVERSIZE Prune it before adding anything. Sections that are snapshots of the tree (file lists, git state, pasted command output) are the usual cause, and durable facts belong in auto memory or a path-scoped rule instead."
else
	echo "HANDOFF: Long session (${LINES} transcript events). Consider invoking the handoff skill to close out: it lands the loose threads, tidies merged branches and worktrees, and picks the channel, writing HANDOFF.md only where nobody is on the far side."
fi

exit 0
