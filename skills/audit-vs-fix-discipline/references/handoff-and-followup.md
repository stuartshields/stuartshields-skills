# Handoff and follow-up

What happens to findings after the report is delivered.

## Findings outlive the session

The usual shape: an audit produces tiers, the user fixes one tier, the rest wait behind a `/clear`. So the numbering in the original report is an address other people use later.

**When the user asks to fix a tier**, fix that tier and report against the original numbering. P1.2 stays P1.2 after P1.1 is fixed. Renumbering the survivors makes every earlier reference in the conversation wrong.

**When a fix changes the picture for another finding**, say so against that finding's number rather than silently dropping it. A finding that dissolved because of an adjacent fix is a result, not an omission.

## Recording before a clear

Outstanding findings must reach `docs/HANDOFF.md` in full: tier, `file:line`, and the one-line problem for each. A handoff saying "6 P2s remain" cannot be worked from, because the next session has to redo the audit to find out what they were.

Include for each surviving finding:

- Tier and original number.
- `file:line`.
- The one-line problem statement.
- The failure scenario if it was established, since that is the expensive part to reconstruct.
- Anything already ruled out, so the next session does not re-investigate it.

See the `handoff` skill for the surrounding process.

## Findings the user declines

Record the decision next to the finding, with the reason given. A declined finding that reappears in the next audit with no memory of the decision wastes the user's time twice: once reading it, once re-explaining.

Two decisions are worth distinguishing:

- **Won't fix**: understood and accepted. Do not raise it again unless the surrounding code changes.
- **Not now**: still live. It belongs in the handoff.

## Verification is not optional after a fix

A tier reported as fixed needs the same evidence standard as the finding did. Run the test, read the changed lines back, say which command settled it. "Fixed" without evidence recreates the problem the audit existed to prevent.
