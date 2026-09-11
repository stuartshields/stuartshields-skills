# stuartshields-skills

Working skills for Claude Code, in one plugin. Install once and every skill below comes with it.

## Install

```
/plugin marketplace add stuartshields/stuartshields-skills
/plugin install stuartshields-skills@stuartshields-skills
```

A plugin installed mid-session does not reach the skill registry until Claude Code restarts.

## Requirements

- `bash` and `jq` for the hooks. Without `jq` a hook exits silently and its skill still works.

---

## `handoff`

Passing work between sessions, and a close-out ritual for ending one on purpose.

`docs/HANDOFF.md` is the interchange format: it carries the state a fresh agent needs to continue, and nothing else. The skill covers writing that document, updating it in place, resuming from it, and deciding whether a document is the right channel at all.

### What it fixes

Handoff documents rot in two ways, and both are gradual enough that no single session notices.

They become changelogs, because appending is easier than revising. One reached 923 lines and 87 dated entries, at which point reading it cost most of the context it existed to preserve.

They become knowledge bases, which is quieter, because every entry is worth keeping. One grew a "carry-forward facts" section to 32 entries and 46,619 bytes; 63% of the file was then content no pruning rule could reach. The answer is routing: state stays in the document and gets revised, a durable fact goes somewhere it can survive.

### Use

Say "handoff", "wrap up", "close out", or "READ HANDOFF and do X". The skill picks the operation. Or invoke it directly:

```
/stuartshields-skills:handoff
```

### Its hook

`remind-handoff.sh` runs on `UserPromptSubmit`. Past 200 transcript events it suggests closing out, once per 30 minutes per session. It stays quiet when a `HANDOFF.md` was touched in the last hour, or when the skill itself ran in the last hour, because a correct close-out sometimes writes no document at all.

It is advisory: it always exits 0 and never blocks a prompt.

Date parsing uses BSD `date -j` with a GNU `date -d` fallback. The BSD path is verified; the GNU path is written but untested, and if both fail the hook fails open into nudging rather than into silence.

### Prior art

This skill was adapted and improved on from the following sources:

- [Handoff, in the Encyclopedia of Agentic Coding Patterns](https://aipatternbook.com/handoff) supplied the doctrine: a handoff is a curated state document rather than a conversation summary, and the highest-value part is what was tried and rejected.
- [maaarcooo/agent-skills](https://github.com/maaarcooo/agent-skills) supplied the mechanics. Its resume step treats recorded state as a claim to be checked against the repository, and its coverage rule keeps a thread from vanishing by accident. It keeps handoff and resume as two skills, and dated files rather than one.
- [thenguyenvn90/claude-session-handoff](https://github.com/thenguyenvn90/claude-session-handoff) shares much of the section vocabulary, and outputs to the chat rather than to a file.

How mine differs is one document revised in place rather than a new file each session, findings carried across the gap with their `file:line`, and writing, updating and resuming handled by one skill instead of two.

## Licence

MIT
