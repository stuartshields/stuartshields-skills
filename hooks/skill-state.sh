# Sourced by the plugin-level hooks: which skills have been invoked this session.
# A PostToolUse hook on Skill writes the marker. The transcript fallback covers a
# slash command typed at the prompt, which never passes through the Skill tool.

skill_state_dir() {
	printf '%s/stuartshields-skills-%s' "${TMPDIR:-/tmp}" "$1"
}

# skill_invoked <session_id> <transcript_path> <skill-name>
skill_invoked() {
	local dir
	dir=$(skill_state_dir "$1")
	[ -f "$dir/$3" ] && return 0
	[ -f "$2" ] || return 1
	grep -qE "(\"skill\":\"([^\":]*:)?$3\"|Base directory for this skill: [^\"\\\\]*/$3|<command-name>/([^<:]*:)?$3<)" "$2" || return 1
	mkdir -p "$dir" && touch "$dir/$3"
}
