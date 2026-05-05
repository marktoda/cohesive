# Spec Cohesion Review — cohesion-review template cleanup

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-05
**Subject:** Five-finding follow-up to the merged delta-at-a-glance preamble convention; ledger at `docs/history/delta-ledgers/2026-05-05-cohesion-review-cleanup.md`. Files reviewed: `references/templates/cohesion-review.md`, `references/templates/design-delta-ledger.md`, `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md`, `scripts/validate_plugin.sh`, plus the design delta ledger.

**Status:** Approved

## Executive judgment

A future contributor can read these four rewritten specs and the ledger and produce conformant reviewer output, conformant ledgers, and a coherent canonical-list mental model without any prior session context. The six-field shape lands cleanly in `cohesion-review.md`; the contract/render-slot annotation is visible from both sides; the canonical pin-list is back in sync with the validator; and the `IMPLEMENTATION_PLAN_COVERS_DELTA` cross-reference makes the previously-invisible coupling a one-glance read. The malformed-filename warn surfaces what was previously silent. Ambiguities are scoped honestly in §"Remaining ambiguity" rather than smuggled in. No blocking issues.

## Delta at a glance

- **Files:** 4 rewritten, 1 added, 0 removed/deprecated
- **Conceptual changes:** "Delta at a glance" disambiguated into *canonical contract* (design-delta-ledger.md) vs *render slot* (cohesion-review.md) via annotation; cohesion-review.md issue-shape examples replaced from three-field (Risk/Substrate artifact/Suggested repair) to canonical six-field (Severity/Category/Why it matters/Evidence/Recommended fix/Substrate artifact)
- **Named invariants:** none added — convention pin 8 added to `PLUGIN_ROOT_PATHS.md` canonical list (substrate bookkeeping for an existing validator check, not a new invariant)
- **Behavior matrices:** none
- **Gotchas:** none
- **Semantic linters:** `validate_plugin.sh` check 13h tightened (added malformed-filename counter + warn-level signal when a delta-ledger filename lacks the `YYYY-MM-DD` prefix per `docs/substrate/designs/substrate-layout.md` §Naming)
- **Tests proposed:** none
- **Deferred (out of scope this pass):** the across-verdicts render rule's promotion to a multi-consumer canonical home; the cutoff-date pattern's promotion to `docs/substrate/designs/skill-conventions.md` §"Cutoff-date checks"; the delta-at-a-glance preamble convention's promotion to a named invariant per `style-guide-rot.md` criteria

## Blocking issues

None.

## Important issues

### I1. Render-slot label asymmetry between contract and slot

- **Severity:** Low
- **Category:** Spec drift
- **Why it matters:** The contract side (`design-delta-ledger.md` line 13) names the render-slot's parenthetical role as "the section in a validation review document where the ledger's preamble appears verbatim," while the slot side (`cohesion-review.md` lines 13–15) describes itself as "a **render slot** in the validation review document, not the canonical contract for the preamble." Both annotations are clear in isolation, but a reader landing first on the contract document sees "render slot" as the chosen term, while a reader landing first on `cohesion-review.md` sees "render slot" introduced before they have a referent for "the canonical contract" beyond the inline cite. The contract-vs-slot framing only clicks fully if both pages are read; the ledger acknowledges this in §"Remaining ambiguity" but the asymmetry could be narrowed without renaming by mirroring one phrase.
- **Evidence:** `references/templates/cohesion-review.md:13-15`; `references/templates/design-delta-ledger.md:13`
- **Recommended fix:** In `cohesion-review.md` §"Delta at a glance" add a one-line mirror noting that the ledger §"Delta at a glance" is the *canonical contract* using the same bolded term the contract side uses — symmetric vocabulary makes the relationship readable from either entry point.
- **Substrate artifact to add or update:** spec — `references/templates/cohesion-review.md` §"Delta at a glance"

### I2. Pin 8's enforcement story names two halves but does not name the warn-level signal

- **Severity:** Low
- **Category:** Enforcement
- **Why it matters:** The pin 8 entry (`PLUGIN_ROOT_PATHS.md:49`) describes the grep as "the presence half of a two-fence model whose accuracy half is the per-dispatch reviewer judgment in `agents/spec-cohesion-reviewer.md` 'What you check' item 11." This frames the enforcement model as a two-fence (presence + accuracy) model. Check 13h now also emits a warn-level signal on malformed filenames (`validate_plugin.sh:438-441`, `:454-456`); that's a third surface — adjacent to the preamble check, not part of the two-fence model — and the canonical-list entry doesn't name it. A future reader of pin 8 sees a clean two-fence story; a reader of the validator script sees a third counter and warning. The drift is small now because the malformed signal is warn-level and adjacent rather than load-bearing, but the canonical list is the document that's supposed to prevent this exact kind of drift between docs and validator.
- **Evidence:** `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md:49`; `scripts/validate_plugin.sh:432-457`
- **Recommended fix:** Add one phrase to the pin 8 entry naming the warn-level malformed-filename signal as an adjacent (not load-bearing) surface, citing `substrate-layout.md` §Naming as its source-of-truth and naming the promotion path (warn → fail when a dedicated filename-validation check ships).
- **Substrate artifact to add or update:** spec — `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md` §"Convention pins enforced alongside this invariant (canonical list)" pin 8

## Substrate gaps

None observed in this pass. The deferrals listed in ledger §"What this rewrite did not do" are scoped with promotion targets and are not gaps this rewrite was supposed to close.

## Locality concerns

None. The annotation route preserves locality — both surfaces self-describe their role without requiring the reader to chase a third document for disambiguation. The cross-reference from `design-delta-ledger.md` §"Authoring rules" to `IMPLEMENTATION_PLAN_COVERS_DELTA` Phase 1 coverage shape is a single one-line note, not a centralization.

## Future-fit concerns

None. Future pressure (filename-validation promotion to fail-level, cutoff-date convention promotion to skill-conventions.md, preamble convention promotion to named invariant) is named in §"Remaining ambiguity" and §"What this rewrite did not do" with concrete trigger conditions, not smuggled into normative scope.

## Enforcement concerns

The voice-imperative pair (pins 6/7) and the verdict-leads invariant (pin 5) carry "Shared ownership" prose at `PLUGIN_ROOT_PATHS.md:53` describing how scope changes propagate. Pin 8 stands alone — the canonical contract is `design-delta-ledger.md` §"Delta at a glance" and the accuracy half is in the reviewer agent, but no shared-ownership note describes how a wording change in the canonical contract should propagate to the validator's grep target (`## Delta at a glance`) and to pin 8's prose. The wording is currently stable; this is a thin observation, not a gap.

## Behavior knowable outside implementation?

Yes. A future contributor with no session context can: reproduce the canonical six-field issue shape from `cohesion-review.md` lines 21–27 alone; identify which document is the contract surface from `design-delta-ledger.md` line 13 alone; understand check 13h's three-counter shape from `validate_plugin.sh:432-457` alone; and trace the preamble-category-list to Phase 1 coverage shape via the new cross-reference at `design-delta-ledger.md:28`.

## Vague language to tighten

None observed in normative sections.

## Recommended repairs (ranked)

1. I2 (canonical-list completeness): one-phrase addition to pin 8 naming the malformed-filename warn signal as an adjacent surface with a promotion path. Highest leverage because the canonical list is the substrate-against-drift surface itself.
2. I1 (vocabulary symmetry): mirror "canonical contract" by name on the render-slot side. Low cost, narrows a remaining-ambiguity entry by one notch.

## What looked right

- §"Delta at a glance" in `design-delta-ledger.md` lines 11–13 — the contract framing names itself as canonical, names the render-slot surface by file and section, and explains why the contract/slot split exists in two sentences without re-stating the rules. This is the load-bearing move and it lands.
- The six-field B1/I1 examples in `cohesion-review.md` lines 21–27 with the lead-in at lines 17–19 citing `reviewer-agent-template.md` §"Output format conventions" *and* naming the synthesizer-consumers (`validate-rewrite`, `cohesive:review-codebase`, `cohesive:review-diff`). The "uniform shape across reviewer agents" justification is exactly the substrate-coupling argument that should drive a shape change.
- Pin 8 in `PLUGIN_ROOT_PATHS.md:49` carries both the canonical contract citation and the natural promotion target (`skill-conventions.md` §"Cutoff-date checks") in one bullet — the substrate trail forward is preserved without committing to the move.
- Check 13h's three-counter ok-line surface (`validate_plugin.sh:454-456`) — `preamble_check_count`, `preamble_skipped_count`, `preamble_malformed_count` — gives a reader of the validator output a complete partition of the ledger directory in one line. That's the right shape for a check that's deliberately warn-level on one dimension and fail-level on another.
