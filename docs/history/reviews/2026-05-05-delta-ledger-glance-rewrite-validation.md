# Rewrite Validation Review — Delta-at-a-glance preamble convention

**Reviewer:** spec-cohesion-reviewer (fresh-eyes Task subprocess)
**Date:** 2026-05-05
**Subject:** Spec rewrite for Option A (Ledger preamble) on branch `design/delta-ledger-glance`. Files reviewed: `references/templates/design-delta-ledger.md`, `references/templates/cohesion-review.md`, `skills/rewrite-specs/SKILL.md`, `skills/validate-rewrite/SKILL.md`, `agents/spec-cohesion-reviewer.md`, `scripts/validate_plugin.sh`, plus the design delta ledger at `docs/history/delta-ledgers/2026-05-05-delta-ledger-glance.md`.

**Verdict:** Approved

## Executive judgment

A future contributor, given only these specs, can author a delta ledger that satisfies the new convention, dispatch `validate-rewrite`, and receive a review that quotes the preamble verbatim. The convention is small, narrowly scoped, and lands with both fences (presence grep + reviewer judgment) plus author-side discipline (rewrite-specs Process / Acceptance / Anti-patterns). The two-fence model is named and motivated; the cutoff-date grandfathering is justified; the choice to ship as convention-with-grep rather than a named invariant is grounded in `style-guide-rot.md` promotion criteria. The single biggest risk is wording drift between the four surfaces that all spell out the same idea — see I1.

## Delta at a glance

- **Files:** 5 rewritten, 1 added, 0 removed/deprecated
- **Conceptual changes:** none (pure addition of a new convention; no existing concept renamed or replaced)
- **Named invariants:** none — the new convention ships as convention-with-grep, not invariant-promoted, per `style-guide-rot.md` promotion criteria
- **Behavior matrices:** none
- **Gotchas:** none
- **Semantic linters:** `validate_plugin.sh` check 13h (added — preamble-presence grep on delta-ledger files dated on or after the 2026-05-05 cutoff); `spec-cohesion-reviewer` "What you check" item 11 (added — per-review preamble↔body consistency check, surfaces divergence as Blocking Issue)
- **Tests proposed:** none
- **Deferred (out of scope this pass):** optional phase-derivation matrix row marking the preamble as non-phase-generating; optional `preamble-drift-in-ledgers.md` gotcha pre-recording the failure mode; promotion of the convention to a named invariant after the convention has stabilized across two release cycles and a real regression has been caught

## Blocking issues

None.

## Important issues

### I1. Preamble category list is restated four times with no canonical home
- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** The 8-category list (Files / Conceptual changes / Named invariants / Behavior matrices / Gotchas / Semantic linters / Tests proposed / Deferred) appears in `references/templates/design-delta-ledger.md` lines 17–24, `skills/rewrite-specs/SKILL.md` line 186, `agents/spec-cohesion-reviewer.md` line 62, and `skills/validate-rewrite/SKILL.md` line 107 (as prose: "counts of files, named invariants by name + status, behavior matrices, gotchas, semantic linters, tests proposed, deferred items"). A future rewrite that adds or renames a category must update four surfaces; if any drifts, the validator grep still passes (it only checks heading presence), and the reviewer's per-review check has no canonical anchor for what "matches the body" means. This is the same locality failure mode `style-guide-rot.md` documents for the voice imperative.
- **Evidence:** four locations cited above; only the template carries the categories declaratively; the others restate.
- **Recommended fix:** Make `references/templates/design-delta-ledger.md` §"Delta at a glance" the canonical home and have the other three surfaces cite it ("the 8 categories specified in design-delta-ledger.md §Delta at a glance") rather than re-enumerate.
- **Substrate artifact to add or update:** spec (design-delta-ledger.md) — promote it to canonical; tighten the three citing surfaces.

### I2. Reviewer item 11 has no example of what "divergence" looks like
- **Severity:** Medium
- **Category:** Enforcement
- **Why it matters:** Item 11 in `agents/spec-cohesion-reviewer.md` lists three example divergence patterns inline ("preamble claims an invariant the body does not record, omits a file the body rewrites, names a behavior matrix not present…"). Without a worked example transcript, two reviewer instances will calibrate "divergence" differently — one may treat a paraphrased category bullet as divergence; another may not. The accuracy fence depends on reviewer judgment that has no captured calibration anchor.
- **Evidence:** `agents/spec-cohesion-reviewer.md:62`; ledger §"Remaining ambiguity" does not flag this; no transcript referenced.
- **Recommended fix:** Add a short worked-example block to `references/templates/design-delta-ledger.md` showing a preamble-vs-body divergence and the correct Blocking Issue rendering, or defer with an explicit `Deferred` bullet noting the missing calibration transcript.
- **Substrate artifact to add or update:** spec or transcript (worked example under `docs/history/transcripts/`).

### I3. Cutoff-date constant is documented as a one-off pattern
- **Severity:** Low
- **Category:** Future-fit
- **Why it matters:** The ledger §"Remaining ambiguity" already names this: cutoff-date constants in `validate_plugin.sh` are a new pattern with no convention for when to advance them. If a second cutoff-scoped check arrives (likely, given the substrate's append-only history posture), reviewers will have to re-derive the pattern. The acknowledgment is honest, but the substrate doesn't yet name the question — "when does a cutoff move?" — anywhere a future contributor would find it.
- **Evidence:** `scripts/validate_plugin.sh:421–427`; ledger lines 100–101.
- **Recommended fix:** Either (a) leave as-is and trust the ledger §"Remaining ambiguity" to surface it next time, or (b) add a one-paragraph §"Cutoff-date checks" to `docs/substrate/designs/skill-conventions.md` noting the convention.
- **Substrate artifact to add or update:** spec (skill-conventions.md) — optional; deferral is also a defensible choice.

## Substrate gaps

- The two-surface deferred-items overlap (preamble's `Deferred` bullet vs. ledger §"What this rewrite did not do") is flagged in §"Remaining ambiguity" but no decision rule is supplied. Future authors will improvise.

## Locality concerns

The reviewer's new item 11 lives in the agent body, but the canonical shape it checks against lives in `references/templates/design-delta-ledger.md`. The agent must read the template to know what categories to compare. This is acceptable (the agent already reads `cohesion-review.md`), but it tightens the dependency from "agent reads the rubric" to "agent reads the rubric AND the ledger template." The agent's "Inputs you will receive" section should list `references/templates/design-delta-ledger.md` alongside the existing four references. Currently it does not.

## Future-fit concerns

The ledger explicitly defers named-invariant promotion until two release cycles + a caught regression + a captured transcript. This matches `style-guide-rot.md` promotion criteria. Good restraint.

## Enforcement concerns

Two-fence model is correctly named: presence (validator grep) + accuracy (reviewer judgment). The grep at `scripts/validate_plugin.sh:444` checks for the literal `## Delta at a glance` heading; the reviewer's item 11 checks accuracy. Both fences have a single-source-of-truth anchor (`references/templates/design-delta-ledger.md` §"Delta at a glance"), satisfying the substrate's enforcement rubric.

## Vague language to tighten

None found in normative sections. The 8–15-line density target is described as a "guideline" rather than enforced count, which is correct (validator does not count lines); the ledger §"Remaining ambiguity" honestly flags this trade-off rather than hiding it.

## Recommended repairs (ranked)

1. I1 — promote `references/templates/design-delta-ledger.md` §"Delta at a glance" to canonical and have the three citing surfaces cite rather than restate the category list.
2. Locality concern — add `references/templates/design-delta-ledger.md` to the agent's "Inputs you will receive" reference list.
3. I2 — add a worked divergence example or explicitly defer with a substrate-noted gap.

## What looked right

- The two-fence model (presence grep + reviewer accuracy check) is named, motivated, and instantiated in this very rewrite — both fences fire on the new ledger as a worked example.
- The cutoff-date grandfathering is principled (forward-looking; old append-only ledgers stay as authored) and the rationale lands in the ledger rather than only in the script comment.
- The brainstorm's Option A vs. B vs. C deliberation is preserved in the ledger's "Reason" field for `references/templates/design-delta-ledger.md`, so a future reader sees not just the choice but why the alternatives lost.
- The §"What this rewrite did not do" enumerates four non-changes (no invariant promotion, no historical backfill, no `implement-cohesively` modification, no phase-derivation row), giving the reviewer a clean punch list of what to NOT flag as gaps.
- Acceptance criteria in `skills/rewrite-specs/SKILL.md` line 186 specifies the count-or-name shape AND the 8–15-line density target — author-side discipline matches reviewer-side enforcement.
