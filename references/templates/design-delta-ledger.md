# Design Delta Ledger — [topic]

**Date:** YYYY-MM-DD
**Worktree / branch:** <path or branch>
**Approved direction:** <one sentence — which option from brainstorm-design was chosen>

This ledger records *what changed* in the substrate during a `rewrite-specs` pass. It exists so the fresh-eyes reviewer (and future readers) can see the rewrite as a delta, not as 'a bunch of files moved around.'

## Delta at a glance

A scannable, verbatim-quotable summary of what this rewrite changes. `validate-rewrite` and its dispatched `spec-cohesion-reviewer` agent render this section verbatim into the validation review (after the Executive judgment, before the Blocking issues), so the reader of the validation review sees what's in the rewrite at decision time — what to implement, defer, or merge — without invoking another skill first.

`spec-cohesion-reviewer` verifies this preamble matches the body sections below it. A divergence — the preamble claims an invariant the body does not record, or omits a file the body rewrites — is a Blocking Issue.

Render every bullet as a count-or-name list. When a category has no entries, render `none` rather than omitting the bullet; consistent shape aids scanning. Density target: 8–15 lines of itemized content.

- **Files:** N rewritten, M added, K removed/deprecated
- **Conceptual changes:** <name1>; <name2>; <name3> — or `none`
- **Named invariants:** `INVARIANT_A` (added); `INVARIANT_B` (strengthened); `INVARIANT_C` (weakened); `INVARIANT_D` (removed) — or `none`
- **Behavior matrices:** `<matrix-1>` (added); `<matrix-2>` (cells added/removed/renamed) — or `none`
- **Gotchas:** <name1> (added); <name2> (retired) — or `none`
- **Semantic linters:** <name1> (proposed, not yet implemented); <name2> (added) — or `none`
- **Tests proposed:** <description> — or `none`
- **Deferred (out of scope this pass):** <items> — or `none`

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
2. Skim "Delta at a glance" and know the shape of the change in 8–15 lines.
3. Skim "Conceptual changes" and know what's *different* in detail.
4. Read "Files rewritten" with before/after snippets to verify each rewrite.
5. Use "Remaining ambiguity" as the focused review punch list.

The "Delta at a glance" preamble is also the surface `validate-rewrite` quotes verbatim into its rendered review, so the validation-review reader sees the same scannable summary at decision time. Keep it consistent with the body sections — the `spec-cohesion-reviewer` agent flags divergence as a Blocking Issue.
