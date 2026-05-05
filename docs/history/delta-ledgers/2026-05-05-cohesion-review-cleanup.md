# Design Delta Ledger — Cohesion-review template cleanup + post-merge substrate bookkeeping

**Date:** 2026-05-05
**Worktree / branch:** `.claude/worktrees/design+cohesion-review-cleanup` on `design/cohesion-review-cleanup`
**Approved direction:** Bundle the five findings from the post-merge `cohesive:review-diff` of the just-landed delta-at-a-glance preamble convention (merge commit `bfde270`) into one follow-up rewrite. Specifically: (1) tighten `references/templates/cohesion-review.md` issue-shape examples to the canonical six-field shape, citing `docs/substrate/designs/reviewer-agent-template.md` §"Output format conventions"; (2) disambiguate "Delta at a glance" by annotating cohesion-review.md as the *render slot* and design-delta-ledger.md as the *canonical contract*; (3) add convention pin 8 to `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md` canonical list naming validator check 13h; (4) add a one-line cross-reference in `references/templates/design-delta-ledger.md` §"Authoring rules" pointing to `IMPLEMENTATION_PLAN_COVERS_DELTA` Phase 1 coverage shape; (5) tighten validator check 13h to surface malformed-filename count and warn.

This ledger records *what changed* in the substrate during a `rewrite-specs` pass. It exists so the fresh-eyes reviewer (and future readers) can see the rewrite as a delta, not as 'a bunch of files moved around.'

## Delta at a glance

- **Files:** 4 rewritten, 1 added, 0 removed/deprecated
- **Conceptual changes:** "Delta at a glance" disambiguated into *canonical contract* (design-delta-ledger.md) vs *render slot* (cohesion-review.md) via annotation; cohesion-review.md issue-shape examples replaced from three-field (Risk/Substrate artifact/Suggested repair) to canonical six-field (Severity/Category/Why it matters/Evidence/Recommended fix/Substrate artifact)
- **Named invariants:** none added — convention pin 8 added to `PLUGIN_ROOT_PATHS.md` canonical list (substrate bookkeeping for an existing validator check, not a new invariant)
- **Behavior matrices:** none
- **Gotchas:** none
- **Semantic linters:** `validate_plugin.sh` check 13h tightened (added malformed-filename counter + warn-level signal when a delta-ledger filename lacks the `YYYY-MM-DD` prefix per `docs/substrate/designs/substrate-layout.md` §Naming)
- **Tests proposed:** none
- **Deferred (out of scope this pass):** the across-verdicts render rule's promotion to a multi-consumer canonical home (still single-surface in `validate-rewrite`; substrate-noted in the prior rewrite's ledger as pass-2 New-I2 / pass-3 I2 with named promotion target); the cutoff-date pattern's promotion to `docs/substrate/designs/skill-conventions.md` §"Cutoff-date checks" (still single-occurrence in `validate_plugin.sh`); the delta-at-a-glance preamble convention's promotion to a named invariant per `style-guide-rot.md` criteria

## Files rewritten

- `references/templates/cohesion-review.md`
  - **Before:** §"Delta at a glance" carried a one-line cite to design-delta-ledger.md (post repair pass 2 of the previous rewrite). §"Blocking issues" and §"Important issues" example findings (B1/I1) used a three-field shape: **Risk** / **Substrate artifact to repair** / **Suggested repair**. The lead-in to §"Blocking issues" did not name the canonical six-field shape.
  - **After:** §"Delta at a glance" still carries a one-line cite, now annotated as a *render slot* (the section in a validation review document where the ledger's preamble appears verbatim) explicitly distinguished from the *canonical contract* (which lives in `design-delta-ledger.md` §"Delta at a glance"). §"Blocking issues" and §"Important issues" example findings now use the canonical six-field shape: **Severity** / **Category** / **Why it matters** / **Evidence** / **Recommended fix** / **Substrate artifact to add or update**. The §"Blocking issues" lead-in cites `docs/substrate/designs/reviewer-agent-template.md` §"Output format conventions" as the canonical home of the six-field shape, naming the synthesizer-consumers (`validate-rewrite`, `cohesive:review-codebase`, `cohesive:review-diff`) that depend on uniform shape across reviewer agents.
  - **Reason:** `cohesive:review-diff` Finding 1 (High, Concept) flagged the issue-shape contradiction between the agent's six-field rubric (`agents/spec-cohesion-reviewer.md` lines 82, 93–104) and the template's three-field examples. The template directs reviewers to "Use the template at `references/templates/cohesion-review.md`" (agent line 87) — a literal reading of the three-field examples produces output that violates the rubric. Three live `spec-cohesion-reviewer` dispatches in the prior rewrite produced six-field output despite this contradiction (rubric overrode template by incumbency), but that's calibration-by-incumbency, not substrate. Pass-3 of the prior rewrite deferred this; the post-merge `review-diff` escalated it from Medium to High, citing the new `## Delta at a glance` slot's adjacency to the non-conformant B1 example as the load-bearing trigger. Finding 2 (Medium, Concept) flagged the heading reuse between the contract surface and the render-slot surface. Both are now closed by annotation + canonical-shape adoption in this single file.

- `references/templates/design-delta-ledger.md`
  - **Before:** §"Delta at a glance" framed itself as "the canonical home of the preamble's category list, authoring rules, and consumer rendering rules" without explicitly distinguishing its role from the cohesion-review.md surface that quotes the preamble verbatim. §"Authoring rules" did not cross-reference `cohesive:implement-cohesively` Phase 1's coverage table, even though the 8-category list is the substrate-shape input to that table per `IMPLEMENTATION_PLAN_COVERS_DELTA`.
  - **After:** §"Delta at a glance" framed itself as the **canonical contract** (using bold) and explicitly names cohesion-review.md §"Delta at a glance" as the *render slot* — the contract/instance distinction is now visible from the contract side. §"Authoring rules" carries a one-line cross-reference noting that the 8-category list is the substrate-shape input to `cohesive:implement-cohesively` Phase 1's coverage table per `IMPLEMENTATION_PLAN_COVERS_DELTA`, so a future contributor renaming or adding a category sees the coupled change before merging.
  - **Reason:** `cohesive:review-diff` Finding 2 (Medium, Concept) flagged the heading reuse — same heading carries different load-bearing roles across two documents. The reviewer recommended either renaming one heading or annotating both. Annotation is the lower-cost choice (renaming a widely-cited heading would ripple through many citations and the validator grep target); the contract-vs-slot distinction lands cleanly on both sides without breaking citations. Finding 4 (Low, Invariant cross-reference) flagged the invisible coupling between this template's category list and `IMPLEMENTATION_PLAN_COVERS_DELTA`'s Phase 1 coverage shape — a future renamer would not see the dependency without a cross-reference, and the prior rewrite's ledger §"What this rewrite did not do" had named the relationship but not anchored it. The cross-reference closes that gap.

- `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md`
  - **Before:** §"Convention pins enforced alongside this invariant (canonical list)" enumerated 7 convention pins (1–7), claiming to be "the canonical enumeration — AGENTS.md and `docs/substrate/designs/skill-conventions.md` link here rather than restating, so the three docs cannot drift." The closing sentence "None of the convention pins above (1–4, 6, 7) are named invariants — they remain conventions" enumerated pins 1–7 by number. Validator check 13h existed in `validate_plugin.sh` (added by the just-merged delta-at-a-glance rewrite) but had no companion entry in the canonical list.
  - **After:** Added pin 8 — Delta-at-a-glance preamble check (validator check 13h) — naming the cutoff-date semantics, citing `references/templates/design-delta-ledger.md` §"Delta at a glance" as the canonical contract, citing `agents/spec-cohesion-reviewer.md` "What you check" item 11 as the accuracy half of the two-fence model, and naming both the convention-with-grep status and the natural promotion target (`docs/substrate/designs/skill-conventions.md` §"Cutoff-date checks") if a second cutoff-scoped check arrives. Closing sentence updated to include 8 in the enumeration.
  - **Reason:** `cohesive:review-diff` Finding 3 (Low, Spec drift) — the canonical list had drifted from the validator script after check 13h shipped without a companion pin entry. The rule "the three docs cannot drift" was violated the moment 13h merged; this closes the drift.

- `scripts/validate_plugin.sh`
  - **Before:** Check 13h iterated `docs/history/delta-ledgers/*.md`, parsed each filename's first 10 characters as a `YYYY-MM-DD` date, and silently `continue`d past any file whose prefix didn't match the date regex. The `ok` line reported `preamble_check_count` (post-cutoff ledgers checked) and `preamble_skipped_count` (pre-cutoff grandfathered), but a malformed filename appeared in neither — the file was silently excluded from both counts and from the preamble check.
  - **After:** Check 13h iterates the same files but increments a third counter `preamble_malformed_count` on each filename that lacks the `YYYY-MM-DD` prefix, emits a `warn` naming the file and citing `docs/substrate/designs/substrate-layout.md` §Naming, and surfaces the malformed count in the `ok` line. The fail behavior on missing preambles is unchanged.
  - **Reason:** `cohesive:review-diff` Finding 5 (Low, Test guarantee) — the silent skip created a test-guarantee gap: a malformed-named ledger would pass the validator without participating in the check, and no signal would surface. `substrate-layout.md` §Naming pins the YYYY-MM-DD-`<slug>`.md filename shape as a substrate convention; a malformed filename is itself a substrate violation that should surface. Warn-level (rather than fail-level) is appropriate because the check's primary contract is preamble presence; filename shape is an adjacent concern that deserves visibility but not blocking status until or unless a separate check ships for filename validation.

## Files added

- `docs/history/delta-ledgers/2026-05-05-cohesion-review-cleanup.md` — this ledger.

## Files removed or deprecated

None.

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| `## Delta at a glance` (heading shared between canonical contract and render slot, with load-bearing role implicit) | `## Delta at a glance` annotated explicitly: *canonical contract* in `design-delta-ledger.md`; *render slot* in `cohesion-review.md` | Tightened |
| Three-field issue shape (Risk / Substrate artifact / Suggested repair) in `cohesion-review.md` B1/I1 examples | Six-field issue shape (Severity / Category / Why it matters / Evidence / Recommended fix / Substrate artifact to add or update) per `docs/substrate/designs/reviewer-agent-template.md` §"Output format conventions" | Replaced |

## New or updated substrate

### Specs
- `references/templates/cohesion-review.md` — issue-shape examples adopt canonical six-field shape; §"Delta at a glance" annotated as render slot
- `references/templates/design-delta-ledger.md` — §"Delta at a glance" annotated as canonical contract; §"Authoring rules" cross-references `IMPLEMENTATION_PLAN_COVERS_DELTA` Phase 1 coverage shape
- `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md` — convention pin 8 added to canonical list naming validator check 13h

### Behavior matrices
None added or modified.

### Named invariants
No new named invariants. Convention pin 8 added to `PLUGIN_ROOT_PATHS.md` canonical list (the validator check it pins shipped in the prior rewrite; this pass closes the canonical-list drift).

### Gotchas
None added.

### Semantic linter specs
- `validate_plugin.sh` check 13h tightened — added `preamble_malformed_count` counter + warn-level signal on filename-shape violation; surfaced in `ok` line.

### Tests / checks proposed (not yet implemented)
None.

## What this rewrite *did not* do

- Did not rename the `## Delta at a glance` heading in either `design-delta-ledger.md` or `cohesion-review.md`. The heading reuse is now disambiguated by annotation rather than by rename. Heading rename would ripple through every cite of the canonical reference plus the validator grep target plus the existing worked-example ledger; annotation closes the same blur with an order of magnitude less change. Naming churn deferred to a future rewrite if annotation proves insufficient.
- Did not promote the cutoff-date pattern to `docs/substrate/designs/skill-conventions.md` §"Cutoff-date checks". Still single-occurrence in `validate_plugin.sh`; the prior rewrite's substrate note already names the promotion target and trigger condition, and this rewrite's pin 8 entry in PLUGIN_ROOT_PATHS.md cites the same target — the substrate-bookkeeping is sufficient until a second cutoff-scoped check arrives.
- Did not promote the across-verdicts render rule to a multi-consumer canonical home. Still single-surface in `validate-rewrite`'s Output format prose; pass-2 New-I2 / pass-3 I2 / `review-diff` Finding 2-adjacent. Substrate note in the prior rewrite's ledger remains the active record; promotion happens when a second consumer arrives.
- Did not promote the delta-at-a-glance preamble convention to a named invariant. Still convention-with-grep status; promotion criteria per `style-guide-rot.md` (two release cycles + caught regression + captured-not-authored worked transcript) unmet.
- Did not add the optional phase-derivation matrix row for the preamble. Deferred per the prior rewrite; the cross-reference added to design-delta-ledger.md §"Authoring rules" partially serves the same coupling-visibility function.
- Did not author a worked-example transcript for `spec-cohesion-reviewer` item 11's divergence-detection calibration (pass-1 review I2 deferral). Still waiting on a real divergence in session.
- Did not modify `agents/spec-cohesion-reviewer.md`, `skills/rewrite-specs/SKILL.md`, `skills/validate-rewrite/SKILL.md`, or `skills/cohesively/SKILL.md`. The cited rules in those files already point at the canonical contract; this rewrite's clarification on the contract side is read transitively via existing citations.
- Did not write code, tests, or CI workflow changes beyond `validate_plugin.sh` check 13h tightening.

## Remaining ambiguity

- The annotation approach for "Delta at a glance" disambiguation (contract vs. slot) relies on a future contributor reading both annotated documents. If a contributor only reads cohesion-review.md (the render slot) without following the cite to design-delta-ledger.md (the canonical contract), the contract-vs-slot distinction may not register. A future tightening could rename one heading; this rewrite chose the lower-cost annotation route. Pass-1 review I1 narrowed this further by mirroring the bolded **canonical contract** term symmetrically across both surfaces, but the underlying need to read both pages persists. The blur is reduced, not eliminated.
- The malformed-filename warn in check 13h is warn-level, not fail-level. A malformed-named ledger passes the validator with one warning per offender; merge is not blocked. If a malformed filename is observed in practice, future tightening could promote to fail-level once `substrate-layout.md` §Naming has a dedicated filename-validation check.
- The IMPLEMENTATION_PLAN_COVERS_DELTA cross-reference in `design-delta-ledger.md` §"Authoring rules" is a one-line note. It surfaces the coupling but does not enforce it — a future rename of a preamble category that fails to update Phase 1's coverage shape produces silent drift between the two surfaces. The note is the convention; structural enforcement (a check that compares the category list to Phase 1's documented shape) is deferred until a real rename happens and exposes the pattern.

## Repair pass 1

Triggered by the pass-1 validate-rewrite review (Approved verdict with two Low Important issues; persisted at `docs/history/reviews/2026-05-05-cohesion-review-cleanup-rewrite-validation.md`). Both findings were new from this rewrite (not pre-existing) and had ~1-line fixes. Repair scope:

- **Pass-1 I1 (Spec drift, Low) — addressed.** The render-slot label asymmetry between `references/templates/cohesion-review.md` §"Delta at a glance" and `references/templates/design-delta-ledger.md` §"Delta at a glance" is closed by mirroring the bolded **canonical contract** term symmetrically. The slot side now uses the same bolded form the contract side uses, with a one-clause note observing the mirroring so the relationship reads from either entry point. The underlying annotation-vs-rename trade-off is still substrate-noted in §"Remaining ambiguity" above.
- **Pass-1 I2 (Enforcement, Low) — addressed.** Pin 8 in `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md` now names the warn-level malformed-filename signal as an adjacent (not load-bearing) surface, citing `substrate-layout.md` §Naming as the source-of-truth and naming the promotion path (warn → fail when a dedicated filename-validation check ships under `substrate-layout.md` §Naming enforcement). The two-fence model (presence + accuracy) framing is preserved; the malformed-filename signal is described as adjacent rather than a third fence.

Files modified in repair pass 1: `references/templates/cohesion-review.md` (one-line mirror addition); `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md` (pin 8 expanded to name warn-level signal). No body sections of this ledger required updates beyond the §"Remaining ambiguity" annotation noting the I1 narrowing — file counts in §"Delta at a glance" are unchanged because repair pass 1 did not add, remove, or rename files.

## Ready for fresh-eyes review?

**Yes** — repair pass 1 closed both pass-1 Important findings (I1 + I2). Five `review-diff` findings closed structurally; one (heading rename) closed by annotation; remaining ambiguities scoped with promotion targets and tightened by pass-1 I1.

## How to read this ledger

The intent is that a reviewer can:
1. Read the "Approved direction" line and know the destination.
2. Skim "Delta at a glance" and know the shape of the change in 8–15 lines.
3. Skim "Conceptual changes" and know what's *different* in detail.
4. Read "Files rewritten" with before/after snippets to verify each rewrite.
5. Use "Remaining ambiguity" as the focused review punch list.

The "Delta at a glance" preamble is also the surface `validate-rewrite` quotes verbatim into its rendered review, so the validation-review reader sees the same scannable summary at decision time. Keep it consistent with the body sections — the `spec-cohesion-reviewer` agent flags divergence as a Blocking Issue.
