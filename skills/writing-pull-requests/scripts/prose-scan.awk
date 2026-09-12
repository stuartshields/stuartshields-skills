# Shared prose scanner. Reads text on stdin, emits one tab-separated record per
# hit: LINE <tab> FINDING <tab> SNIPPET
#
# Called by prose-tells-guard.sh, which advises on Markdown writes. Written to
# be shared: a second caller that wants to log prose drift can run the same
# scanner, and a second copy of these patterns would drift from the first.
# The list is written out for reading in ../references/prose.md; keep the two
# in step.
#
# macOS ships BWK awk (one true awk), which supports neither IGNORECASE nor the
# GNU \< word boundary. Both fail silently, matching nothing, so this uses
# tolower() plus an explicit character-class boundary. Verified against awk
# version 20200816; do not reintroduce the gawk idioms.

BEGIN {
	fence = 0
	frontmatter = 0
	FS = "\n"
	# Sentence-length checking is opt-in. prose-tells-guard.sh turns it on for
	# Markdown writes, where a 40-word sentence is worth catching before the file
	# lands. A caller that logs prose over time leaves it off, so its windows
	# stay comparable with each other.
	if (LONG == "") LONG = 0
	# Chosen from the corpus, not from the style target. The target is 20 words,
	# but > 20 fires on 9% of real sentences and an advisory that common gets
	# ignored. > 30 fires on 1%, and those are the ones that are actually hard to
	# read. The 21 to 30 band stays a judgement call.
	if (LONG_MAX == "") LONG_MAX = 30
}

# Frontmatter is configuration, not prose. A skill description is deliberately
# long because it carries trigger vocabulary, so measuring it as a sentence
# reports the longest "sentences" in the tree and teaches you to skim.
NR == 1 && /^---[[:space:]]*$/ { frontmatter = 1; next }
frontmatter && /^---[[:space:]]*$/ { frontmatter = 0; next }
frontmatter { next }

# Fenced blocks are skipped whole: a code sample legitimately contains anything.
/^[[:space:]]*(```|~~~)/ { fence = !fence; next }
fence { next }

function emit(finding) {
	print NR "\t" finding "\t" snippet
}

function tell(word, label,    pat) {
	# Inflections carry the same tell ("unlocks", "crucially"), but "robustness"
	# falls outside this set on purpose: robustness testing is a real term.
	pat = "(^|[^a-z])" word "(s|es|ed|ing|ly)?([^a-z]|$)"
	if (l ~ pat) emit(label)
}

{
	line = $0
	gsub(/`[^`]*`/, "", line)             # inline code spans
	gsub(/\[[^]]*\]\([^)]*\)/, "", line)  # link targets carry hyphens and dashes
	l = tolower(line)

	snippet = line
	gsub(/^[[:space:]]+|[[:space:]]+$/, "", snippet)
	if (length(snippet) > 70) snippet = substr(snippet, 1, 70) "..."

	if (line ~ /—/) emit("em dash")

	# style.md keeps en dashes for numeric and word ranges, so only flag one that
	# is not sitting between digits. This precision is the point of a checker: the
	# rule could not express the exception without suppressing it.
	if (line ~ /–/ && line !~ /[0-9][[:space:]]*–[[:space:]]*[0-9]/)
		emit("en dash outside a numeric range")

	# Vocabulary whose function is to assert significance rather than show it.
	n = split("seamless,delve,vibrant,bustling,nestled,testament,holistic,synergy,tapestry", assert, ",")
	for (i = 1; i <= n; i++)
		tell(assert[i], "\"" assert[i] "\" asserts significance")

	if (l ~ /not just [^,]*,? (but|it.s)/) emit("negative parallelism")
	if (l ~ /more than just/)              emit("\"more than just\"")
	if (l ~ /dive into/)                   emit("\"dive into\"")
	if (l ~ /in today.s/)                  emit("\"in today's\"")
	if (l ~ /pivotal moment/)              emit("\"pivotal moment\"")
	if (l ~ /marks a shift/)               emit("\"marks a shift\"")
	if (l ~ /serves as/)                   emit("\"serves as\"")
	if (l ~ /underscor(es|ing) the/)       emit("\"underscores the\"")

	# Throat-clearing and filler, kept to seven of the highest-precision forms.
	# The list could be five times this length; it is not, because the scanner's
	# value is that a report means something. A check that fires on most
	# paragraphs gets skimmed, which is the same reasoning behind LONG_MAX = 30.
	# Sentence shapes a regex cannot match are documented in the
	# writing-documentation skill under references/tells.md, not in this file.
	if (l ~ /here.s (the thing|what|why|how)/) emit("throat-clearing opener")
	if (l ~ /it.s worth noting/)           emit("\"it's worth noting\"")
	if (l ~ /at the end of the day/)       emit("\"at the end of the day\"")
	if (l ~ /when it comes to/)            emit("\"when it comes to\"")
	if (l ~ /in a world where/)            emit("\"in a world where\"")
	if (l ~ /let that sink in/)            emit("\"let that sink in\"")
	if (l ~ /at its core/)                 emit("\"at its core\"")

	# Real technical senses exist for these, so they are named separately rather
	# than lumped in. Flat lists are what make a denylist read as arbitrary.
	m = split("robust,leverage,elevate,crucial,unlock", check, ",")
	for (i = 1; i <= m; i++)
		tell(check[i], "\"" check[i] "\" needs a usage check")

	if (LONG) check_length()
}

# A table row, heading or blockquote is not a sentence, and a list marker is not
# a word. Everything else gets split on terminal punctuation and counted.
function check_length(    body, parts, k, j, words, w, count, saved) {
	if (line ~ /^[[:space:]]*(\||#|>)/) return
	body = line
	sub(/^[[:space:]]*([-*+]|[0-9]+\.)[[:space:]]+/, "", body)
	# A bold lead-in ends ".**" before the space, so the boundary regex below finds
	# no break and welds the lead-in onto the sentence following it.
	gsub(/\*\*|__/, "", body)
	k = split(body, parts, /[.!?][[:space:]]+/)
	for (j = 1; j <= k; j++) {
		count = split(parts[j], words, /[[:space:]]+/)
		w = 0
		for (i = 1; i <= count; i++)
			if (words[i] ~ /[A-Za-z]/) w++
		if (w > LONG_MAX) {
			saved = snippet
			snippet = substr(parts[j], 1, 70)
			if (length(parts[j]) > 70) snippet = snippet "..."
			emit("long sentence (" w " words)")
			snippet = saved
		}
	}
}
