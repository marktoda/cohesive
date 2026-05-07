# Design Delta Ledger — run-scaffolding cleanup (PR artifact lifecycle)

**Date:** 2026-05-07
**Worktree / branch:** `.worktrees/cohesive-run-scaffolding-cleanup` on `design/run-scaffolding-cleanup`
**Approved direction:** Strip-at-handoff. Ephemeral artifacts (per-phase plans, discovery reports, per-phase reviewer verdicts when they persist) live on the `design/<slug>` branch during the implementation pass; `implement-cohesively` Phase 3.5 strips them via a cleanup commit on Implemented verdict before handoff to `superpowers:finishing-a-development-branch`. Main's tree carries only durable decision records.

This ledger records *what changed* in the substrate during the rewrite-specs pass for the brainstorm at `docs/history/brainstorms/2026-05-07-run-scaffolding-cleanup.md`. Classification: **Mixed** — substrate-layer changes (substrate-layout convention + artifact-placement matrix + IMPLEMENTATION_PLAN_COVERS_DELTA invariant + new gotcha + handoffs.md) plus implementation-layer changes (`implement-cohesively` SKILL.md). Design-layer changes are listed first in §"Files rewritten" and §"New or updated substrate"; the SKILL.md change implements the substrate-layer rules.

## Delta at a glance

This rewrite is **Mixed**. Design-layer changes: substrate-layout convention adds Lifecycle axis; artifact-placement matrix adds Lifecycle by artifact category section; IMPLEMENTATION_PLAN_COVERS_DELTA adds Rule #6 and tightens citation distinction; handoffs.md (implement-cohesively → finishing-a-development-branch) names Phase 3.5 cleanup as preceding the handoff; new gotcha plans-as-run-scaffolding.md. Implementation changes: `implement-cohesively/SKILL.md` adds Phase 3.5, Hard constraint #6, and trailer Branch-state cleanup-SHA slot.

- **Files:** 5 rewritten, 2 added, 0 removed/deprecated
- **Conceptual changes:** Lifecycle axis (durable vs ephemeral) introduced for `docs/history/` artifacts; durable audit citation (delta-entry stable IDs) distinguished from runtime audit citation (plan paths)
- **Named invariants:** `IMPLEMENTATION_PLAN_COVERS_DELTA` (strengthened — Rule #6 added; §"Runtime paths", §"Enforcement", §"Review checklist" extended for Phase 3.5 cleanup gating) — no other invariants added or removed
- **Behavior matrices:** `artifact-placement.md` (cells added — new §"Lifecycle by artifact category" classifying all 10 artifact categories) — no new matrix files
- **Gotchas:** `plans-as-run-scaffolding.md` (added) — none retired
- **Semantic linters:** none added; deferred CI grep target shifts from "plan path" form to "delta-entry stable ID" form per the durable-citation distinction
- **Tests proposed:** none — enforcement is skill-body acceptance criteria + reviewer judgment; CI grep target is deferred per existing invariant convention
- **Deferred (out of scope this pass):** per-phase delta-coverage verdict file persistence (currently chat-only — classified as ephemeral by construction in §"Lifecycle by artifact category" so future persistence inherits the cleanup pattern); CI grep promotion (deferred per `IMPLEMENTATION_PLAN_COVERS_DELTA` §"Enforcement" convention); existing-repo migration tooling for repos like pinky that have plans already in main (manual `git rm` PR is sufficient for v0.1)

## Files rewritten

- `docs/substrate/conventions/substrate-layout.md`
  - **Before:** §"The split" framed the layout as canonical (`substrate/`, replace-on-update) vs historical (`history/`, append-only dated); every artifact under `docs/history/` carried the same persists-forever lifecycle.
  - **After:** §"The split" preamble names two principles (canonical/historical *and* durable/ephemeral). New §"Lifecycle: durable vs ephemeral" introduces the two-class split inside `docs/history/`. New §"Cleanup at handoff" names the strip-at-handoff convention with operational steps and gating rules. §"Skill behavior" gains Rule #4 requiring lifecycle classification at artifact-introduction time. §"Anti-patterns" gains three new entries (ephemeral leaking into main; new category without lifecycle classification; gitignoring ephemeral artifacts).
  - **Reason:** The lifecycle axis is what distinguishes durable decision records from run scaffolding; without it, the persists-forever default produces the bloat documented in `gotchas/plans-as-run-scaffolding.md`.

- `docs/substrate/matrices/artifact-placement.md`
  - **Before:** §"Cells" was the only matrix surface; rows were repo shapes, columns were artifact categories (Review / Delta ledger / Brainstorm). Every artifact category persisted in main by default; lifecycle was implicit and unclassified.
  - **After:** §"Purpose" expanded to name the two persistence axes (where + whether). New §"Lifecycle by artifact category" classifies all 10 artifact categories Cohesive produces or consumes — 7 durable, 3 ephemeral — with cleanup-target paths for each ephemeral row. §"Lifecycle rules" names four rules: durable-regardless-of-verdict, ephemeral-cleanup-gated-on-Implemented, cleanup-commit-as-breadcrumb, new-categories-register-lifecycle. §"Related substrate" expanded with cross-links to substrate-layout §"Cleanup at handoff", IMPLEMENTATION_PLAN_COVERS_DELTA, the new gotcha, and `implement-cohesively` §"Phase 3.5".
  - **Reason:** The cell-by-cell classification is what makes the lifecycle convention testable per-artifact; without it, the substrate-layout convention has no per-category authority to point at.

- `docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md`
  - **Before:** Top-of-file callout claimed "phases without a plan persisted at `docs/history/plans/` cannot exist." Rule #2 said plans persist at the path; Rule #3 said commit messages cite "the plan path and the stable IDs." §"Runtime paths" said "Plans persisted here are the audit trail. A branch with implementation commits but no plans persisted is a violation." The invariant treated plan paths and delta-entry stable IDs as equally durable citations.
  - **After:** Top-of-file callout distinguishes runtime persistence (plans persist at the path *during the run*) from durable citation (delta-entry stable ID in commit message survives Phase 3.5 cleanup). Rule #2 names plans as ephemeral per the artifact-placement matrix; Rule #3 splits the citation requirement into durable (stable IDs) and pre-cleanup branch-history pointer (plan paths). New Rule #6 names Phase 3.5 cleanup gated on Implemented. §"Runtime paths" extended with Phase 3.5 entry and a runtime-vs-durable note on plans. §"Enforcement" extended with Phase 3.5 gating, durable-vs-runtime citation note, and shifted CI grep target. §"Review checklist" replaced item #3 with a runtime-check version, added items for cleanup-fires-on-Implemented and cleanup-does-not-fire-on-other-verdicts. §"Related" expanded with cross-links to artifact-placement §"Lifecycle", substrate-layout §"Cleanup at handoff", and the new gotcha. §"History" gains a 2026-05-07 entry.
  - **Reason:** The invariant was the load-bearing pin against silent substrate drift; tightening the durable-vs-runtime citation distinction is what makes Phase 3.5 cleanup compatible with the invariant's audit-trail promise.

- `skills/implement-cohesively/SKILL.md`
  - **Before:** Process had Step 0, Phase 1, Phase 2, Phase 3, Step 4 — five labeled sections. Hard constraints stopped at #5 (final substrate review mandatory). Anti-patterns table had nine rows. Output format §"Branch state" carried Branch / Commits / Plans-persisted-count.
  - **After:** Process gains Phase 3.5 between Phase 3 and Step 4 — six labeled sections — with operational steps for ephemeral path enumeration, tracked-path verification, cleanup commit production, and SHA capture. Hard constraints gain #6 (Phase 3.5 ephemeral cleanup is gated on Implemented verdict; cleanup on a non-Implemented verdict is a violation; skipping cleanup on Implemented is a violation; cleanup commit body must list removed paths verbatim). §"What this skill produces" expanded to name plans as ephemeral run scaffolding and the cleanup commit as the breadcrumb. Process intro updated to enumerate Phase 3.5 alongside Phase 1/2/3. Phase 3 verdict outcomes updated: Pass/Pass-with-notes proceeds to Phase 3.5; non-Pass verdicts skip directly to Step 4. Output format §"Branch state" gains a `Cleanup commit:` line rendered only on Implemented; render-conditional rules updated. Anti-patterns table gains four new rows (skipping cleanup on Implemented; firing cleanup on non-Implemented; cleanup commit without verbatim list; stripping durable artifacts at Phase 3.5). Acceptance criteria gains items for Phase 3.5 firing, cleanup commit shape, and trailer Branch-state SHA surfacing. Phase commit citation requirement clarified: cite both stable IDs (durable) and plan path (pre-cleanup branch-history pointer).
  - **Reason:** Phase 3.5 is the structural enforcement of the lifecycle convention; without the new step in the SKILL body, the substrate-layer rule has no implementing surface and the anti-patterns have no skill-body fence to violate.

- `docs/substrate/architecture/handoffs.md`
  - **Before:** §"implement-cohesively → finishing-a-development-branch (Implemented)" was four short paragraphs (verdict gate, downstream skill, what-must-not-re-derive, failure mode) treating the handoff as a direct branch-to-merge transition.
  - **After:** Same four-paragraph shape, expanded: verdict gate names Phase 3.5 cleanup as part of the Implemented condition; new "Phase 3.5 precedes this handoff" paragraph explains the cleanup pattern with cross-links to `implement-cohesively` §"Phase 3.5" and substrate-layout §"Cleanup at handoff"; new "Artifact crossing" paragraph names the branch + cleanup-commit-SHA pair; what-must-not-re-derive extended with "must not undo the Phase 3.5 cleanup"; failure-mode paragraph extended from one cause to three (auto-invocation, Phase-3.5-skipped-on-Implemented, Phase-3.5-fired-on-non-Implemented), each with a detection mechanism.
  - **Reason:** The handoff contract is the structural interface between Cohesive's terminal verdict and Superpowers' branch-finishing; without naming Phase 3.5 in the contract, the cleanup step has no documented seam in the cross-skill layer.

## Files added

- `docs/substrate/gotchas/plans-as-run-scaffolding.md` — names the failure mode the lifecycle convention prevents: per-phase plans and discovery reports look durable because they live under `docs/history/`, but they are run scaffolding cleaned up at handoff. The gotcha covers symptom (PR bloat + post-merge dangling citations), why-it-happened (the original `docs/history/` lifecycle had no axis to express the difference), tempting wrong fix (`.gitignore` causes citation rot at commit time), correct pattern (strip-at-handoff via Phase 3.5), related invariant (`IMPLEMENTATION_PLAN_COVERS_DELTA` durable-vs-runtime citation distinction), structural enforcement (Phase 3.5 + structure-reviewer + cleanup-commit-as-breadcrumb), discovery (2026-05-07, pinky PR #175 brainstorm), and notes for future contributors (the lifecycle axis is orthogonal to the audience seam; per-phase delta-coverage verdicts are pre-classified ephemeral for forward compatibility).

- `docs/history/delta-ledgers/2026-05-07-run-scaffolding-cleanup.md` — this ledger.

## Files removed or deprecated

None. The rewrite is purely additive (new gotcha + new SKILL phase + new matrix section + new convention section) and purely tightening (existing invariant rules clarified, not weakened).

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| `docs/history/` artifacts share one lifecycle (persists-forever-after-commit) | `docs/history/` artifacts split along a lifecycle axis: **durable** (persists-forever) vs **ephemeral** (cleaned up at handoff on Implemented verdict) | Tightened |
| `IMPLEMENTATION_PLAN_COVERS_DELTA` plan-path citation = audit citation | Plan-path citation is the **pre-cleanup branch-history pointer** (resolves during the run, recoverable via `git log --all` after cleanup); the **delta-entry stable ID** is the durable audit citation that survives Phase 3.5 cleanup | Tightened |
| `cohesive:implement-cohesively` Process: Step 0 → Phase 1 → Phase 2 → Phase 3 → Step 4 | Process: Step 0 → Phase 1 → Phase 2 → Phase 3 → Phase 3.5 → Step 4 (Phase 3.5 conditionally fires on Implemented verdict only) | Tightened |
| `validate-rewrite → implement-cohesively → finishing-a-development-branch` is a clean two-edge handoff with no intermediate cleanup step | The handoff to `finishing-a-development-branch` is preceded by Phase 3.5 cleanup on Implemented verdict; the cleanup commit at HEAD is part of the artifact crossing | Tightened |

## New or updated substrate

### Specs

- `docs/substrate/conventions/substrate-layout.md` — adds Lifecycle axis, Cleanup at handoff section, lifecycle classification rule for skill-creating-new-artifacts; expands anti-patterns.
- `docs/substrate/architecture/handoffs.md` — `implement-cohesively → finishing-a-development-branch (Implemented)` edge contract names Phase 3.5 as preceding the handoff; failure modes extended.

### Behavior matrices

- `docs/substrate/matrices/artifact-placement.md` — new §"Lifecycle by artifact category" classifies all 10 artifact categories with cleanup-target paths; new §"Lifecycle rules" names four operational rules.

### Named invariants

- `IMPLEMENTATION_PLAN_COVERS_DELTA` — strengthened. Rule #6 added (Phase 3.5 cleanup gated on Implemented). Rule #3 split into durable + runtime citation. §"Runtime paths" extended. §"Enforcement" extended with cleanup gating and citation distinction. §"Review checklist" replaced item #3 with runtime-check version; added cleanup-fires and cleanup-does-not-fire items.

### Gotchas

- `plans-as-run-scaffolding.md` — added. Names the failure mode the lifecycle convention prevents.

### Semantic linter specs

None added or proposed in this pass. The deferred CI grep target named in `IMPLEMENTATION_PLAN_COVERS_DELTA` §"Enforcement" shifts focus from "plan path appears in commit message" to "delta-entry stable ID appears in commit message" — the latter is the durable citation that survives Phase 3.5 cleanup and remains greppable in main.

### Tests / checks proposed (not yet implemented)

None. Enforcement is skill-body acceptance criteria (`implement-cohesively` Hard constraint #6, Acceptance criteria items) plus reviewer judgment (`cohesive:review-codebase` structure-reviewer flagging missing cleanup commits) plus the deferred CI grep promotion path.

## What this rewrite *did not* do

- Implementation code: not changed. The cleanup-commit-producing logic in `implement-cohesively`'s Phase 3.5 is described in the SKILL body at the prose level; the actual code that runs at Phase 3.5 is the agent's own work driven by the SKILL prose, not pre-existing code.
- Tests: not changed. No test files in this repo today; no test additions proposed in this pass.
- CI: not changed. The deferred CI grep is a future tightening, not in scope.
- Migration tooling for repos with plans already in main: not provided. Manual `git rm` PR is sufficient for v0.1; existing-repo migration is named in §"Deferred" of the brainstorm but out of scope here.
- Per-phase delta-coverage verdict file persistence: not changed (still chat-only). The lifecycle classification in `artifact-placement.md` §"Lifecycle by artifact category" pre-classifies them as ephemeral so future persistence inherits cleanup automatically; the file-persistence work itself is deferred.
- `validate-rewrite` SKILL body: untouched. The validation review is durable; nothing changes for the validate-rewrite skill.
- `discover-substrate` SKILL body: untouched. Discovery reports are classified as ephemeral in `artifact-placement.md` but the discover-substrate skill body already writes them to disk per its convention; cleanup happens in `implement-cohesively` Phase 3.5, not in discover-substrate.

## Remaining ambiguity

- **Migration tooling for existing repos** — repos with plans already in main get a brainstorm acknowledgment but no substrate path. A bulk `git rm` PR is the manual path; whether Cohesive ships a one-shot migration skill is deferred. (Closes substrate gap from pass-1 review.)
- **Per-phase delta-coverage verdict promotion path** — when verdicts promote from chat-only to file persistence, that PR adds the row to `artifact-placement.md` §"Lifecycle by artifact category" and updates `implement-cohesively` Phase 3.5's enumerated paths. The pre-classification was removed from this rewrite per pass-1 finding I2; promotion is a separate substrate change.

## Repair pass 1 — pass-1 review I1, I2, simplification

Source review: `docs/history/reviews/2026-05-07-run-scaffolding-cleanup-rewrite-validation.md` (Approved, two Mediums + two substrate gaps + author-driven simplification pass).

Closed in this pass:

- **Closes I1 (Run boundary unnamed).** `IMPLEMENTATION_PLAN_COVERS_DELTA.md` §"Rule" gains a closing paragraph defining run = Phase 1 inception → Phase 3 verdict, independent of Claude session boundary. Plans persist on the branch across session disconnects.
- **Closes I2 (Speculative matrix row).** Removed the "Per-phase delta-coverage verdict (when persisted)" row from `artifact-placement.md` §"Lifecycle by artifact category" and the corresponding glob from `implement-cohesively/SKILL.md` Phase 3.5. The matrix is extended in the same pass that promotes verdicts to file persistence (pre-classifying speculative artifacts in normative spec violates `rewrite-specs` Hard constraint #5).
- **Closes substrate gap (squash-merge / force-push forensic edge).** `substrate-layout.md` §"Cleanup at handoff" gains a §"Forensic recovery edges" paragraph naming the merge-commit / squash / force-push behaviors.
- **Closes substrate gap (existing-repo migration).** Migration pointer added to `plans-as-run-scaffolding.md` §"Correct pattern".

Author-driven simplifications (no review finding; user requested):

- `artifact-placement.md` §"Lifecycle by artifact category" table collapsed from 5 columns × 10 rows to 3 columns × 3 rows; durable categories merged into one row. §"Lifecycle rules" subsection removed (one truly-novel rule folded into the table footer).
- `substrate-layout.md` §"Lifecycle: durable vs ephemeral" compressed by ~50%; §"Why the split" two-paragraph form merged into one.
- `IMPLEMENTATION_PLAN_COVERS_DELTA.md` §"Runtime paths" condensed from 6 bullets to 3; §"Enforcement" condensed; §"Review checklist" tightened to 6 items from 9; durable-vs-runtime citation named-concept treatment compressed (the distinction remains structural, the vocabulary is no longer multi-paragraph).
- `implement-cohesively/SKILL.md` Phase 3.5 collapsed from 4 numbered sub-steps to 2 sentences + commit template; anti-pattern table consolidated 4 rows to 1.
- `substrate-layout.md` §"Anti-patterns" 3 new entries collapsed to 1.
- `plans-as-run-scaffolding.md` compressed from 75 lines to ~45 lines; §"Notes for future contributors" removed (the audience-seam orthogonality belongs in `audience-separation.md`; the verdict-promotion pre-classification was removed per I2).
- Cross-references trimmed across all five rewritten files; each section names the single most-relevant link.

Net change: ~-220 lines of substrate prose without changing structural enforcement. Hard constraint #6, Rule #6, Phase 3.5, the matrix lifecycle classification, and the gotcha all hold; the spec is shorter without weakening the contract.

## Ready for fresh-eyes review?

**Yes.** The rewrite covers the six target files plus the new gotcha and this delta ledger; classification (Mixed) is named in the preamble; durable-vs-runtime citation distinction is consistent across `IMPLEMENTATION_PLAN_COVERS_DELTA`, `implement-cohesively/SKILL.md`, `substrate-layout.md`, `artifact-placement.md`, and the new gotcha; Phase 3.5 gating rules are consistent across the SKILL body Hard constraint #6, the invariant Rule #6, and the handoffs.md edge contract.

## How to read this ledger

1. **Approved direction line** at the top — Strip-at-handoff. Plans live on the branch, get cleaned up at handoff on Implemented verdict only.
2. **Delta at a glance** — 8-category preamble; this ledger is verbatim-quoted by `validate-rewrite` into the validation review.
3. **Conceptual changes** — the four shifts: lifecycle axis introduced; durable-vs-runtime citation split; Phase 3.5 added to Process; handoffs.md edge contract names cleanup as preceding the handoff.
4. **Files rewritten** — five files with before/after summaries; the SKILL.md change is the implementation layer for the four substrate-layer changes.
5. **Remaining ambiguity** — three open items (existing-repo migration, squash-merge interaction, future verdict-persistence promotion) — none Blocking, all forward-pass concerns.
