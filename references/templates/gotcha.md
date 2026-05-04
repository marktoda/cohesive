# Gotcha: [name]

> A documented scar. Names a recurring failure mode, dangerous helper, or tempting wrong fix so future contributors don't rediscover the bug or commit the wrong fix.

## Symptom

What goes wrong, observably. The thing a contributor would notice in production, in tests, or in code review.

## Why it happened

The underlying cause. Often a subtle interaction the codebase doesn't (yet) make visible. Be specific — name files, functions, runtime paths, sequencing.

## Tempting wrong fix

The fix that looks reasonable, makes the symptom go away, but introduces or perpetuates the underlying problem. This is the most valuable section of a gotcha doc — it warns future contributors away from the obvious-but-wrong move.

## Correct pattern

The right fix. What the system does (or should do) instead. Reference specific files, helpers, or invariants where possible.

## Related invariant

If the gotcha is an instance of an invariant violation: name the invariant. If the gotcha *led* to creating an invariant: name it.

- Invariant: `<INVARIANT_NAME>` — <relationship>

## Tests / checks that preserve this

The structural enforcement that catches future regressions:

- <test path> — fails when the bug recurs
- <linter rule> — flags the tempting wrong fix at lint time
- <CI check> — gates against the symptom

If this list is empty, the gotcha is enforced by reviewer memory. Add at least one structural check, or note explicitly why it can't be automated.

## When this was discovered

- Date: YYYY-MM-DD
- Incident or PR: <link>
- One-line summary of the original encounter

## Notes for future contributors

Anything else a reader needs to know to avoid the trap. Examples of related code patterns to be skeptical of. Pointers to other gotchas in the same area.
