# Rewrite Validation Review — Skill pack flow tightening

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-05
**Subject:** 2026-05-05 skill-pack-flow-tightening rewrite — new `using-cohesive` skill, Skill-tool dispatch convention, restructured "Adding a new skill" sequence, validator Check 13i, scattered drift fixes. Ledger at `${CLAUDE_PLUGIN_ROOT}/docs/history/delta-ledgers/2026-05-05-skill-pack-flow-tightening.md`.

**Verdict:** Issues Found

## Executive judgment

The rewrite is structurally sound and substantively closes the targeted findings — `using-cohesive` is well-shaped at both design and implementation layers, the Skill-tool dispatch convention reads as a proper complement to (not a duplicate of) the Task-tool contract, and the verdict-drift fix on `audit-substrate` is now consistent across all three surfaces (handoffs.md, skills.md at-a-glance row, skills.md per-skill Outputs). One Blocking issue: the ledger's `## Delta at a glance` preamble claims **14 files rewritten**, but the body's `## Files rewritten` section enumerates **12**, and the closing §"How to read this ledger" §4 also says "12 files rewritten." The preamble is the surface `validate-rewrite` quotes verbatim into its review at decision time — a count mismatch propagates to every reader of the validation review.

## Delta at a glance

> This rewrite is **Mixed**. Design-layer changes: new skill `using-cohesive` (per-skill section in architecture/skills.md, handoff section in handoffs.md, exemption in skill-shape.md, row in skill-section-presence.md); restructured "Adding a new skill" sequence (3-step → 5-step) in architecture/skills.md. Implementation changes: spec drift fixes, new convention doc, validator extension, README/ARCHITECTURE updates, mirror-annotation citations.
>
> - **Files:** 14 rewritten, 3 added, 0 removed/deprecated
> - **Conceptual changes:** session-start orientation as a 5th transition shape (handoffs.md); Skill-tool dispatch as a distinct contract from Task-tool dispatch (new conventions doc); validator-array updates as Step 5 of the "Adding a new skill" sequence (was implicit) — or `none` not applicable
> - **Named invariants:** none added, none strengthened, none weakened, none removed (`DISPATCH_CONTRACT_MIRROR` and `HANDOFF_VOCABULARY_PARITY` remain candidate invariants — promotion deferred per `style-guide-rot.md` criteria)
> - **Behavior matrices:** `skill-section-presence` (cells added: rows for `implement-cohesively` (pre-existing drift fix) and `using-cohesive` (new); intro skill count 8 → 10; new exemption entry); `router` (mirror-annotation citation updated to name Check 13i) — none added, none retired
> - **Gotchas:** `discovery-vs-superpowers` (added §"Correct pattern" item 3 naming `using-cohesive` as structural mitigation; renumbered subsequent items 4 and 5); `no-implementation-handoff` (relabeled three "Lint check (deferred V1)" entries as shipped Checks 13e/13f/13g) — none added, none retired
> - **Semantic linters:** `validate_plugin.sh` Check 13i (`DISPATCH_CONTRACT_MIRROR` mirror grep) — added
> - **Tests proposed:** `none` (the deferred manual scenario tests in `discovery-vs-superpowers.md` and `no-implementation-handoff.md` remain deferred to V1 per the review's roadmap; encoding scenario tests is item 13 in the review's "Then: strengthen enforcement" tier and is out of scope for this rewrite)
> - **Deferred (out of scope this pass):** review findings 6–11, 13–16; review finding 7 gated on harness-schema verification; named-invariant promotion gated on grep-wording stability for one release cycle

## Blocking issues

### B1. Preamble file-count diverges from body

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** The preamble is the surface the dispatching `validate-rewrite` skill renders verbatim into the validation review at decision time. The reader sees "14 files rewritten" in the executive summary while the body lists 12 — contradicting both the body's `## Files rewritten` section and the closing §"How to read this ledger" item 4 ("12 files rewritten, 3 added"). Per the canonical contract at `references/templates/design-delta-ledger.md` §"Delta at a glance" consumer rendering rules, a preamble inconsistent with the body is a Blocking Issue. A future contributor running coverage against the ledger (`cohesive:implement-cohesively` Phase 1 maps preamble entries to phases) would either over- or under-count files.
- **Evidence:** `docs/history/delta-ledgers/2026-05-05-skill-pack-flow-tightening.md:13` ("14 rewritten, 3 added, 0 removed/deprecated"); body §"Files rewritten" enumerates 12 entries (handoffs.md, skills.md, skill-shape.md, skill-section-presence.md, router.md, cohesively/SKILL.md, dispatch-protocol.md, discovery-vs-superpowers.md, no-implementation-handoff.md, validate_plugin.sh, README.md, ARCHITECTURE.md); §"How to read this ledger" item 4 ("12 files rewritten, 3 added").
- **Recommended fix:** Audit the body and pick one truth. If 12 is correct, change the preamble to "12 rewritten, 3 added." If two additional files were rewritten (candidates: a fresh-eyes-review.md update, or a substrate-layout.md update missing from the body), add them to the body's §"Files rewritten" with before/after entries.
- **Substrate artifact to add or update:** The ledger itself; the validator's Check 13h preamble grep does not assert preamble↔body consistency, so this surface relies on the reviewer's lens 11 — promote to Check 13j candidate if the regression recurs.

## Important issues

### I1. handoffs.md "Adding a new chain skill" deference is now nuanced

- **Severity:** Medium
- **Category:** Domain model
- **Why it matters:** handoffs.md §"Adding a new chain skill or re-entry edge" defers to skills.md §"Adding a new skill" as the canonical sequence, but skills.md Step 2 instructs "Add the inbound and outbound handoff contracts. For non-chain skills (router, session-start orientation), add a brief contract section naming the transition shape (per §'The five transition shapes')." The five-shape vocabulary is now the load-bearing taxonomy a future contributor consults when adding a non-chain skill. handoffs.md's deference does not point at the five-shape section; a future author of a sixth-shape skill (or a contributor adding a non-chain diagnostic) would have to derive the rule from skills.md Step 2 alone.
- **Evidence:** `docs/substrate/architecture/handoffs.md` §"Adding a new chain skill or re-entry edge" deference paragraph; `docs/substrate/architecture/skills.md` §"Adding a new skill" Step 2.
- **Recommended fix:** In handoffs.md §"Adding a new chain skill or re-entry edge" deference paragraph, add one sentence: "For non-chain skills, follow skills.md Step 2's reference to §'The five transition shapes' here for the transition vocabulary."
- **Substrate artifact to add or update:** `docs/substrate/architecture/handoffs.md`.

### I2. using-cohesive ownership claim mildly diverges from SKILL.md

- **Severity:** Low
- **Category:** Spec drift
- **Why it matters:** skills.md §"using-cohesive" Owns includes "Documenting the seam between Cohesive and Superpowers as the structural mitigation for...discovery-vs-superpowers.md." The SKILL.md body does not claim ownership of documenting the seam — it cites the gotcha as the mitigation surface. The gotcha file itself documents the seam (item 3 names using-cohesive). So the *structural mitigation* is using-cohesive existing, not using-cohesive's documentation. The Owns bullet reads as if the skill body is the canonical home of the seam doc, which is slightly off.
- **Evidence:** `docs/substrate/architecture/skills.md` §"using-cohesive" Owns bullet ("Documenting the seam..."); `skills/using-cohesive/SKILL.md` §"What this skill does" ("The seam this skill closes is the trigger competition documented in [discovery-vs-superpowers.md] §'Correct pattern' item 3.").
- **Recommended fix:** In skills.md §"using-cohesive" Owns, replace "Documenting the seam..." with "Being the structural mitigation for the trigger competition documented in `discovery-vs-superpowers.md`." This matches the gotcha's framing.
- **Substrate artifact to add or update:** `docs/substrate/architecture/skills.md`.

### I3. "Adding a new skill" Step 5 names six arrays inline; drift-watcher delegated to remaining-ambiguity

- **Severity:** Low
- **Category:** Enforcement
- **Why it matters:** skills.md Step 5 enumerates six validator arrays inline ("`expected_skills` always; `discovery_prereq_subskills`, `path_prereq_subskills`, `persisting_skills`, `verdict_led_skills`, `voice_imperative_skills`"). The ledger's §"Remaining ambiguity" item 3 acknowledges this list will drift if the validator changes. Concrete and bounded today; predictable drift surface tomorrow. Not a blocker — the deferred remediation is appropriate.
- **Evidence:** `docs/substrate/architecture/skills.md` §"Adding a new skill" Step 5; ledger §"Remaining ambiguity" item 3.
- **Recommended fix:** No change required this pass; promote to a named-invariant candidate (`SKILL_ARRAY_PARITY`) or a new validator check on the next pass that touches `validate_plugin.sh` array definitions. Revisit if the array list changes.
- **Substrate artifact to add or update:** None this pass.

## Substrate gaps

- The preamble→body consistency check is reviewer-judged (lens 11) but not mechanically enforced. Check 13h validates preamble *presence*; promotion to a preamble-vs-body file-count grep would have caught B1 mechanically. Consider for the next validator-extension pass.

## Locality concerns

The new `using-cohesive` skill maintains good locality. Its responsibilities (orientation only) are tight; its downstream is exclusively `cohesively` (no chain skill or diagnostic invoked directly); the new convention doc `skill-tool-dispatch.md` introduces no shared abstraction with `dispatch-protocol.md` beyond cross-references. The five-shape transition vocabulary in handoffs.md replaces an inconsistent three-vs-four-shape mention; locality of the bootstrap seam is now a named transition shape rather than an exception buried in deference.

## Future-fit concerns

The remaining-ambiguity §3 drift watcher (validator arrays) is honestly named as future pressure, not smuggled into normative sections. Named-invariant promotions (`DISPATCH_CONTRACT_MIRROR`, `HANDOFF_VOCABULARY_PARITY`) are deferred with stated criteria (one release cycle of clean grep + caught regression + worked transcript) — appropriate per `style-guide-rot.md`. No over-promising.

## Enforcement concerns

- Check 13i (the new `DISPATCH_CONTRACT_MIRROR` grep) is concrete: extracts route names, normalizes ` (V1)` suffixes, asserts set equality. Catches the failure mode prose annotation could not.
- The four-constraint Skill-tool dispatch contract is enforceable in principle: constraint 3 (commit shape) is mechanically auditable via `git log --grep "pass-"`; constraints 1, 2, and 4 are reviewer-judged at dispatch-prompt-authoring time. The doc names this honestly.
- using-cohesive's frontmatter narrowing rule is enforced by Check 9a/9b — same surface as every other skill.

## Behavior knowable outside implementation?

Partially. A contributor reading skills.md, handoffs.md, skill-tool-dispatch.md, and skill-shape.md can reproduce the using-cohesive seam without reading SKILL.md. Step 5 of "Adding a new skill" is now concrete enough that the validator-rejection failure mode (review finding 5) cannot recur for a contributor following the docs. Lens 13 inherited-status drift on using-cohesive: design-doc and SKILL.md agree on Purpose, Inputs, Outputs, ownership at high resolution. The I2 ownership-phrasing nuance is the only divergence — bootstrap drift was predicted and is mild.

## Vague language to tighten

- `skills/using-cohesive/SKILL.md:39` — "Cohesive does NOT apply when..." follows with bulleted examples; the list is non-exhaustive but framed as imperative. Consider tightening to "examples include" or making the criteria predicate-shaped.
- No "TBD" / "TODO" / "we will" found in normative sections.

## Recommended repairs (ranked)

1. **Reconcile the preamble file count** (B1). Either drop two body entries that aren't really rewrites, or add two missing body entries, or correct the preamble to "12 rewritten, 3 added." Validation review readers see this number first.
2. **Tighten handoffs.md "Adding a new chain skill" deference** (I1) to point at skills.md §"Adding a new skill" Step 2's five-shape reference for non-chain skills.
3. **Revise skills.md using-cohesive Owns bullet** (I2) to frame the skill itself (not its documentation) as the structural mitigation.

## What looked right

- The five-shape transition vocabulary in handoffs.md is the right level of abstraction — naming session-start orientation as a peer of chain transition / router dispatch / off-chain re-entry / internal repair loop closes the seam rather than creating an exception. The blockquote, the heading, the new per-handoff section, and the deference paragraph in §"Adding a new chain skill" all reflect the same five-shape model. No drift.
- `skill-tool-dispatch.md` is a clean complement to `dispatch-protocol.md`. The opening paragraph explicitly distinguishes the two contracts; the Skill-tool-vs-Task-tool comparison table makes the choice obvious; the four-constraint contract's worked examples (validate-rewrite repair loop, implement-cohesively phase loop) are concrete. A future contributor authoring an internal loop can find the right doc in one search.
- The `audit-substrate` verdict drift fix is propagated cleanly. handoffs.md §"audit-substrate → rewrite-specs", skills.md at-a-glance row, and per-skill Outputs all say `Substrate gaps`. This is exactly the kind of cross-surface parity `HANDOFF_VOCABULARY_PARITY` would catch if promoted; the rewrite shows the parity holds without it.
- Step 5 of "Adding a new skill" is the kind of operational substrate that turns "the validator immediately rejects" failure mode (review finding 5) into a one-pass mechanical step.

### Recommended next Cohesive skill

**Disposition:** Repair → re-validate
