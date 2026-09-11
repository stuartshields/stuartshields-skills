---
name: audit-vs-fix-discipline
description: Use when the user asks for a code review or asks you to investigate, audit, check, scan, look at, go through, or find issues in code, especially phrased as "do a code review", "properly investigate", "look for Performance, Security, Bugs, Regression", "do not use training data", or "do not make things up". Any diagnostic request without an explicit fix verb. Also use before answering any question about what code does, whether a job or a file recurs, whether a case is already handled, or whether anything retries, cleans up, or calls something, when the answer would change what the user builds. Also use when about to write "nothing", "never", "always", "only" or "no other" about a codebase.
---

<!-- Last updated: 2026-09-11T19:05+10:00 -->

# Audit vs fix discipline

**Audits produce findings. Fixes happen separately, on explicit request.**

"Just one quick fix while I'm here" is the failure mode this exists to prevent. The round-trip is the user's checkpoint on scope.

## When this applies

Two triggers, loading different amounts of this skill.

**Full audit.** Any diagnostic verb with no fix verb: `code review`, `review`, `investigate`, `audit`, `check`, `scan`, `look at`, `look over`, `go through`, `inspect`, `find issues in`, `what's wrong with`, `how's the X looking`. Everything below applies, findings format included.

**Verification only.** Any claim about what this code does, whatever verb the user used and however short your answer will be. "Verify, don't recall" applies; the findings format does not. A question is the same obligation as an audit with a shorter output, not a lighter one.

A diagnostic verb **plus** an explicit fix verb ("audit and fix", "review and clean up", "find and fix") authorises both. Proceed through diagnosis into the fix in one pass.

An ambiguous prompt defaults to audit mode. If they meant fix, they would have said fix.

## The discipline

1. **Read-only tools only.** Read, Grep, Glob, and non-mutating Bash. No Edit, no Write, no state-changing git. Subagents inherit this, so say so in their prompt.
2. **Tier every finding.**
	- **P0**: broken behaviour, security, data loss, build or test failure.
	- **P1**: correctness risk, performance, dead code with side effects.
	- **P2**: style, naming, nits, harmless dead code.
3. **Cite `file:line` for every finding.** No location, no finding.
4. **Keep proposals out of the findings.** Refactor ideas go in a separate "Suggested follow-ups" section. A finding says "this is wrong"; a proposal says "this could be better shaped".
5. **End with the ask, then stop.** `Want me to fix any of these? Specify by number, by tier ("fix all P0"), or by file.`

## Verify, don't recall

Check each claim against the code actually in front of you. The most common way a review goes wrong is asserting what a codebase like this usually does instead of what this one does: a function that "must" exist, a flag that "should" be there, a helper assumed to work the way its name suggests.

Confirm the specific thing before flagging it. Read the caller. Grep for the definition. Run the read-only command. A finding that dissolves the moment someone opens the file costs more trust than a missed issue, because it makes every other finding suspect.

This applies equally to a clean result. "I checked X and it is fine" needs the same evidence as a finding.

State the evidence, not the verdict: the command and what it returned, rather than the conclusion drawn from it. `references/surfacing-and-evidence.md` carries that rule, with the surfacing discipline the findings format depends on.

### Three predicates, checkable before you answer

1. **Am I stating what code does without having read the thing that decides it?** A function body cannot tell you whether the function runs again: recurrence is decided by the caller and the scheduler. Intent is decided by tests and commit messages. Whether a path exists is decided by an unfiltered read, not by a grep whose pattern already assumed the answer. Check the branch too, since a question about the system is not a question about the diff in front of you.
2. **Am I about to write "nothing", "never", "always", "only" or "no other"?** Each is a claim about every path, and you have read some paths. Either read the rest, or downgrade to what you did: "I traced X and did not see Y."
3. **Would this answer change what gets built?** If yes, the size of the question does not lower the bar. A one-line answer that sends someone off to build a retry system carries the weight of the system, not of the line.

Failing one costs a tool call. Getting it wrong costs a design decision built on a false premise.

`references/search-traps.md` carries the ways a search returns nothing and reads as an answer:

- a phrase pattern that assumes word adjacency
- an untested pattern whose silence proves nothing
- a same-line `grep -v` that filters out the evidence

## Calibration

A clean audit is a valid outcome. `P0: none` is a correct answer. Manufacturing findings to populate a tier is the primary failure mode of LLM reviewers: it costs the user more time than a miss does, and teaches them to distrust the whole report.

**Gate: 80% confident with a concrete failure mode, or drop it.** Before a finding goes in a tier:

1. Can you cite the exact `file:line`?
2. Can you state the input and state that produce the wrong outcome?
3. Have you read enough around it (callers, imports, tests) to be sure?
4. Is the tier defensible: P0 broken or exploitable now, P1 a real risk under realistic conditions, P2 a nit a senior would mention in passing?

Any "no" means drop it, or move it to Suggested follow-ups where speculation is allowed to live.

**Do not flag** unless the specific case genuinely breaks. The pattern being a common bug elsewhere is not evidence about this instance.

The recurring false positives are error handling the caller already owns, well-known constants, long data declarations, N+1 on fixed cardinality, `Math.random()` outside crypto, and anything the linter reports. Check a candidate against `references/false-positive-patterns.md`, which carries the full list and the framework misreads worth ruling out first.

**Length works against accuracy here.** Elaborate review prompts and long rationales measurably increase false positives, because the pressure to produce reasoning biases toward finding fault. Stay terse, gate hard, drop liberally.

## Forbidden during an audit

- Editing any file, including an obvious typo.
- `git add`, `git commit`, or any state-changing git command.
- Bundling fixes into the report ("I've fixed the P0s and listed the rest…").
- Calling a finding **"pre-existing"**, **"unrelated"**, **"out of scope"**, or **"not worth fixing"** to avoid reporting it. Tier it and let the user decide. These phrases are fine *after* surfacing; they are a red flag used instead of surfacing. `references/surfacing-and-evidence.md` carries the rule in full, including what to do with an issue outside the asked scope.
- Skipping the closing ask, which leaves the user unsure whether you are waiting or finished.

## What happens after

Findings outlive the session: the user fixes one tier and the rest wait behind a `/clear`. Two consequences bind here. Fix a tier against the **original numbering**, so P1.2 stays P1.2 and earlier references stay valid. Before a clear, every surviving finding reaches `docs/HANDOFF.md` with its tier, `file:line` and one-line problem, because "6 P2s remain" cannot be worked from.

`references/handoff-and-followup.md` covers the rest: what to record for a declined finding, and the evidence a fix owes.

## Output

```
## Audit: <scope> (<criteria>)

### P0 (blocking)
- `path/to/file.ts:42`: <finding>. <why it matters, one sentence>.

### P1 (correctness / performance risk)
- `path/to/file.ts:88`: ...

### P2 (nits)
- `path/to/file.ts:120`: ...

### Suggested follow-ups (not findings)
- Bigger refactor ideas surfaced by the audit, clearly separated.

---
Want me to fix any of these? Specify by number, by tier ("fix all P0"), or by file.
```

Name every tier even when empty. `P0: none` is signal; an omitted header is ambiguous.

## Rationalisation table

| Excuse | Reality |
|---|---|
| "It's a one-line fix, faster to just do it." | The user can read a one-line fix from a finding. The cost is consistency, not keystrokes. |
| "Critical security bug, has to be fixed now." | Report it as P0 with the fix in the body. Timing is the user's call. |
| "Those lint errors are pre-existing." | You were asked to audit, which includes whatever you find. Tier it. |
| "I'll fix the trivial ones and report the rest." | The most common violation. Don't. |
| "I should fill P1 and P2 so it looks thorough." | Empty tiers are valid. Manufactured findings erode trust in the real ones. |
| "It might be an issue, I'll flag it just in case." | Under 80%, drop it. Speculation goes in Suggested follow-ups. |
| "This pattern is usually a bug." | Then confirm it is one *here*, in this file, before flagging it. |
| "It's just a question, not a review." | The obligation attaches to the claim, not to the user's phrasing. Skip the findings format, keep the verification. |
| "I read the function, so I read what decides it." | The task requires whatever decides the claim, usually one call site further out than feels necessary. A function cannot tell you whether it runs again. |
| "I should answer in text before reaching for tools." | Answering first stops a question springboarding into unrequested edits. It does not license answering from a file you have not opened: read-only tools are part of forming the answer. |
| "The branch I'm on is the state of the work." | Check. Feature branches lag the epic, and the answer often landed in a sibling PR. |

## When not to use

- Fixes are explicitly authorised in the same request.
- The session already established fix mode.
- The question is about your own reasoning, the user's intent, or a preference, and turns on no claim about code behaviour.

**A short question about code is not on that list.** Whether a direct answer settles a question is only knowable once you have investigated it, so it cannot be the thing that decides whether to investigate.

## Per-project override

Check the project root for `REVIEW.md` before producing findings. If it exists it wins: it carries the user's own calibration, exclusions, and scope limits for that codebase.
