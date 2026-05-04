# Design Delta Ledger — [topic]

**Date:** YYYY-MM-DD
**Worktree / branch:** <path or branch>
**Approved direction:** <one sentence — which option from brainstorm-design was chosen>

This ledger records *what changed* in the substrate during a `rewrite-specs` pass. It exists so the fresh-eyes reviewer (and future readers) can see the rewrite as a delta, not as 'a bunch of files moved around.'

## Files rewritten

For each file whose normative content changed:

- `path/to/file.md`
  - **Before:** <one sentence describing what it claimed>
  - **After:** <one sentence describing what it now claims>
  - **Reason:** <which design decision drove the rewrite>

## Files added

- `path/to/new-file.md` — <one-line purpose>

## Files removed or deprecated

- `path/to/removed.md` — <why; what replaced it; whether it was deleted or marked deprecated>

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| <name> | <name> | Replaced / Merged / Removed / Tightened / Renamed |

## New or updated substrate

### Specs
- <path> — what it now says
- ...

### Behavior matrices
- <path> — cells added / removed / renamed
- ...

### Named invariants
- `INVARIANT_NAME` — added / strengthened / weakened / removed; current scope
- ...

### Gotchas
- <name> — added / updated; what scar it now records
- ...

### Semantic linter specs
- <name> — proposed; what it would enforce; not yet implemented
- ...

### Tests / checks proposed (not yet implemented)
- <description> — what behavior it would pin
- ...

## What this rewrite *did not* do

- Implementation code: not changed
- Tests: not changed (specifications proposed for follow-up)
- CI: not changed
- <other deliberate non-changes>

## Remaining ambiguity

Things the rewrite couldn't fully resolve and that the fresh-eyes reviewer should flag:

- <ambiguity>: <why it was left open>

## Ready for fresh-eyes review?

**Yes / No** — <if no, what's blocking>

## How to read this ledger

The intent is that a reviewer can:
1. Read the "Approved direction" line and know the destination.
2. Skim "Conceptual changes" and know what's *different*.
3. Read "Files rewritten" with before/after snippets to verify each rewrite.
4. Use "Remaining ambiguity" as the focused review punch list.
