# False positive patterns

Findings that look like defects and are not. Check a candidate against this list before it goes in a tier.

The rule for every entry: flag it only when the **specific case in front of you** genuinely breaks, and you can say what input produces the wrong outcome. The pattern being a common bug elsewhere is not evidence about this instance.

## Do not flag

| Pattern | Why it is usually fine |
|---|---|
| Missing error handling | The framework or the caller already handles it. Check which boundary owns the failure before flagging the level below it. |
| Well-known constants as "magic numbers" | HTTP 200/404, port 443, 1024, 60, 3600. Naming these adds indirection without adding meaning. |
| Missing comments on self-describing helpers | A comment restating the signature is noise. |
| "Function too long" | Switch tables, fixtures, config maps and data declarations are long because the data is long. Length is not complexity. |
| N+1 queries | Fixed-cardinality loops cost a constant. Check the cardinality and check for existing batching before calling it N+1. |
| `Math.random()` | Only a defect in a cryptographic context. Test seeds, jitter and sampling are fine. |
| Null dereference | Type narrowing or a guard upstream may already make it unreachable. Read the guard. |
| Style the project does not enforce | If the linter is silent and the config does not ask for it, it is your preference, not a finding. |
| Anything a linter already reports | The user runs the linter. Duplicating it pads the report. |

## Framework behaviour that reads as a bug

Confirm what the framework does before flagging the calling code. Common misreads:

- A function that returns a value on one path and an error object on another, where a filtered grep showed only one path.
- A cleanup that appears missing because the framework performs it, or appears present because a name suggests it and the body does not.
- A translated user-facing string treated as a stable identifier. Anything through a translation layer varies by locale, so neither log-grepping nor branching on it is safe.

## When a pattern is worth flagging anyway

Two cases override the list above:

1. **The instance breaks under a stated input.** You can name the value and the wrong outcome. Tier it normally.
2. **The pattern is load-bearing for a decision the user is about to make.** Say which entry it resembles and why this instance differs, so they can judge the reasoning rather than the label.

## Adding entries

New entries belong here when a finding was reported, investigated, and turned out to be nothing. Record the pattern and the reason it dissolved, not the incident.
