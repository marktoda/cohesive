# Artifact Placement Behavior Matrix

**Status:** Active
**Last reviewed:** 2026-05-08
**Owner:** Mark Toda

## Purpose

Cohesive skills persist output along two axes:

1. **Where the artifact lives** — resolved by the four-rule procedure in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/substrate-layout.md` §"Artifact directory resolution". §"Cells" below expands the resolution cell-by-cell across artifact category and repo shape.
2. **Whether the artifact persists in main** — defined per-category in §"Lifecycle by artifact category" below. **Durable** artifacts persist permanently; **ephemeral** artifacts are cleaned up at handoff per `${CLAUDE_PLUGIN_ROOT}/skills/implement-cohesively/SKILL.md` §"Step 3.5. Post-implementation cleanup".

This matrix expands both axes cell-by-cell so the contract is testable. Without §"Cells", an external-repo run can silently litter `docs/history/` into a user repo that already has `docs/adr/` — the placement failure Cohesive exists to prevent. Without §"Lifecycle by artifact category", the per-pass plan and discovery reports leak into main and produce the bloat documented in [`docs/substrate/gotchas/plans-as-run-scaffolding.md`](../gotchas/plans-as-run-scaffolding.md).

## Cells

Rows are repo shapes. Columns are artifact categories produced by the five persisting skills. Each cell names the resolved output directory.

| Repo shape | Review (`review-codebase`, `audit-substrate`, `validate-rewrite`) | Delta ledger (`rewrite-specs`) | Brainstorm (`brainstorm-design`, when persisted) |
|---|---|---|---|
| **A. Cohesive layout** — `docs/history/reviews/` exists | `docs/history/reviews/` | `docs/history/delta-ledgers/` | `docs/history/brainstorms/` |
| **B. ADR-style** — `docs/adr/` exists, no `docs/history/` | `docs/adr/reviews/` | `docs/adr/delta-ledgers/` | `docs/adr/brainstorms/` |
| **C. Specs-style** — `docs/specs/` exists, no `docs/history/` or `docs/adr/` | `docs/specs/reviews/` | `docs/specs/delta-ledgers/` | `docs/specs/brainstorms/` |
| **D. Design-style** — `docs/design/` exists, none of the above | `docs/design/reviews/` | `docs/design/delta-ledgers/` | `docs/design/brainstorms/` |
| **E. Decisions-style** — `docs/decisions/` exists, none of the above | `docs/decisions/reviews/` | `docs/decisions/delta-ledgers/` | `docs/decisions/brainstorms/` |
| **F. Architecture-style** — `docs/architecture/` exists, none of the above | `docs/architecture/reviews/` | `docs/architecture/delta-ledgers/` | `docs/architecture/brainstorms/` |
| **G. External-repo default** — `docs/` exists, none of A–F | `docs/cohesive/reviews/` | `docs/cohesive/delta-ledgers/` | `docs/cohesive/brainstorms/` |
| **H. No `docs/`** | `docs/cohesive/reviews/` (created) | `docs/cohesive/delta-ledgers/` (created) | `docs/cohesive/brainstorms/` (created) |

## Rules

- Resolution stops at the first matching row. A repo with both `docs/history/` and `docs/adr/` resolves as **A** (treat the existing Cohesive layout as authoritative; surface the duplication to the user).
- "Exists" means the directory is present, not that it is non-empty. An empty `docs/adr/` still triggers row B.
- Skills do not write outside `docs/`. Row H creates `docs/cohesive/<subdir>/` rather than placing artifacts at the repo root.
- The `validate-rewrite` skill writes its review artifact to the **review** column (not a separate `validation/` column), so an external user reading the resolved path sees `…/reviews/2026-05-04-<slug>-rewrite-validation.md` consistently with `review-codebase` output. The producing-skill suffix in the filename (`-rewrite-validation`, `-architecture-review`, `-audit-substrate`) tells a contributor which skill produced each artifact.
- Writing to row B–F means the matrix is colonizing a non-Cohesive convention. Skills do this on purpose — a repo that has chosen `docs/adr/` for its canonical decisions wants Cohesive output to land near them, not in a sibling `docs/history/`. The category subdir under the existing convention (`docs/adr/reviews/`) keeps Cohesive artifacts visible without renaming the host repo's convention.
- When `--no-write` is passed (only honored by `review-diff` and `validate-rewrite`), no resolution happens and no artifact is written.

## Skill behavior

- `review-codebase` resolves at Phase 0, before reading any substrate.
- `audit-substrate` resolves at step 0, before scanning.
- `rewrite-specs` resolves at step 0, before rewriting any docs (the resolved dir is where the design delta ledger is written).
- `brainstorm-design` resolves at Phase 0 *only when persistence is requested*. Many brainstorms end at the recommendation without persisting.
- `validate-rewrite` resolves at step 0, before dispatching the reviewer agent.

The resolved path is announced in chat at the start of the run, before any read or dispatch. Hardcoding `docs/history/<subdir>/` is a violation of this matrix.

## Lifecycle by artifact category

Every artifact category Cohesive produces carries exactly one lifecycle. **Durable** artifacts persist permanently in main. **Ephemeral** artifacts are committed during the implementation pass on the `design/<slug>` branch and cleaned up at Step 3.5 of `cohesive:implement-cohesively` (post-implementation cleanup), gated on Implemented verdict only.

| Artifact category | Lifecycle | Cleanup target (ephemeral only) |
|---|---|---|
| Brainstorm, delta ledger, validation review, architecture review, substrate audit, final substrate review, transcript | **Durable** | n/a |
| Per-pass plan | **Ephemeral** | `git rm docs/history/plans/<YYYY-MM-DD>-<slug>.md` |
| Discovery report | **Ephemeral** | `git rm docs/cohesive/discovery/<slug>.md` (when present) |

Producing skill and consumer for each category are documented in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/handoffs.md`. New artifact categories register their lifecycle in this table *in the same pass* as the skill change; default to **Durable** when ambiguous.

## Related substrate

- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/substrate-layout.md` §"Artifact directory resolution" — the four-rule procedure each skill cites.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/substrate-layout.md` §"Lifecycle: durable vs ephemeral" + §"Cleanup at handoff" — the lifecycle convention this matrix expands per-category.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md` — the invariant pinning ephemeral-artifact citation rules (stable IDs are durable; plan paths are pre-cleanup branch-history pointers).
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/plans-as-run-scaffolding.md` — the failure mode the lifecycle classification prevents.
- `${CLAUDE_PLUGIN_ROOT}/skills/implement-cohesively/SKILL.md` §"Step 3.5. Post-implementation cleanup" — the structural enforcement of ephemeral cleanup.
- `${CLAUDE_PLUGIN_ROOT}/AGENTS.md` §"Default substrate locations" — names the layout for this repo's substrate (separate concern from artifact placement).
- `${CLAUDE_PLUGIN_ROOT}/ARCHITECTURE.md` §"Conventions" — names `docs/cohesive/<x>/` as the external-repo default.

## Out of scope

- Where canonical substrate artifacts (invariants, gotchas, behavior matrices, designs) live — that's `substrate-layout.md` §"The split". This matrix is only about workflow-product placement.
- The contents of each artifact — defined per-skill in the skill body's "Output format" section.
- Filename conventions — defined in `substrate-layout.md` §"Naming".

## History

- 2026-05-04 — Created during the v0.1 release-gate Phase 1+2 substrate repair pass. Promoted from finding #2 of `docs/history/reviews/2026-05-04-skill-quality-self-review.md` to a tracked behavior matrix; previously documented only in prose at `AGENTS.md:57` and `ARCHITECTURE.md:48`.
- 2026-05-07 — Added §"Lifecycle by artifact category" introducing the durable/ephemeral split per the brainstorm at `docs/history/brainstorms/2026-05-07-run-scaffolding-cleanup.md`. The matrix now tracks both placement (where) and lifecycle (whether persists in main); `implement-cohesively` Step 3.5 enforces ephemeral cleanup.
- 2026-05-08 — `Per-phase plan` row collapsed to `Per-pass plan` per the single-pass redesign at `docs/history/brainstorms/2026-05-08-implement-cohesively-single-pass.md`. The cleanup target glob simplifies to a single path. Step 3.5 cleanup gating logic preserved.
