# Rewrite Validation Review — run-scaffolding cleanup (PR artifact lifecycle)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-07
**Subject:** 5 rewritten files + 1 new gotcha + delta ledger at `docs/history/delta-ledgers/2026-05-07-run-scaffolding-cleanup.md`

**Verdict:** Approved

## Architectural reflection

Now that the lifecycle axis is locked, the architecture's overall shape is: **`docs/history/` carries one bucket of dated artifacts for the chain output, but the bucket has two persistence destinations** — durable artifacts ride the merge into main; ephemeral artifacts live and die on the implementation branch. The audience seam (substrate-shape vs decision-shape rendering) and the lifecycle axis (durable vs ephemeral persistence) are orthogonal and structurally distinguished — a clean two-dimensional classification rather than a layered one.

- **Easier downstream:** Cohesive-driven PRs become legibly substantive. Main's `docs/history/` directory carries only decisions (brainstorms, delta ledgers, validation reviews, final substrate reviews), not process scaffolding. Future contributors reading `git log` in main aren't drowning in 56% process docs (the pinky #175 baseline). The cleanup commit's verbatim removed-paths list is the explicit breadcrumb back from main to branch history when forensic recovery is needed.
- **Harder downstream:** A forensic reader on main now needs to know the *branch* is the audit surface for plans, not main. Without reading `substrate-layout.md` §"Cleanup at handoff" or `plans-as-run-scaffolding.md`, a contributor running `git log -p docs/history/plans/<slug>-phase-*.md` in main sees nothing and may conclude plans were never written. The breadcrumb is structural but requires the contributor to read the cleanup commit's body. New ephemeral-artifact categories require lifecycle classification *before* shipping (per `artifact-placement.md` §"Lifecycle rules"); a contributor who skips that step produces silent bloat.
- **Load-bearing on memory:** Two convention-with-reviewer-judgment surfaces lack automated enforcement: (a) the cleanup-commit-without-verbatim-list violation depends on `cohesive:review-codebase` structure-reviewer attention; (b) "Phase 3.5 fired on the wrong verdict" depends on the same reviewer attention. The deferred CI grep target shifts focus to delta-entry stable IDs, which closes the durable-citation half but not the cleanup-commit half. v0.1 accepts this; promotion is the existing-pattern path.

## Executive judgment

The rewrite makes the lifecycle axis structurally true across five surfaces — convention, matrix, invariant, SKILL body, handoff edge — and the durable-vs-runtime citation distinction propagates consistently. A future contributor reading these specs alone could reproduce the strip-at-handoff behavior without consulting the original architect. The single biggest gap is non-blocking: the cross-session resumption case (Phase 1+2 in one session, Phase 3+3.5 later) is implicit rather than named — the substrate says plans persist "during the run" but doesn't define run-boundary against Claude session boundary. Approved with two Medium findings worth closing in the same worktree.

## Delta at a glance

This rewrite is **Mixed**. Design-layer changes: substrate-layout convention adds Lifecycle axis; artifact-placement matrix adds Lifecycle by artifact category section; IMPLEMENTATION_PLAN_COVERS_DELTA adds Rule #6 and tightens citation distinction; handoffs.md (implement-cohesively → finishing-a-development-branch) names Phase 3.5 cleanup as preceding the handoff; new gotcha plans-as-run-scaffolding.md. Implementation changes: `implement-cohesively/SKILL.md` adds Phase 3.5, Hard constraint #6, and trailer Branch-state cleanup-SHA slot.

- **Files:** 5 rewritten, 2 added, 0 removed/deprecated
- **Conceptual changes:** Lifecycle axis (durable vs ephemeral) introduced for `docs/history/` artifacts; durable audit citation (delta-entry stable IDs) distinguished from runtime audit citation (plan paths)
- **Named invariants:** `IMPLEMENTATION_PLAN_COVERS_DELTA` (strengthened — Rule #6 added; §"Runtime paths", §"Enforcement", §"Review checklist" extended for Phase 3.5 cleanup gating) — no other invariants added or removed
- **Behavior matrices:** `artifact-placement.md` (cells added — new §"Lifecycle by artifact category" classifying all 10 artifact categories) — no new matrix files
- **Gotchas:** `plans-as-run-scaffolding.md` (added) — none retired
- **Semantic linters:** none added; deferred CI grep target shifts from "plan path" form to "delta-entry stable ID" form per the durable-citation distinction
- **Tests proposed:** none — enforcement is skill-body acceptance criteria + reviewer judgment; CI grep target is deferred per existing invariant convention
- **Deferred:** per-phase delta-coverage verdict file persistence; CI grep promotion; existing-repo migration tooling

## Important issues

### I1. Cross-session run boundary is unnamed

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** Phase 3.5 gating presumes "the run" is a coherent unit, but a Cohesive implementation pass can span multiple Claude sessions (user runs Phase 1+2 today, returns tomorrow for Phase 3+3.5). The substrate repeatedly says "plans persist *during the run*" (`IMPLEMENTATION_PLAN_COVERS_DELTA.md:10,51,83`; `substrate-layout.md:99`) without defining "run." A future contributor reading these specs cannot tell whether closing the Claude session terminates the run (and triggers cleanup eligibility on Aborted-via-disconnect) or whether re-entering on `design/<slug>` resumes it. The brainstorm acknowledged this in §"Future pressure" but the rewrite did not import the answer.
- **Evidence:** `IMPLEMENTATION_PLAN_COVERS_DELTA.md:10` ("during the run"); `substrate-layout.md:99-101`; `implement-cohesively/SKILL.md:128` ("ephemeral artifacts remain on the branch for the next attempt"). The phrase "next attempt" implies multi-session resumption is supported but the run-boundary semantics are absent.
- **Recommended fix:** Add one paragraph to `IMPLEMENTATION_PLAN_COVERS_DELTA.md` §"Runtime paths" or `substrate-layout.md` §"Cleanup at handoff" defining run-boundary as Phase 1 inception → Phase 3 verdict, independent of Claude session boundary. Name multi-session resumption explicitly: "plans persist on the branch across session boundaries; the run terminates on Phase 3 verdict, not on session disconnect."
- **Substrate artifact to add or update:** spec (§"Cleanup at handoff" extension) or named invariant §"Runtime paths" extension

### I2. Speculative row in normative matrix

- **Severity:** Medium
- **Category:** Future-fit
- **Why it matters:** `artifact-placement.md:65` introduces a "Per-phase delta-coverage verdict" row in §"Lifecycle by artifact category" with cleanup target `docs/history/reviews/<YYYY-MM-DD>-<slug>-phase-*-coverage.md` — but the row's "Producing skill" parenthetical says "currently chat-only." The matrix is a normative cell-by-cell contract; an artifact that doesn't yet exist as a persisted file is non-normative speculation in a normative section. The rewrite-specs Hard constraint #5 (end-state language only) is at risk: the row reads as if the file exists, then qualifies it as future. Same row shape repeats in `implement-cohesively/SKILL.md:134` Phase 3.5 enumeration.
- **Evidence:** `artifact-placement.md:65` ("`delta-coverage-reviewer` agent (currently chat-only)" + "Lifecycle: **Ephemeral** (when promoted to file persistence)"); `implement-cohesively/SKILL.md:134` ("if persisted (currently chat-only; included here for forward compatibility…)").
- **Recommended fix:** Either (a) split the row into a §"Future ephemeral categories" subsection clearly marked non-normative, or (b) keep it in the main table but add a `Status` column with values `Active` / `Pre-classified (not yet persisted)` so the speculative row is visually distinguishable from active rows, or (c) drop the row entirely (the matrix can be extended in the same PR that promotes verdicts to file persistence). Option (c) is the cleanest — least speculative content in normative spec.
- **Substrate artifact to add or update:** behavior matrix (column addition, section split, or row removal)

## Substrate gaps

- **Squash-merge / force-push forensic edge case** — the brainstorm (§"Initial risks") and ledger (§"Remaining ambiguity") both flag the squash-merge interaction as benign, but no substrate artifact records that judgment for future readers. If a contributor squashes a Cohesive branch and later finds the cleanup-commit breadcrumb is gone, they have no spec to consult. A one-paragraph note in the new gotcha's §"Notes for future contributors" or a `### Forensic recovery edge cases` subsection in `substrate-layout.md` §"Cleanup at handoff" would close it.
- **Existing-repo migration** — repos with plans already in main get a brainstorm acknowledgment but no substrate path. Acceptable for v0.1 per the ledger's explicit out-of-scope, but worth a one-line pointer in `plans-as-run-scaffolding.md` §"Notes for future contributors".

## Locality concerns

The rewrite is structurally local: cleanup logic lives in `implement-cohesively` Phase 3.5, classification lives in `artifact-placement.md`, the gotcha pedagogy is its own file. No premature centralization. The lifecycle axis is correctly orthogonalized from the audience seam — `substrate-layout.md:42` and `plans-as-run-scaffolding.md:70` both name the orthogonality at the conceptual level (render surfaces vs persistence surfaces); the assertion holds because they govern different decisions (chat vs file rendering ≠ branch vs main persistence).

## Future-fit concerns

The "Per-phase delta-coverage verdict (when promoted)" pre-classification is the right move for forward compatibility — see I2 for the rendering concern, not the substance.

## Enforcement concerns

`IMPLEMENTATION_PLAN_COVERS_DELTA` Rule #6 is enforced by skill-body acceptance criteria + reviewer judgment + (deferred) CI grep — same enforcement pattern as Rules #1-5, consistent with the invariant's existing convention. The cleanup-commit-without-verbatim-list violation has no automated detector; it depends on `cohesive:review-codebase` structure-reviewer attention. This is consistent with v0.1's enforcement philosophy and explicitly deferred per the ledger.

## Behavior knowable outside implementation?

Yes. Phase 3.5's operational steps are enumerated; per-verdict behavior is named on three surfaces (Hard constraint #6, Rule #6, handoffs.md edge); the cleanup commit format is shown verbatim in three docs (SKILL.md, substrate-layout.md, gotcha). A future contributor implementing a new ephemeral artifact category has the matrix row + lifecycle rule + gotcha to consult.

## Vague language to tighten

None in normative sections. The "currently chat-only" phrasing in I2 is the closest, and that's a future-fit issue rather than a vague-language one.

## Lens 12-14 findings (Mixed-classification)

**Lens 12 (substrate-first compliance):** The design-layer changes (handoffs.md edge contract) are touched. `handoffs.md:201-213` updates the chain-exit edge with Phase 3.5 gating, the cleanup-commit SHA artifact, and three failure modes. Compliant.

**Lens 13 (design-implementation agreement):** SKILL.md Hard constraint #6 (cleanup gated on Implemented), §"What this skill produces" (cleanup commit listed), and Phase 3.5 body all agree with handoffs.md's edge contract. Verdict vocabulary (`Implemented` / `Phase Drift` / `Substrate Drift` / `Aborted`) matches between SKILL.md, handoffs.md, and the chain-exit terminal verdicts. Compliant.

**Lens 14 (handoff contract consistency):** The Implemented gate appears identically as the cleanup precondition in three sites — `implement-cohesively/SKILL.md` Hard constraint #6 + Phase 3.5; `IMPLEMENTATION_PLAN_COVERS_DELTA` Rule #6; `handoffs.md` §"implement-cohesively → finishing-a-development-branch (Implemented)". The cleanup-commit-as-artifact crossing appears in the trailer's Branch state slot, the handoff edge's Artifact crossing, and the gotcha's Tests/checks section. Consistent across all three sites.

## Recommended repairs (ranked)

1. **Name the run boundary** (I1) — one paragraph in `IMPLEMENTATION_PLAN_COVERS_DELTA.md` §"Runtime paths" defining run = Phase 1 → Phase 3 verdict, independent of Claude session. Highest leverage because cross-session resumption is a real workflow the substrate currently leaves undefined.
2. **Drop or mark the speculative matrix row** (I2) — preferred fix is (c) drop the row entirely (the matrix can be extended in the same PR that promotes verdicts to file persistence); fallback is (b) add a `Status` column with `Active` / `Pre-classified` values. Either closes the rewrite-specs end-state-language Hard constraint.
3. **Note squash-merge / force-push forensic edge** — one paragraph in `plans-as-run-scaffolding.md` §"Notes for future contributors" or `substrate-layout.md` §"Cleanup at handoff" naming the cleanup-commit-survives-merge-commit-but-collapses-on-squash behavior.

## What looked right

- **Durable-vs-runtime citation distinction is the load-bearing tightening.** Splitting `IMPLEMENTATION_PLAN_COVERS_DELTA` Rule #3 into two citation kinds (delta-entry stable ID = durable; plan path = pre-cleanup branch-history pointer) is what makes Phase 3.5 compatible with the invariant's audit-trail promise. The named-concept status earned itself — without the split, "audit citation" would be ambiguous and the cleanup commit would either break the invariant or weaken its enforcement. The same vocabulary propagates verbatim across SKILL.md (acceptance criteria, commit-message template), the gotcha (§"Related invariant"), substrate-layout (§"Cleanup at handoff" body), and the matrix (lifecycle rules). Single canonical home, four citing surfaces — exactly the locality pattern the rubric asks for.
- **Orthogonality assertion at line 42 of substrate-layout.md** is concretely defended (render surfaces vs persistence surfaces, with the worked example of "delta ledger is substrate-shape *and* persists in main vs plan is substrate-shape *and* gets cleaned up before main"). The assertion holds because the two axes govern different decisions; the rewrite doesn't merely claim orthogonality, it shows it.
- **Cleanup-commit-as-breadcrumb pattern** is the right structural choice for forensic recovery. The commit body lists removed paths verbatim, which preserves greppability in main; pre-cleanup branch history retains the file content for `git log --all` recovery. This is more cohesive than the gitignore alternative (which the gotcha explicitly retires with the "citation rot at commit time" argument) and earns its complexity.
- **Phase 3.5 gating on Implemented verdict only** correctly preserves the load-bearing-for-next-attempt property of ephemeral artifacts on Phase Drift / Substrate Drift / Aborted verdicts. This was a non-obvious design choice — the simpler design (always strip on Step 4) would have produced the resume-can't-recover-prior-plans failure the brainstorm flagged. The gating is named in three places (Hard constraint #6, Rule #6, handoffs.md failure mode (c)) so the gating rule is reviewer-verifiable rather than depending on memory.
