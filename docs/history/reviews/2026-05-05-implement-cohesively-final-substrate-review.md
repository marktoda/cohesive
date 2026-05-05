# Change Cohesion Review — implement-cohesively branch

> Voice and density: ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md

**Verdict:** Pass with notes

## Main concern

Decision-matrix triplication: the four-row matrix appears verbatim in five substrate surfaces (`validate-rewrite/SKILL.md`, `no-implementation-handoff.md`, `IMPLEMENTATION_PLAN_COVERS_DELTA.md`, validator check 13d, validator check 13f for the bypass string). Any future reword breaks the validator's exact-string fences silently against substrate that still reads sensibly. The substrate is internally consistent today; the concern is forward.

## Synthesis

The diff is substrate-coherent. All 30+ validator structural checks pass; the new invariant `IMPLEMENTATION_PLAN_COVERS_DELTA` is anchored in five places (SKILL Hard constraints, the invariant doc, the reviewer agent, the phase-derivation matrix, and the gotcha pair); the validator pins three new structural fences (13d/13e/13f) that match the gotcha's "Tests/checks that preserve this" list line-for-line; the bypass-acknowledgment string is identical across SKILL, invariant §Known bypass risks, and gotcha §Tests/checks. The composition seam with Superpowers is documented at four levels of tightness with the right level chosen for `implement-cohesively` (no fallback). The two reviewers agree: substrate is preserved; the gaps are tightening opportunities, not spec drift.

## Findings

| # | Severity | Area | Finding | Suggested substrate |
|---|---|---|---|---|
| 1 | High | Centralization / Duplication | Decision-matrix triplication — five surfaces with exact-string equality means a reword breaks 13d/13f silently | New `docs/substrate/matrices/post-validation-options.md` as the single normative source; SKILL/gotcha/invariant link to it; validator 13d greps the matrix doc |
| 2 | Medium | Concept | `IMPLEMENTATION_PLAN_COVERS_DELTA` bundles five distinct rules at one tier — closer to a workflow conformance checklist than a single named invariant | Tighten the invariant to clause 1 (delta-entry-to-phase coverage); demote clauses 2–5 to skill-body acceptance criteria (already present) |
| 3 | Medium | Concept / Locality | Run-local phase numbers vs global delta-entry IDs creates a reviewer pitfall when comparing across runs (e.g., after Phase Drift repair) | Make per-phase plan filenames carry a stable intent-slug instead of a phase number — `phase-rename-old-to-new.md` not `phase-1.md` |
| 4 | Medium | Invariant enforcement | Phase 2c "at most one repair cycle" rule has no structural pin — only in SKILL body; future edit softening it would not trip any reviewer fence | Add to invariant §Review checklist: "Did each phase get at most one repair cycle?"; consider validator grep 13g for the literal phrase |
| 5 | Low | Seam | rewrite-specs (loose, with fallback) vs implement-cohesively (tight, hard error) asymmetry is real and intentional but the structural reason is buried in prose | Add a "When to pick which seam shape" table to `composition-with-superpowers.md` §"The seam" with three rows: loose / tight / recommendation |
| 6 | Low | Concept (matrix granularity) | R015 and R016 collapse into the same dispatch with the same prereq-handling logic — matrix bloat tracking input variants rather than dispatch outputs | Collapse to one R015 with a "Trigger phrase variants" column |
| 7 | Low | Test guarantee | Phase 3 final-review filename schema (`-final-substrate-review.md`) appears only in the Output format example — no canonical pin | Either drop the suffix specificity from the example or pin the literal suffix in invariant §Runtime paths |
| 8 | Low | Implicit invariant | Dispatch-budget threshold of 8 is a tunable constant with no substrate home — magic number lives only in SKILL prose | Add a row to `phase-derivation.md` §Rules naming the threshold explicitly with a tuning-rule and history convention |
| 9 | Low | Implicit invariant | Phase 1 coverage table (phases-as-rows) and `delta-coverage-reviewer` coverage table (entries-as-rows) are intentionally different shapes for different scopes — easy to homogenize accidentally | Add one sentence to `phase-derivation.md` §Out of scope or invariant §Runtime paths noting the shape distinction is intentional |

## Behavior/spec alignment

The skill body, the invariant, the new agent, and the validator agree on the loop's structure (Step 0 / Phase 1–3 / Step 4) and the per-phase composition with Superpowers (`writing-plans` + `executing-plans`). The bypass acknowledgment is structurally pinned. The Step/Phase nomenclature hybrid (initially jarring) lands cleanly because the SKILL body explicitly explains the choice (`implement-cohesively/SKILL.md:33–34`).

## Invariant preservation

`PLUGIN_ROOT_PATHS` and `VERDICT_BEFORE_EVIDENCE` preserved across all new files. `IMPLEMENTATION_PLAN_COVERS_DELTA` introduces with five structural enforcement points, but its scope is wider than peer invariants (see Finding 2).

## Test guarantee gaps

Validator pins three new substrate-pin checks (13d/13e/13f), each grep-anchored to the literal substrate text. Phase 2c's escalation rule and the Phase 3 filename schema are not pinned (Findings 4, 7).

## Locality and abstraction concerns

The phase-derivation matrix is the right substrate-shape↔TDD-shape seam. Premature centralization risk is low — `implement-cohesively` orchestrates rather than reimplements. The decision-matrix triplication (Finding 1) is the only locality concern with real centralization weight; the rest are smaller concept-tier issues.

## Highest-leverage fix

**Finding 1** (decision-matrix triplication) — the only High-severity finding and the only one with an asymmetric cost-of-future-drift profile. Lifting the matrix into a single normative source (a new `docs/substrate/matrices/post-validation-options.md`) and grepping the matrix doc rather than the SKILL would reduce five edit sites to two without losing enforcement strength.

## What looked right

- Validator structural fences match the gotcha's test list line-for-line (13d/13e/13f map to bullets 2/3/4).
- Composition-with-superpowers seam right-sized: tight composition for `implement-cohesively` is documented as a structural choice, not a local convenience.
- Phase-derivation matrix is the load-bearing seam doing real work.
- Step/Phase nomenclature hybrid lands cleanly with explicit explanation in the SKILL body.
- Repair pass 1 + Repair pass 2 closed all twelve findings from validation passes 1+2 in place without scope creep.

### Recommended next Cohesive skill

- **Pass with notes:** `superpowers:writing-plans` — substrate is preserved; ready for implementation discipline. *(Already complete — Tasks 1–4 of the implementation plan landed before this review; this branch is ready for `superpowers:finishing-a-development-branch` as a user action.)*
- The nine findings above are advisory, not gating. They could fold into a follow-up substrate-only repair pass 3 (Findings 1, 2, 3, 4 are highest-leverage), or be addressed in V1 — at the user's discretion.
