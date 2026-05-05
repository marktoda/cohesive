# Design Delta Ledger — [topic]

**Date:** YYYY-MM-DD
**Worktree / branch:** <path or branch>
**Approved direction:** <one sentence — which option from brainstorm-design was chosen>

This ledger records *what changed* in the substrate during a `rewrite-specs` pass. It exists so the fresh-eyes reviewer (and future readers) can see the rewrite as a delta, not as 'a bunch of files moved around.'

## Delta at a glance

A scannable, verbatim-quotable summary of what this rewrite changes. `validate-rewrite` and its dispatched `spec-cohesion-reviewer` agent render this section verbatim into the validation review (after the Executive judgment, before the Blocking issues), so the reader of the validation review sees what's in the rewrite at decision time — what to implement, defer, or merge — without invoking another skill first.

This section is the **canonical contract** for the preamble's category list, authoring rules, and consumer rendering rules. `references/templates/cohesion-review.md` §"Delta at a glance" is the *render slot* that quotes the ledger's preamble verbatim into a validation review document; this section is the *contract* that defines what the preamble carries and how consumers handle it. `agents/spec-cohesion-reviewer.md` ("What you check" item 11) and `skills/validate-rewrite/SKILL.md` (Output format render template) cite this section rather than restate its contents — the single-source-of-truth shape closes the drift surface between author-side and consumer-side specifications.

### Authoring rules

Render every bullet as a count-or-name list. When a category has no entries, render `none` rather than omitting the bullet; consistent shape aids scanning. Density target: 8–15 lines of itemized content.

- **Files:** N rewritten, M added, K removed/deprecated
- **Conceptual changes:** <name1>; <name2>; <name3> — or `none`
- **Named invariants:** `INVARIANT_A` (added); `INVARIANT_B` (strengthened); `INVARIANT_C` (weakened); `INVARIANT_D` (removed) — or `none`
- **Behavior matrices:** `<matrix-1>` (added); `<matrix-2>` (cells added/removed/renamed) — or `none`
- **Gotchas:** <name1> (added); <name2> (retired) — or `none`
- **Semantic linters:** <name1> (proposed, not yet implemented); <name2> (added) — or `none`
- **Tests proposed:** <description> — or `none`
- **Deferred (out of scope this pass):** <items> — or `none`

The 8-category list above is also the substrate-shape input to `cohesive:implement-cohesively` Phase 1's coverage table — Phase 1 maps each delta-ledger entry to ≥1 implementation phase per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md`. A future rename or addition of a category here updates Phase 1's coverage shape; treat the rename as a coupled change.

### Consumer rendering rules

When a consumer (a validation review, a future implement-cohesively Phase 1 announcement, a future ledger-viewer CLI) renders the preamble, three rules govern what appears:

- **Preamble present and consistent with the body:** quote it verbatim into the consumer's `## Delta at a glance` section. No further annotation.
- **Preamble missing:** render the literal string `Preamble missing — see Blocking issues` in the consumer's `## Delta at a glance` section. The consumer raises a Blocking Issue against this template's §"Delta at a glance" pointing to the missing preamble.
- **Preamble present but inconsistent with the body** (preamble claims an invariant the body does not record, omits a file the body rewrites, names a behavior matrix not present in the body's `### Behavior matrices` section, etc.): still quote the preamble verbatim into the consumer's `## Delta at a glance` section — the reader sees what was claimed even when it is wrong — and raise a Blocking Issue naming the divergence.

`spec-cohesion-reviewer`'s "What you check" item 11 operationalizes the consistency check: compare each preamble category bullet to the corresponding body section of the same ledger.

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

This section is the **substrate residue for what the rewrite did not close**. It serves two roles, both load-bearing:

1. **Author-time entries** — ambiguities the rewriter knew were open at write-time. Format: `<short title>: <why it was left open>`.
2. **Deferred validation-review findings** — non-Blocker findings the validation review surfaced that the user chose to substrate-note rather than close inline (per the disposition rule in `${CLAUDE_PLUGIN_ROOT}/references/cohesion-rubric.md` §"Disposition rule for validation-review findings"). Format: `<finding ID, e.g., pass-1 I2 or pass-2 New-I3> — <one-line crux>: <rationale for deferral>; <link to the validation review file>`.

A deferred finding that does not land here is a substrate violation: the next reviewer cannot see it, and the same gap surfaces again in a later pass. `cohesive:validate-rewrite` reads this section on subsequent passes and treats a previously-deferred finding that still applies as either confirmation-of-deferral (no new finding needed) or escalation (if the gap is now causing drift, raise it as a fresh finding with the original ID cited).

Entries:

- <ambiguity title>: <why it was left open>
- pass-N I<n> — <crux>: <deferral rationale>; <`docs/history/reviews/...` path>

If both kinds are absent, write `none` rather than omitting the section.

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
